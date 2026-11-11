import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/errors/app_exception.dart';
import '../../models/private_media.dart';

class ParsedMediaInfo {
  const ParsedMediaInfo({
    required this.title,
    required this.url,
    required this.platform,
    required this.extension,
    this.durationMs = 0,
    this.thumbnailUrl,
  });

  final String title;
  final String url;
  final String platform;
  final String extension;
  final int durationMs;
  final String? thumbnailUrl;
}

abstract interface class YtDlpService {
  Future<ParsedMediaInfo> parse(String url, {required PrivateMediaType type});

  Future<File> download({
    required ParsedMediaInfo media,
    required PrivateMediaType type,
    required CancelToken cancelToken,
    required void Function(double progress) onProgress,
  });
}

/// 公开链接解析/下载边界。
///
/// 当前 Flutter 3.22（Dart 3.4.3）无法安装 flutter_yt_dlp 0.2.2（要求 Dart 3.5.3），
/// 因此默认只支持可直接下载的 http(s) 媒体地址；平台页链接会明确提示不支持。
/// 未来升级 Flutter 后只需替换本实现，页面与 Provider 不用改。
class DirectYtDlpService implements YtDlpService {
  DirectYtDlpService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  static const Set<String> _audioExts = <String>{
    'mp3',
    'm4a',
    'aac',
    'wav',
    'ogg',
    'flac',
  };
  static const Set<String> _videoExts = <String>{'mp4', 'mov', 'webm', 'mkv'};

  @override
  Future<ParsedMediaInfo> parse(
    String url, {
    required PrivateMediaType type,
  }) async {
    final Uri? uri = validateMediaUrl(url);
    if (uri == null) {
      throw const AppException('请输入有效的 http(s) 链接');
    }
    final String platform = _platformOf(uri);
    final String rawExt =
        p.extension(uri.path).replaceFirst('.', '').toLowerCase();
    if (platform != '本地' && rawExt.isEmpty) {
      throw AppException('当前版本暂不支持解析 $platform 页面链接');
    }
    final String ext = _extensionOf(uri, type);
    final Set<String> allowed = type == PrivateMediaType.audio
        ? _audioExts
        : _videoExts;
    if (!allowed.contains(ext)) {
      throw AppException(
        platform == '本地'
            ? '该链接不是可直接下载的${type == PrivateMediaType.audio ? '音频' : '视频'}文件'
            : '当前版本暂不支持解析 $platform 页面链接',
      );
    }
    final String decoded = Uri.decodeComponent(
      uri.pathSegments.isEmpty ? '未命名媒体' : uri.pathSegments.last,
    );
    final String title = decoded
        .replaceAll(RegExp(r'\.[A-Za-z0-9]+$'), '')
        .trim();
    return ParsedMediaInfo(
      title: title.isEmpty ? '未命名媒体' : title,
      url: uri.toString(),
      platform: platform,
      extension: ext,
    );
  }

  @override
  Future<File> download({
    required ParsedMediaInfo media,
    required PrivateMediaType type,
    required CancelToken cancelToken,
    required void Function(double progress) onProgress,
  }) async {
    try {
      final Directory docs = await getApplicationDocumentsDirectory();
      final Directory dir = Directory(p.join(docs.path, 'private_media'));
      if (!dir.existsSync()) {
        await dir.create(recursive: true);
      }
      final String safeTitle = _safeName(media.title);
      final String name =
          '${DateTime.now().millisecondsSinceEpoch}_$safeTitle.${media.extension}';
      final File target = File(p.join(dir.path, name));
      final File part = File('${target.path}.part');
      try {
        await _dio.download(
          media.url,
          part.path,
          cancelToken: cancelToken,
          onReceiveProgress: (int received, int total) {
            if (total > 0) {
              onProgress((received / total).clamp(0.0, 1.0));
            }
          },
        );
        if (part.existsSync()) {
          await part.rename(target.path);
        }
        return target;
      } catch (_) {
        if (part.existsSync()) {
          await part.delete();
        }
        rethrow;
      }
    } on DioException catch (error) {
      if (CancelToken.isCancel(error)) {
        throw const AppException('已取消下载');
      }
      throw AppException(
        '下载失败，请检查网络或链接是否可访问',
        error,
      );
    } on AppException {
      rethrow;
    } catch (error) {
      throw AppException('下载失败，请稍后再试', error);
    }
  }

  static Uri? validateMediaUrl(String raw) {
    final Uri? uri = Uri.tryParse(raw.trim());
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      return null;
    }
    if (uri.scheme != 'http' && uri.scheme != 'https') {
      return null;
    }
    return uri;
  }

  String _platformOf(Uri uri) {
    final String host = uri.host.toLowerCase();
    if (host.contains('bilibili') || host == 'b23.tv') {
      return 'Bilibili';
    }
    if (host.contains('youtube') || host == 'youtu.be') {
      return 'YouTube';
    }
    if (host.contains('douyin')) {
      return '抖音';
    }
    return '本地';
  }

  String _extensionOf(Uri uri, PrivateMediaType type) {
    final String ext = p.extension(uri.path).replaceFirst('.', '').toLowerCase();
    if (ext.isNotEmpty) {
      return ext;
    }
    return type == PrivateMediaType.audio ? 'm4a' : 'mp4';
  }

  String _safeName(String value) {
    final String cleaned = value
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '')
        .replaceAll(RegExp(r'\s+'), '_')
        .trim();
    if (cleaned.isEmpty) {
      return 'media';
    }
    return cleaned.length > 60 ? cleaned.substring(0, 60) : cleaned;
  }
}
