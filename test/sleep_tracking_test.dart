import 'package:flutter_test/flutter_test.dart';
import 'package:mengyu_app/data/services/sleep_tracking_service.dart';
import 'package:mengyu_app/models/sleep_session.dart';
import 'package:mengyu_app/models/sleep_tracking_record.dart';
import 'package:mengyu_app/utils/sleep_night.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fake_session_repository.dart';
import 'support/fake_sleep_tracking.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('自动记录：定时结束 → recording → pending → confirmed', () async {
    DateTime now = DateTime(2026, 11, 10, 23);
    final FakeSleepTrackingRepository tracking = FakeSleepTrackingRepository();
    final FakeSessionRepository sessions = FakeSessionRepository();
    final FakeSleepNotificationService notifications =
        FakeSleepNotificationService();
    final SleepTrackingService service = SleepTrackingService(
      tracking: tracking,
      sessions: sessions,
      notifications: notifications,
      clock: () => now,
    );

    await service.notePlaybackExpectedEnd(
      expectedEndAt: DateTime(2026, 11, 11, 7),
      mediaId: 'rain',
    );
    final SleepTrackingRecord? recording = await service.startRecording();
    expect(recording?.status, SleepTrackingStatus.recording);
    expect(recording?.startAt, DateTime(2026, 11, 10, 23));
    expect(notifications.scheduled, isTrue);

    now = DateTime(2026, 11, 11, 7, 31);
    final SleepTrackingRecord? pending = await service.checkOnResume();
    expect(pending?.status, SleepTrackingStatus.pending);
    expect(notifications.scheduled, isFalse);
    expect(service.needsPrompt(pending!), isTrue);

    final bool ok = await service.confirm(
      pending,
      endAt: DateTime(2026, 11, 11, 7, 30),
    );
    expect(ok, isTrue);
    expect(sessions.saved.length, 1);
    final SleepSession saved = sessions.saved.single;
    expect(saved.source, SleepSource.auto);
    expect(saved.nightKey, '2026-11-10');
    expect(saved.durationMin, 510);
    expect(tracking.records.values.single.status, SleepTrackingStatus.confirmed);
    expect(notifications.scheduled, isFalse);
  });

  test('App 被杀：预期结束时间到了 → 从预期时刻补 pending', () async {
    DateTime now = DateTime(2026, 11, 10, 23);
    final FakeSleepTrackingRepository tracking = FakeSleepTrackingRepository();
    final FakeSleepNotificationService notifications =
        FakeSleepNotificationService();
    final SleepTrackingService service = SleepTrackingService(
      tracking: tracking,
      sessions: FakeSessionRepository(),
      notifications: notifications,
      clock: () => now,
    );

    await service.notePlaybackExpectedEnd(
      expectedEndAt: DateTime(2026, 11, 11, 7),
    );
    now = DateTime(2026, 11, 11, 8);
    final SleepTrackingRecord? pending = await service.checkOnResume();

    expect(pending, isNotNull);
    expect(pending!.status, SleepTrackingStatus.pending);
    expect(pending.startAt, DateTime(2026, 11, 11, 7));
  });

  test('丢弃：不写入 sleep_sessions，且取消通知', () async {
    DateTime now = DateTime(2026, 11, 10, 23);
    final FakeSleepTrackingRepository tracking = FakeSleepTrackingRepository();
    final FakeSessionRepository sessions = FakeSessionRepository();
    final FakeSleepNotificationService notifications =
        FakeSleepNotificationService();
    final SleepTrackingService service = SleepTrackingService(
      tracking: tracking,
      sessions: sessions,
      notifications: notifications,
      clock: () => now,
    );
    final SleepTrackingRecord? record = await service.startRecording();
    now = DateTime(2026, 11, 11, 7, 31);
    final SleepTrackingRecord pending = (await service.checkOnResume())!;
    await service.discard(pending);

    expect(sessions.saved, isEmpty);
    expect(notifications.scheduled, isFalse);
    expect(record, isNotNull);
    expect(tracking.records.values.single.status, SleepTrackingStatus.discarded);
  });

  test('晨间时间跨夜：23 点开始 → 次日 07:30', () {
    expect(
      nextMorning(DateTime(2026, 11, 10, 23)),
      DateTime(2026, 11, 11, 7, 30),
    );
    expect(
      nextMorning(DateTime(2026, 11, 11, 1)),
      DateTime(2026, 11, 11, 7, 30),
    );
    expect(sleepNightKey(DateTime(2026, 12, 31, 23)), '2026-12-31');
    expect(sleepNightKey(DateTime(2027, 1, 1, 1)), '2026-12-31');
    expect(sleepNightKey(DateTime(2026, 11, 10, 17, 59)), '2026-11-09');
    expect(sleepNightKey(DateTime(2026, 11, 10, 18)), '2026-11-10');
  });

  test('自动记录入库：UTC 时间往返后仍是本地同一时刻', () {
    final SleepTrackingRecord record = SleepTrackingRecord(
      id: 1,
      nightKey: '2026-11-10',
      startAt: DateTime(2026, 11, 10, 23),
      status: SleepTrackingStatus.pending,
      promptDate: '2026-11-11',
    );
    final SleepTrackingRecord restored =
        SleepTrackingRecord.fromMap(record.toMap()..['id'] = 1);
    expect(restored.startAt, record.startAt);
    expect(restored.nightKey, '2026-11-10');
    expect(restored.status, SleepTrackingStatus.pending);
  });

  test('提醒去重：当天提示过，次日才再次提示', () async {    DateTime now = DateTime(2026, 11, 11, 7, 31);
    final FakeSleepTrackingRepository tracking = FakeSleepTrackingRepository(
      SleepTrackingRecord(
        id: 1,
        nightKey: '2026-11-10',
        startAt: DateTime(2026, 11, 10, 23),
        status: SleepTrackingStatus.pending,
      ),
    );
    final SleepTrackingService service = SleepTrackingService(
      tracking: tracking,
      sessions: FakeSessionRepository(),
      notifications: FakeSleepNotificationService(),
      clock: () => now,
    );
    final SleepTrackingRecord pending = (await service.checkOnResume())!;
    expect(service.needsPrompt(pending), isTrue);
    await service.markPrompted(pending);
    expect(service.needsPrompt(tracking.records.values.single), isFalse);
    now = DateTime(2026, 11, 12, 7, 31);
    expect(service.needsPrompt(tracking.records.values.single), isTrue);
  });

  test('重复确认 / 同日手动记录：只保留一条', () async {    DateTime now = DateTime(2026, 11, 10, 23);
    final FakeSleepTrackingRepository tracking = FakeSleepTrackingRepository();
    final FakeSessionRepository sessions = FakeSessionRepository(
      <SleepSession>[
        SleepSession(
          id: 1,
          bedTime: DateTime(2026, 11, 10, 22),
          wakeTime: DateTime(2026, 11, 11, 7),
          quality: 4,
          note: '手动补记',
        ),
      ],
    );
    final SleepTrackingService service = SleepTrackingService(
      tracking: tracking,
      sessions: sessions,
      notifications: FakeSleepNotificationService(),
      clock: () => now,
    );
    final SleepTrackingRecord? record = await service.startRecording();
    now = DateTime(2026, 11, 11, 7, 31);
    final SleepTrackingRecord pending = (await service.checkOnResume())!;
    await service.confirm(pending);
    await service.confirm(pending);

    expect(sessions.saved.length, 1);
    expect(sessions.saved.single.note, '手动补记');
    expect(sessions.saved.single.source, SleepSource.manual);
    expect(record, isNotNull);
  });
}
