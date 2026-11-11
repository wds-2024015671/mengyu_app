import '../utils/formatters.dart';
import '../utils/sleep_night.dart';

/// 记录来源：手动补记 / 媒体或定时结束后的自动记录。
enum SleepSource { manual, auto }

/// 一条睡眠记录（手工补记或自动确认）。
///
/// 时长不单独存字段：由 bedTime / wakeTime 推导，避免两处数据打架；
/// 数据库层仍会落 duration_min 方便按月统计。
class SleepSession {
  const SleepSession({
    required this.bedTime,
    required this.wakeTime,
    required this.quality,
    this.id,
    this.note = '',
    this.source = SleepSource.manual,
    this.nightKeyValue,
  });

  final int? id;
  final DateTime bedTime;
  final DateTime wakeTime;

  /// 主观评分 1~5。
  final int quality;
  final String note;
  final SleepSource source;
  final String? nightKeyValue;

  String get nightKey => nightKeyValue ?? sleepNightKey(bedTime);

  /// 分钟数；跨零点由 wakeTime 落到次日来保证为正。
  int get durationMin => wakeTime.difference(bedTime).inMinutes;

  /// 记录归属日期：按入睡日期归属（凌晨 00:30 入睡算当天，不做跨夜偏移）。
  /// 补记页如果选“昨晚”，由页面把 bedTime 落在昨天即可。
  DateTime get date => DateTime(bedTime.year, bedTime.month, bedTime.day);

  /// 补记校验：起床必须晚于入睡，时长 1~16 小时。
  bool get isValid {
    final int minutes = durationMin;
    return !wakeTime.isBefore(bedTime) && minutes >= 60 && minutes <= 960;
  }

  SleepSession copyWith({
    int? id,
    DateTime? bedTime,
    DateTime? wakeTime,
    int? quality,
    String? note,
    SleepSource? source,
    String? nightKeyValue,
  }) {
    return SleepSession(
      id: id ?? this.id,
      bedTime: bedTime ?? this.bedTime,
      wakeTime: wakeTime ?? this.wakeTime,
      quality: quality ?? this.quality,
      note: note ?? this.note,
      source: source ?? this.source,
      nightKeyValue: nightKeyValue ?? this.nightKeyValue,
    );
  }

  /// 写库映射：created_at 由 DAO 插入时补，更新时不覆盖。
  Map<String, Object?> toMap() {
    return <String, Object?>{
      'bed_time': formatTimestamp(bedTime.toUtc()),
      'wake_time': formatTimestamp(wakeTime.toUtc()),
      'duration_min': durationMin,
      'quality': quality,
      'note': note,
      'sleep_date': formatDateKey(date),
      'source': source.name,
      'night_key': nightKey,
    };
  }

  /// 从数据库行还原；时间字段缺失属于脏数据，直接抛错让 Provider 显示失败态。
  factory SleepSession.fromMap(Map<String, Object?> map) {
    final DateTime? bed = parseTimestamp(map['bed_time']?.toString());
    final DateTime? wake = parseTimestamp(map['wake_time']?.toString());
    if (bed == null || wake == null) {
      throw FormatException('睡眠记录缺少 bed_time / wake_time：$map');
    }
    return SleepSession(
      id: (map['id'] as num?)?.toInt(),
      bedTime: bed.toLocal(),
      wakeTime: wake.toLocal(),
      quality: ((map['quality'] as num?)?.toInt() ?? 3).clamp(1, 5).toInt(),
      note: map['note']?.toString() ?? '',
      source: SleepSource.values.firstWhere(
        (SleepSource value) => value.name == map['source'],
        orElse: () => SleepSource.manual,
      ),
      nightKeyValue: map['night_key']?.toString(),
    );
  }
}
