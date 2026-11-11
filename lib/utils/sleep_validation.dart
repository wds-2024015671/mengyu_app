/// 跨夜补记：起床时间不晚于入睡时，自动落到次日同一时刻。
DateTime normalizeWakeTime(DateTime bedTime, DateTime wakeTime) {
  if (wakeTime.isAfter(bedTime)) {
    return wakeTime;
  }
  return DateTime(
    wakeTime.year,
    wakeTime.month,
    wakeTime.day + 1,
    wakeTime.hour,
    wakeTime.minute,
  );
}

/// 补记睡眠的纯校验：起床必须晚于入睡，时长 1–16 小时。
///
/// 抽成纯函数是为了单测边界（59/60/960/961 分钟），页面只负责显示文案。
String? validateSleepRange(DateTime bedTime, DateTime wakeTime) {
  if (!wakeTime.isAfter(bedTime)) {
    return '起床时间要晚于入睡时间';
  }
  final int minutes = wakeTime.difference(bedTime).inMinutes;
  if (minutes < 60) {
    return '睡眠时长至少 1 小时';
  }
  if (minutes > 960) {
    return '睡眠时长不能超过 16 小时';
  }
  return null;
}
