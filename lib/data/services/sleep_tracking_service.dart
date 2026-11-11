import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/sleep_settings.dart';
import '../../core/errors/app_exception.dart';
import '../../data/repositories/session_repository.dart';
import '../../data/repositories/sleep_tracking_repository.dart';
import '../../data/services/sleep_notification_service.dart';
import '../../models/sleep_session.dart';
import '../../models/sleep_tracking_record.dart';
import '../../utils/formatters.dart';
import '../../utils/sleep_night.dart';
/// 自动睡眠记录四环节：媒体/定时结束 → 持久化 → 晨间确认 → 写入统计。
///
/// 只存时间戳与状态，不跑整夜 Timer；页面被杀后靠 SQLite + prefs 恢复。
class SleepTrackingService {
  SleepTrackingService({
    required SleepTrackingRepository tracking,
    required SessionRepository sessions,
    required SleepNotificationService notifications,
    DateTime Function()? clock,
  })  : _tracking = tracking,
        _sessions = sessions,
        _notifications = notifications,
        _clock = clock ?? DateTime.now;
  static const String expectedEndKey = 'sleep.expected_end_at';
  static const String expectedMediaKey = 'sleep.expected_media_id';
  final SleepTrackingRepository _tracking;
  final SessionRepository _sessions;
  final SleepNotificationService _notifications;
  final DateTime Function() _clock;
  Future<void> initialize() => _notifications.initialize();
  void setOnNotificationTap(void Function()? callback) {
    _notifications.setOnTap(callback);
  }
  bool takeNotificationTap() => _notifications.takePendingTap();
  Future<bool> autoEnabled() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(kAutoSleepTrackingKey) ?? true;
  }
  Future<bool> reminderEnabled() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(kMorningReminderKey) ?? true;
  }
  Future<int> reminderMinutes() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int value =
        prefs.getInt(kReminderMinutesKey) ?? kDefaultReminderMinutes;
    return kReminderOptions.contains(value)
        ? value
        : kDefaultReminderMinutes;
  }
  Future<bool> requestNotificationPermission() =>
      _notifications.requestPermission();
  Future<bool> hasNotificationPermission() => _notifications.hasPermission();
  /// 播放开始时存预期结束时间，App 被杀也能按这里补记录。
  Future<void> notePlaybackExpectedEnd({
    required DateTime expectedEndAt,
    String? mediaId,
  }) async {
    if (!await autoEnabled()) {
      return;
    }
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(expectedEndKey, formatTimestamp(expectedEndAt));
    if (mediaId == null) {
      await prefs.remove(expectedMediaKey);
    } else {
      await prefs.setString(expectedMediaKey, mediaId);
    }
  }
  Future<SleepTrackingRecord?> startRecording({
    DateTime? at,
    String? mediaId,
  }) async {
    if (!await autoEnabled()) {
      return null;
    }
    final DateTime start = at ?? _clock();
    final String night = sleepNightKey(start);
    final SleepTrackingRecord? existing = await _tracking.byNight(night);
    if (existing != null && existing.status != SleepTrackingStatus.discarded) {
      return existing;
    }
    final SleepTrackingRecord record = SleepTrackingRecord(
      nightKey: night,
      startAt: start,
      expectedEndAt: await _expectedEnd() ?? start,
      status: SleepTrackingStatus.recording,
      mediaId: mediaId ?? await _expectedMedia(),
      createdAt: _clock(),
    );
    final SleepTrackingRecord saved = await _tracking.save(record);
    await _scheduleFor(saved);
    return saved;
  }
  /// 生命周期恢复/冷启动：补 pending、把 recording 推进到 pending。
  Future<SleepTrackingRecord?> checkOnResume() async {
    final DateTime now = _clock();
    SleepTrackingRecord? open = await _tracking.open();
    if (open == null) {
      final DateTime? expected = await _expectedEnd();
      if (expected != null &&
          now.isAfter(expected) &&
          now.difference(expected).inHours <= 24) {
        open = await startRecording(at: expected);
        if (open != null) {
          open = await _tracking.save(
            open.copyWith(status: SleepTrackingStatus.pending),
          );
          await _notifications.cancelMorning();
        }
      }
    }
    if (open == null) {
      return null;
    }
    if (open.status == SleepTrackingStatus.pending &&
        now.difference(open.startAt).inHours >= 24) {
      await discard(open);
      return null;
    }
    if (open.status == SleepTrackingStatus.recording) {
      final int minutes = await reminderMinutes();
      final DateTime promptAt = nextMorning(open.startAt, minutes: minutes);
      if (!now.isBefore(promptAt)) {
        open = await _tracking.save(
          open.copyWith(status: SleepTrackingStatus.pending),
        );
        await _notifications.cancelMorning();
      }
    }
    return open;
  }
  Future<SleepTrackingRecord?> pending() => _tracking.pending();
  Future<SleepTrackingRecord?> open() => _tracking.open();
  bool needsPrompt(SleepTrackingRecord record) {
    final String today = formatDateKey(_clock());
    return record.status == SleepTrackingStatus.pending &&
        record.promptDate != today;
  }
  Future<void> markPrompted(SleepTrackingRecord record) async {
    await _tracking.save(
      record.copyWith(promptDate: formatDateKey(_clock())),
    );
  }
  /// 设置开关/提醒时间变化后重排通知；pending 不再推送。
  Future<void> rescheduleReminder() async {
    try {
      final SleepTrackingRecord? open = await _tracking.open();
      if (open == null ||
          !await autoEnabled() ||
          !await reminderEnabled() ||
          open.status != SleepTrackingStatus.recording) {
        await _notifications.cancelMorning();
        return;
      }
      await _scheduleFor(open);
    } catch (_) {
      // 设置保存不应被通知失败阻塞。
    }
  }
  Future<bool> confirm(
    SleepTrackingRecord record, {
    DateTime? endAt,
  }) async {
    final DateTime end = endAt ?? _clock();
    DateTime start = record.startAt;
    if (!end.isAfter(start)) {
      throw const AppException('起床时间要晚于入睡时间');
    }
    if (end.difference(start).inHours > 24) {
      start = end.subtract(const Duration(hours: 24));
    }
    final List<SleepSession> all = await _sessions.all();
    final SleepSession? existing = all
        .where((SleepSession item) => item.nightKey == record.nightKey)
        .firstOrNull;
    final SleepSession merged = SleepSession(
      id: existing?.id,
      bedTime: existing != null && existing.bedTime.isBefore(start)
          ? existing.bedTime
          : start,
      wakeTime: existing != null && existing.wakeTime.isAfter(end)
          ? existing.wakeTime
          : end,
      quality: existing?.quality ?? 3,
      note: existing?.note.isNotEmpty == true ? existing!.note : '自动记录',
      source: existing?.source ?? SleepSource.auto,
      nightKeyValue: record.nightKey,
    );
    final SleepSession saved = await _sessions.save(merged);
    await _tracking.save(
      record.copyWith(
        status: SleepTrackingStatus.confirmed,
        endAt: end,
        confirmedAt: _clock(),
        sessionId: saved.id,
      ),
    );
    await _notifications.cancelMorning();
    await _clearExpected();
    return true;
  }
  Future<void> discard(SleepTrackingRecord record) async {
    await _tracking.save(
      record.copyWith(
        status: SleepTrackingStatus.discarded,
        endAt: _clock(),
      ),
    );
    await _notifications.cancelMorning();
    await _clearExpected();
  }

  /// 手动停止且用户选择“不记录”时，清掉预期结束，避免下次启动补一条。
  Future<void> clearExpected() => _clearExpected();
  Future<void> _scheduleFor(SleepTrackingRecord record) async {
    try {
      if (!await reminderEnabled()) {
        await _notifications.cancelMorning();
        return;
      }
      final int minutes = await reminderMinutes();
      await _notifications.scheduleMorning(
        nextMorning(record.startAt, minutes: minutes),
      );
    } catch (_) {
      // 权限被拒或通知不可用时只走 3A，自动记录本身仍然保留。
    }
  }
  Future<DateTime?> _expectedEnd() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(expectedEndKey);
    return parseTimestamp(raw);
  }
  Future<String?> _expectedMedia() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(expectedMediaKey);
  }
  Future<void> _clearExpected() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(expectedEndKey);
    await prefs.remove(expectedMediaKey);
  }
}
