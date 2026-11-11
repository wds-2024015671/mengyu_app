/// 音源类型：App 内置资源 / 已下载到本机文件 / 服务端远程地址。
///
/// 为什么单独建枚举：数据库、上传、下载都要落这个字段，
/// 用字符串到处比 'asset' 容易拼错，编译器也帮不上忙。
enum AudioSourceType {
  asset,
  file,
  remote;

  /// 从持久化字符串还原；未知值按 remote 处理，宁可当成在线也不误判成本地。
  static AudioSourceType fromName(String? value) {
    return AudioSourceType.values.firstWhere(
      (AudioSourceType type) => type.name == value,
      orElse: () => AudioSourceType.remote,
    );
  }

  bool get isLocal => this == AudioSourceType.asset || this == AudioSourceType.file;
}

/// 全局唯一的音频模型：本地 6 段、公共库、我的上传都用它。
///
/// 字段与宪法一一对应，后端阶段直接复用，不允许再加平行模型。
class AudioItem {
  const AudioItem({
    required this.id,
    required this.title,
    required this.category,
    required this.sourceType,
    this.description = '',
    this.assetPath,
    this.filePath,
    this.fileUrl,
    this.durationSec = 0,
    this.fileSize = 0,
    this.status = statusPending,
    this.rejectReason,
    this.isFavorite = false,
  })  : assert(
          status >= statusPending && status <= statusRejected,
          'status 只能是 0 审核中 / 1 上架 / 2 驳回',
        );

  /// 内置音景专用：sourceType 固定 asset，状态一定是已上架。
  ///
  /// 为什么单独给一个命名构造：默认构造的 status 是“审核中”，
  /// 上传记录如果忘了写状态会停留在审核中，绝不会被误当成已上架。
  const AudioItem.builtIn({
    required this.id,
    required this.title,
    required this.category,
    this.description = '',
    this.assetPath,
    this.durationSec = 0,
    this.fileSize = 0,
  })  : sourceType = AudioSourceType.asset,
        filePath = null,
        fileUrl = null,
        status = statusPublished,
        rejectReason = null,
        isFavorite = false;

  // 审核状态：0 审核中 / 1 上架 / 2 驳回。
  static const int statusPending = 0;
  static const int statusPublished = 1;
  static const int statusRejected = 2;

  final String id;
  final String title;
  final String category;
  final String description;
  final AudioSourceType sourceType;

  /// sourceType=asset 时使用。
  final String? assetPath;

  /// sourceType=file 时使用；下载完成后也写这里。
  final String? filePath;

  /// sourceType=remote 时使用；本阶段不发请求。
  final String? fileUrl;

  final int durationSec;
  final int fileSize;

  /// 审核状态：默认 0 审核中；只有内置音景（AudioItem.builtIn）才是 1 上架。
  final int status;
  final String? rejectReason;
  final bool isFavorite;

  /// 本地可播：asset 有路径，或 file 有落盘路径。
  bool get playableOffline {
    return switch (sourceType) {
      AudioSourceType.asset => (assetPath ?? '').isNotEmpty,
      AudioSourceType.file => (filePath ?? '').isNotEmpty,
      AudioSourceType.remote => (filePath ?? '').isNotEmpty,
    };
  }

  /// 只有已上架的音频能进入播放/公共列表。
  bool get isAvailable => status == statusPublished;

  AudioItem copyWith({
    String? title,
    String? category,
    String? description,
    AudioSourceType? sourceType,
    String? assetPath,
    String? filePath,
    String? fileUrl,
    int? durationSec,
    int? fileSize,
    int? status,
    String? rejectReason,
    bool? isFavorite,
  }) {
    return AudioItem(
      id: id,
      title: title ?? this.title,
      category: category ?? this.category,
      description: description ?? this.description,
      sourceType: sourceType ?? this.sourceType,
      assetPath: assetPath ?? this.assetPath,
      filePath: filePath ?? this.filePath,
      fileUrl: fileUrl ?? this.fileUrl,
      durationSec: durationSec ?? this.durationSec,
      fileSize: fileSize ?? this.fileSize,
      status: status ?? this.status,
      rejectReason: rejectReason ?? this.rejectReason,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  /// 持久化映射：键名与 downloads / my_uploads 的列名一致，布尔存 0/1。
  ///
  /// 为什么模型自己负责序列化：下载缓存、收藏列表都可能整条存进 prefs，
  /// 序列化规则集中在这里，以后端字段调整时只改一处。
  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'title': title,
      'category': category,
      'description': description,
      'source_type': sourceType.name,
      'asset_path': assetPath,
      'file_path': filePath,
      'file_url': fileUrl,
      'duration_sec': durationSec,
      'file_size': fileSize,
      'status': status,
      'reject_reason': rejectReason,
      'is_favorite': isFavorite ? 1 : 0,
    };
  }

  /// 从数据库/缓存映射还原；缺字段或脏状态一律回退到安全默认值。
  factory AudioItem.fromMap(Map<String, Object?> map) {
    final int rawStatus = _asInt(map['status'], fallback: statusPending);
    final int safeStatus =
        rawStatus >= statusPending && rawStatus <= statusRejected
            ? rawStatus
            : statusPending;
    return AudioItem(
      id: map['id']?.toString() ?? '',
      title: _asText(map['title']),
      category: _asText(map['category']),
      description: _asText(map['description']),
      sourceType: AudioSourceType.fromName(map['source_type']?.toString()),
      assetPath: _asNullableText(map['asset_path']),
      filePath: _asNullableText(map['file_path']),
      fileUrl: _asNullableText(map['file_url']),
      durationSec: _asInt(map['duration_sec']),
      fileSize: _asInt(map['file_size']),
      status: safeStatus,
      rejectReason: _asNullableText(map['reject_reason']),
      isFavorite: _asBool(map['is_favorite']),
    );
  }
}

int _asInt(Object? value, {int fallback = 0}) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value) ?? fallback;
  }
  return fallback;
}

bool _asBool(Object? value) {
  if (value is bool) {
    return value;
  }
  if (value is num) {
    return value != 0;
  }
  if (value is String) {
    return value == '1' || value.toLowerCase() == 'true';
  }
  return false;
}

String _asText(Object? value) => value?.toString() ?? '';

String? _asNullableText(Object? value) {
  final String text = value?.toString() ?? '';
  return text.isEmpty ? null : text;
}
