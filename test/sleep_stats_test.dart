import 'package:flutter_test/flutter_test.dart';
import 'package:mengyu_app/models/sleep_session.dart';
import 'package:mengyu_app/utils/formatters.dart';
import 'package:mengyu_app/utils/sleep_stats.dart';

SleepSession _session(DateTime bed, int minutes) {
  return SleepSession(
    bedTime: bed,
    wakeTime: bed.add(Duration(minutes: minutes)),
    quality: 3,
  );
}

void main() {
  final DateTime today = DateTime(2026, 11, 9); // 周一

  group('连续天数', () {
    test('空列表为 0', () {
      expect(calculateStreakDays(const <SleepSession>[], today: today), 0);
    });

    test('连续 3 天（含今天）为 3，同一天多条只算一天', () {
      final List<SleepSession> sessions = <SleepSession>[
        _session(DateTime(2026, 11, 7, 23), 480),
        _session(DateTime(2026, 11, 8, 23), 450),
        _session(DateTime(2026, 11, 9, 23), 480),
        _session(DateTime(2026, 11, 9, 1), 120),
      ];
      expect(calculateStreakDays(sessions, today: today), 3);
    });

    test('今天还没记录时从昨天开始算', () {
      final List<SleepSession> sessions = <SleepSession>[
        _session(DateTime(2026, 11, 7, 23), 480),
        _session(DateTime(2026, 11, 8, 23), 450),
      ];
      expect(calculateStreakDays(sessions, today: today), 2);
    });

    test('中间断一天就停', () {
      final List<SleepSession> sessions = <SleepSession>[
        _session(DateTime(2026, 11, 5, 23), 480),
        _session(DateTime(2026, 11, 6, 23), 480),
        _session(DateTime(2026, 11, 8, 23), 450),
        _session(DateTime(2026, 11, 9, 23), 480),
      ];
      expect(calculateStreakDays(sessions, today: today), 2);
    });
  });

  group('本周统计', () {
    test('周一为起点，7 天数据与平均时长正确', () {
      final List<SleepSession> sessions = <SleepSession>[
        _session(DateTime(2026, 11, 7, 23), 480), // 上周六
        _session(DateTime(2026, 11, 8, 23), 450), // 上周日
        _session(DateTime(2026, 11, 9, 23), 480), // 本周一
        _session(DateTime(2026, 11, 9, 1), 120), // 本周一凌晨
      ];
      final SleepWeekStats stats = buildSleepWeek(sessions, today: today);

      expect(stats.days.length, 7);
      expect(formatDateKey(stats.days.first.date), '2026-11-09');
      expect(formatDateKey(stats.days.last.date), '2026-11-15');
      expect(stats.days.first.minutes, 600);
      expect(stats.days.first.sessionCount, 2);
      expect(stats.days[1].hasData, isFalse);
      // 本周只有一天有记录，平均值就是那天的 600 分钟。
      expect(stats.averageMinutes, 600);
      expect(stats.sessionCount, 2);
      expect(stats.streakDays, 3);
      expect(stats.hasData, isTrue);
    });

    test('只有上周记录时本周为空，但连续天数仍从昨天算', () {
      final List<SleepSession> sessions = <SleepSession>[
        _session(DateTime(2026, 11, 8, 23), 450),
      ];
      final SleepWeekStats stats = buildSleepWeek(sessions, today: today);

      expect(stats.hasData, isFalse);
      expect(stats.sessionCount, 0);
      expect(stats.averageMinutes, 0);
      expect(stats.days.every((SleepDayStat day) => day.minutes == 0), isTrue);
      expect(stats.streakDays, 1);
    });

    test('平均时长按记录条数计算', () {
      final List<SleepSession> sessions = <SleepSession>[
        _session(DateTime(2026, 11, 9, 23), 420),
        _session(DateTime(2026, 11, 10, 23), 480),
        _session(DateTime(2026, 11, 11, 23), 360),
      ];
      expect(averageMinutes(sessions), 420);
    });
  });

  test('weekStart 始终回到周一', () {
    expect(formatDateKey(weekStart(DateTime(2026, 11, 9))), '2026-11-09');
    expect(formatDateKey(weekStart(DateTime(2026, 11, 15))), '2026-11-09');
    expect(formatDateKey(weekStart(DateTime(2026, 11, 16))), '2026-11-16');
  });
}
