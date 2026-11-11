import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

import '../../core/errors/app_exception.dart';
import '../../models/private_media.dart';

class PickedLocalMedia {
  const PickedLocalMedia({
    required this.source,
    required this.file,
    required this.title,
    required this.durationMs,
    required this.fileSize,
    required this.type,
  });

  final File source;
  final File file;
  final String title;
  final int durationMs;
  final int fileSize;
  final PrivateMediaType type;
}

abstract interface class LocalMediaService {
  Future<File?> pick(PrivateMediaType type);

  Future<PickedLocalMedia> import(File source, PrivateMediaType type);
}

/// 手机本地音视频导入：系统文件选择器 → App 私有目录 → 读取时长。
class FilePickerLocalMediaService implements LocalMediaService {
  static const Set<String> audioExtensions = <String>{
    'mp3',
    'm4a',
    'aac',
    'wav',
    'ogg',
    'flac',
  };
  static const Set<String> videoExtensions = <String>{
    'mp4',
    'mov',
    'webm',
    'mkv',
  };

  @override
  Future<File?> pick(PrivateMediaType type) async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions:
          (type == PrivateMediaType.audio ? audioExtensions : videoExtensions)
              .toList(growable: false),
      allowMultiple: false,
      withData: false,
    );
    final String? path = result?.files.single.path;
    if (path == null || path.isEmpty) {
      return null;
    }
    return File(path);
  }

  @override
  Future<PickedLocalMedia> import(
    File source,
    PrivateMediaType type,
  ) async {
    if (!source.existsSync()) {
      throw const AppException('无法读取所选文件');
    }
    final String extension =
        p.extension(source.path).replaceFirst('.', '').toLowerCase();
    final Set<String> allowed = type == PrivateMediaType.audio
        ? audioExtensions
        : videoExtensions;
    if (!allowed.contains(extension)) {
      throw const AppException('文件格式与所选类型不匹配');
    }
    final Directory docs = await getApplicationDocumentsDirectory();
    final Directory dir = Directory(p.join(docs.path, 'private_media'));
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }
    final String title = p.basenameWithoutExtension(source.path).trim();
    final String safe = title
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '')
        .replaceAll(RegExp(r'\s+'), '_');
    final String name =
        '${DateTime.now().millisecondsSinceEpoch}_${safe.isEmpty ? 'media' : safe}.$extension';
    final File target = File(p.join(dir.path, name));
    final File part = File('${target.path}.part');
    try {
      await source.copy(part.path);
      await part.rename(target.path);
    } catch (error) {
      if (part.existsSync()) {
        await part.delete();
      }
      throw AppException('保存文件失败，请检查存储空间', error);
    }
    int durationMs = 0;
    try {
      durationMs = type == PrivateMediaType.audio
          ? await _audioDuration(target)
          : await _videoDuration(target);
    } catch (_) {
      durationMs = 0;
    }
    return PickedLocalMedia(
      source: source,
      file: target,
      title: title.isEmpty ? '未命名媒体' : title,
      durationMs: durationMs,
      fileSize: await target.length(),
      type: type,
    );
  }

  Future<int> _audioDuration(File file) async {
    final AudioPlayer player = AudioPlayer();
    try {
      await player.setSourceDeviceFile(file.path);
      final Duration? duration = await player.getDuration();
      return duration?.inMilliseconds ?? 0;
    } finally {
      await player.dispose();
    }
  }

  Future<int> _videoDuration(File file) async {
    final VideoPlayerController controller =
        VideoPlayerController.file(file);
    try {
      await controller.initialize();
      return controller.value.duration.inMilliseconds;
    } finally {
      await controller.dispose();
    }
  }
}
