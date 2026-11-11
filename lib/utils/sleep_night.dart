import 'formatters.dart';

/// 睡眠归属夜：18:00 之后算当晚，凌晨到 18:00 前算前一晚。
String sleepNightKey(DateTime at) {
  final DateTime local = at.toLocal();
  final DateTime night = local.hour >= 18
      ? local
      : local.subtract(const Duration(days: 1));
  return formatDateKey(night);
}

DateTime sleepNightDate(String key) {
  final DateTime? parsed = parseDateKey(key);
  return parsed ?? DateTime.now();
}

/// 晨间确认时间：默认 07:30；若从凌晨才开始记录，仍落到当天早上。
DateTime nextMorning(DateTime start, {int minutes = 450}) {
  final DateTime local = start.toLocal();
  DateTime prompt = DateTime(
    local.year,
    local.month,
    local.day,
    minutes ~/ 60,
    minutes % 60,
  );
  if (!prompt.isAfter(local.add(const Duration(hours: 4)))) {
    prompt = prompt.add(const Duration(days: 1));
  }
  return prompt;
}
