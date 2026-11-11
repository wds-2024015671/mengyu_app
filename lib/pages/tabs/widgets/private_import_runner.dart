import 'dart:io';

import 'package:dio/dio.dart';

import '../../../data/services/yt_dlp_service.dart';
import '../../../models/private_media.dart';

class PrivateImportRun {
  const PrivateImportRun({
    required this.media,
    required this.file,
    required this.fileSize,
  });

  final ParsedMediaInfo media;
  final File file;
  final int fileSize;
}

/// 解析 + 下载的单一执行体；页面只负责状态与 UI。
class PrivateImportRunner {
  PrivateImportRunner(this._service);

  final YtDlpService _service;
  CancelToken? _cancelToken;

  Future<PrivateImportRun> run({
    required String url,
    required PrivateMediaType type,
    required void Function(double progress) onProgress,
    void Function(ParsedMediaInfo media)? onParsed,
  }) async {
    final ParsedMediaInfo media = await _service.parse(url, type: type);
    onParsed?.call(media);
    final CancelToken token = CancelToken();
    _cancelToken = token;
    final File file = await _service.download(
      media: media,
      type: type,
      cancelToken: token,
      onProgress: onProgress,
    );
    final int size = await file.length();
    return PrivateImportRun(media: media, file: file, fileSize: size);
  }

  void cancel() {
    _cancelToken?.cancel();
    _cancelToken = null;
  }
}
