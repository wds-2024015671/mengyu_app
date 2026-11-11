/// 纯展示格式化工具。
///
/// 放在 utils 而不是页面里：F03 的 Provider 与统计逻辑也要用，
/// 且这些函数不依赖 BuildContext，可以直接单测。
library;

/// 睡眠时长：65 → 「1 小时 5 分」；0 → 「0 分」。
String formatMinutes(int minutes) {
  if (minutes <= 0) {
    return '0 分';
  }
  final int hours = minutes ~/ 60;
  final int rest = minutes % 60;
  if (hours == 0) {
    return '$rest 分';
  }
  if (rest == 0) {
    return '$hours 小时';
  }
  return '$hours 小时 $rest 分';
}

/// 音频时间轴：75 → 「01:15」，超过一小时保留总分钟数。
String formatSeconds(int seconds) {
  final int safe = seconds < 0 ? 0 : seconds;
  final String minutes = (safe ~/ 60).toString().padLeft(2, '0');
  final String rest = (safe % 60).toString().padLeft(2, '0');
  return '$minutes:$rest';
}

/// 文件大小：0 → 「—」，1536 → 「2 KB」，2.5MB → 「2.5 MB」。
String formatFileSize(int bytes) {
  if (bytes <= 0) {
    return '—';
  }
  if (bytes < 1024) {
    return '$bytes B';
  }
  if (bytes < 1024 * 1024) {
    return '${(bytes / 1024).toStringAsFixed(0)} KB';
  }
  return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
}

/// 日期：2026-11-09 → 「11 月 9 日」。
String formatMonthDay(DateTime date) => '${date.month} 月 ${date.day} 日';

/// 时间：07:05。
String formatClock(DateTime time) {
  final String hour = time.hour.toString().padLeft(2, '0');
  final String minute = time.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

/// 数据库日期键：2026-11-09。
///
/// 用字符串存日期而不是时间戳：SQLite 没有 DATE 类型，
/// 'yyyy-MM-dd' 既能直接比较大小，也方便 BETWEEN 查询。
String formatDateKey(DateTime date) {
  final String month = date.month.toString().padLeft(2, '0');
  final String day = date.day.toString().padLeft(2, '0');
  return '${date.year.toString().padLeft(4, '0')}-$month-$day';
}

/// 数据库时间戳：ISO8601（本地时区），同一天内可直接按字符串排序。
String formatTimestamp(DateTime time) => time.toIso8601String();

/// 解析日期键；坏数据返回 null，交给调用方决定如何兜底。
DateTime? parseDateKey(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }
  return DateTime.tryParse(value);
}

/// 解析 ISO 时间戳；坏数据返回 null。
DateTime? parseTimestamp(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }
  return DateTime.tryParse(value);
}

/// 首页问候：按小时切成五段，夜间不出现“早上好”。
///
/// 抽成纯函数而不是写在页面里，是为了能单测边界（5/11/14/18 点）。
String greetingForHour(int hour) {
  if (hour < 5) {
    return '夜里好';
  }
  if (hour < 11) {
    return '早上好';
  }
  if (hour < 14) {
    return '中午好';
  }
  if (hour < 18) {
    return '下午好';
  }
  return '晚上好';
}

