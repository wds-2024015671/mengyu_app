import '../models/sleep_session.dart';

/// 单日睡眠汇总：月迹柱状图的一格。
class SleepDayStat {
  const SleepDayStat({
    required this.date,
    required this.minutes,
    required this.sessionCount,
  });

  final DateTime date;
  final int minutes;
  final int sessionCount;

  bool get hasData => sessionCount > 0;
}

/// 本周（周一到周日）睡眠统计。
class SleepWeekStats {
  const SleepWeekStats({
    required this.days,
    required this.averageMinutes,
    required this.streakDays,
    required this.sessionCount,
  });

  /// 固定 7 项，周一在前；没记录的日期 minutes=0。
  final List<SleepDayStat> days;

  /// 只对“有记录的天”求平均，避免没睡的 5 天把均值拉低。
  final double averageMinutes;

  /// 含今天（若连续记录到昨天则从昨天起算），不受本周范围限制。
  final int streakDays;

  /// 本周记录条数，页面用它算“仪式次数”。
  final int sessionCount;

  bool get hasData => sessionCount > 0;
}

/// 去掉时分秒，只保留日期，作为 Map 的 key。
DateTime dayStart(DateTime time) => DateTime(time.year, time.month, time.day);

/// 加减天数时重新构造 DateTime，跨月/跨年由 DateTime 自己进位。
DateTime addDays(DateTime day, int days) =>
    DateTime(day.year, day.month, day.day + days);

/// 本周一 00:00。
DateTime weekStart(DateTime day) {
  final DateTime start = dayStart(day);
  return addDays(start, 1 - start.weekday);
}

/// 连续记录天数：同一晚多条记录只算一天。
///
/// 今天还没写日记时允许从昨天开始算（例如现在是早上，用户还没补记今晚），
/// 这样“连续 3 天”不会因为一天还没结束就断掉。
int calculateStreakDays(
  List<SleepSession> sessions, {
  required DateTime today,
}) {
  if (sessions.isEmpty) {
    return 0;
  }
  final Set<DateTime> recorded = <DateTime>{
    for (final SleepSession session in sessions) dayStart(session.date),
  };
  DateTime cursor = dayStart(today);
  if (!recorded.contains(cursor)) {
    cursor = addDays(cursor, -1);
  }
  int streak = 0;
  while (recorded.contains(cursor)) {
    streak++;
    cursor = addDays(cursor, -1);
  }
  return streak;
}

/// 平均时长：按记录条数平均；没有记录返回 0。
double averageMinutes(List<SleepSession> sessions) {
  if (sessions.isEmpty) {
    return 0;
  }
  int total = 0;
  for (final SleepSession session in sessions) {
    total += session.durationMin;
  }
  return total / sessions.length;
}

/// 生成一周统计；纯函数，方便单测，也避免 Provider 里堆计算逻辑。
SleepWeekStats buildSleepWeek(
  List<SleepSession> sessions, {
  required DateTime today,
}) {
  final DateTime start = weekStart(today);
  final DateTime end = addDays(start, 7);
  final List<DateTime> dates = <DateTime>[
    for (int i = 0; i < 7; i++) addDays(start, i),
  ];

  final Map<DateTime, int> minutesByDay = <DateTime, int>{};
  final Map<DateTime, int> countByDay = <DateTime, int>{};
  int weekMinutes = 0;
  int weekCount = 0;

  for (final SleepSession session in sessions) {
    final DateTime day = dayStart(session.date);
    minutesByDay[day] = (minutesByDay[day] ?? 0) + session.durationMin;
    countByDay[day] = (countByDay[day] ?? 0) + 1;
    if (!day.isBefore(start) && day.isBefore(end)) {
      weekMinutes += session.durationMin;
      weekCount++;
    }
  }

  final int daysWithData =
      dates.where((DateTime date) => (countByDay[date] ?? 0) > 0).length;

  return SleepWeekStats(
    days: dates
        .map(
          (DateTime date) => SleepDayStat(
            date: date,
            minutes: minutesByDay[date] ?? 0,
            sessionCount: countByDay[date] ?? 0,
          ),
        )
        .toList(growable: false),
    averageMinutes: daysWithData == 0 ? 0 : weekMinutes / daysWithData,
    streakDays: calculateStreakDays(sessions, today: today),
    sessionCount: weekCount,
  );
}
