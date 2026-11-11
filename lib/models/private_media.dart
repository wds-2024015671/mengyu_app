import 'audio_item.dart';

enum PrivateMediaType { audio, video }

enum PrivateMediaStatus { downloading, ready, failed }

/// 私人库条目：来自公开链接导入，文件只保存在本机。
class PrivateMedia {
  const PrivateMedia({
    required this.id,
    required this.type,
    required this.title,
    required this.sourceUrl,
    required this.localPath,
    required this.durationMs,
    required this.platform,
    required this.fileSize,
    required this.status,
    required this.createdAt,
    this.thumbUrl,
    this.thumbPath,
  });

  final int id;
  final PrivateMediaType type;
  final String title;
  final String sourceUrl;
  final String localPath;
  final int durationMs;
  final String platform;
  final int fileSize;
  final PrivateMediaStatus status;
  final DateTime createdAt;
  final String? thumbUrl;
  final String? thumbPath;

  bool get isReady => status == PrivateMediaStatus.ready;

  AudioItem toAudioItem() {
    return AudioItem(
      id: 'private_$id',
      title: title,
      category: platform,
      sourceType: AudioSourceType.file,
      filePath: localPath,
      durationSec: durationMs > 0 ? durationMs ~/ 1000 : 0,
      fileSize: fileSize,
      status: AudioItem.statusPublished,
    );
  }

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'type': type.name,
      'title': title,
      'source_url': sourceUrl,
      'local_path': localPath,
      'duration_ms': durationMs,
      'platform': platform,
      'file_size': fileSize,
      'status': status.name,
      'created_at': createdAt.toUtc().toIso8601String(),
      'thumb_url': thumbUrl,
      'thumb_path': thumbPath,
    };
  }

  factory PrivateMedia.fromMap(Map<String, Object?> map) {
    final int id = (map['id'] as num?)?.toInt() ?? 0;
    final DateTime created = DateTime.tryParse(
          map['created_at']?.toString() ?? '',
        )?.toLocal() ??
        DateTime.now();
    return PrivateMedia(
      id: id,
      type: PrivateMediaType.values.firstWhere(
        (PrivateMediaType value) => value.name == map['type'],
        orElse: () => PrivateMediaType.audio,
      ),
      title: map['title']?.toString() ?? '未命名',
      sourceUrl: map['source_url']?.toString() ?? '',
      localPath: map['local_path']?.toString() ?? '',
      durationMs: (map['duration_ms'] as num?)?.toInt() ?? 0,
      platform: map['platform']?.toString() ?? '本地',
      fileSize: (map['file_size'] as num?)?.toInt() ?? 0,
      status: PrivateMediaStatus.values.firstWhere(
        (PrivateMediaStatus value) => value.name == map['status'],
        orElse: () => PrivateMediaStatus.ready,
      ),
      createdAt: created,
      thumbUrl: map['thumb_url']?.toString(),
      thumbPath: map['thumb_path']?.toString(),
    );
  }
}
