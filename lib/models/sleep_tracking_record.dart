import '../utils/formatters.dart';
import '../utils/sleep_night.dart';

enum SleepTrackingStatus { recording, pending, confirmed, discarded }

/// 自动睡眠记录状态机：recording → pending → confirmed / discarded。
///
/// 只存时间戳与状态，不跑整夜 Timer；跨夜/重启后都能从这张表恢复。
class SleepTrackingRecord {
  const SleepTrackingRecord({
    required this.nightKey,
    required this.startAt,
    required this.status,
    this.id,
    this.expectedEndAt,
    this.endAt,
    this.mediaId,
    this.promptDate,
    this.createdAt,
    this.confirmedAt,
    this.sessionId,
  });

  final int? id;
  final String nightKey;
  final DateTime startAt;
  final DateTime? expectedEndAt;
  final DateTime? endAt;
  final SleepTrackingStatus status;
  final String? mediaId;
  final String? promptDate;
  final DateTime? createdAt;
  final DateTime? confirmedAt;
  final int? sessionId;

  bool get isOpen =>
      status == SleepTrackingStatus.recording ||
      status == SleepTrackingStatus.pending;

  int durationMinAt(DateTime end) {
    final int minutes = end.difference(startAt).inMinutes;
    if (minutes <= 0) {
      return 0;
    }
    return minutes > 24 * 60 ? 24 * 60 : minutes;
  }

  SleepTrackingRecord copyWith({
    int? id,
    String? nightKey,
    DateTime? startAt,
    DateTime? expectedEndAt,
    DateTime? endAt,
    SleepTrackingStatus? status,
    String? mediaId,
    String? promptDate,
    DateTime? createdAt,
    DateTime? confirmedAt,
    int? sessionId,
  }) {
    return SleepTrackingRecord(
      id: id ?? this.id,
      nightKey: nightKey ?? this.nightKey,
      startAt: startAt ?? this.startAt,
      expectedEndAt: expectedEndAt ?? this.expectedEndAt,
      endAt: endAt ?? this.endAt,
      status: status ?? this.status,
      mediaId: mediaId ?? this.mediaId,
      promptDate: promptDate ?? this.promptDate,
      createdAt: createdAt ?? this.createdAt,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      sessionId: sessionId ?? this.sessionId,
    );
  }

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'night_key': nightKey,
      'start_at': formatTimestamp(startAt.toUtc()),
      'expected_end_at': expectedEndAt == null
          ? null
          : formatTimestamp(expectedEndAt!.toUtc()),
      'end_at': endAt == null ? null : formatTimestamp(endAt!.toUtc()),
      'status': status.name,
      'media_id': mediaId,
      'prompt_date': promptDate,
      'created_at': formatTimestamp(createdAt ?? DateTime.now()),
      'confirmed_at':
          confirmedAt == null ? null : formatTimestamp(confirmedAt!),
      'session_id': sessionId,
    };
  }

  factory SleepTrackingRecord.fromMap(Map<String, Object?> map) {
    final DateTime? start = parseTimestamp(map['start_at']?.toString());
    if (start == null) {
      throw FormatException('自动记录缺少 start_at：$map');
    }
    final String night = map['night_key']?.toString() ?? sleepNightKey(start);
    return SleepTrackingRecord(
      id: (map['id'] as num?)?.toInt(),
      nightKey: night,
      startAt: start.toLocal(),
      expectedEndAt:
          parseTimestamp(map['expected_end_at']?.toString())?.toLocal(),
      endAt: parseTimestamp(map['end_at']?.toString())?.toLocal(),
      status: SleepTrackingStatus.values.firstWhere(
        (SleepTrackingStatus value) => value.name == map['status'],
        orElse: () => SleepTrackingStatus.pending,
      ),
      mediaId: map['media_id']?.toString(),
      promptDate: map['prompt_date']?.toString(),
      createdAt: parseTimestamp(map['created_at']?.toString())?.toLocal(),
      confirmedAt: parseTimestamp(map['confirmed_at']?.toString())?.toLocal(),
      sessionId: (map['session_id'] as num?)?.toInt(),
    );
  }
}
