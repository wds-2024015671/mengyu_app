import 'package:flutter_test/flutter_test.dart';
import 'package:mengyu_app/utils/formatters.dart';

void main() {
  test('睡眠时长格式化', () {
    expect(formatMinutes(0), '0 分');
    expect(formatMinutes(-5), '0 分');
    expect(formatMinutes(45), '45 分');
    expect(formatMinutes(60), '1 小时');
    expect(formatMinutes(65), '1 小时 5 分');
    expect(formatMinutes(1440), '24 小时');
  });

  test('音频时间轴格式化', () {
    expect(formatSeconds(0), '00:00');
    expect(formatSeconds(75), '01:15');
    expect(formatSeconds(-1), '00:00');
    expect(formatSeconds(3600), '60:00');
  });

  test('数据库日期键补零且可解析', () {
    expect(formatDateKey(DateTime(2026, 1, 5)), '2026-01-05');
    expect(parseDateKey('2026-01-05'), DateTime(2026, 1, 5));
    expect(parseDateKey('bad'), isNull);
    expect(parseTimestamp('bad'), isNull);
  });

  test('首页问候按时段切换', () {
    expect(greetingForHour(3), '夜里好');
    expect(greetingForHour(5), '早上好');
    expect(greetingForHour(8), '早上好');
    expect(greetingForHour(11), '中午好');
    expect(greetingForHour(15), '下午好');
    expect(greetingForHour(18), '晚上好');
    expect(greetingForHour(23), '晚上好');
  });

  test('文件大小格式化', () {
    expect(formatFileSize(0), '—');
    expect(formatFileSize(512), '512 B');
    expect(formatFileSize(2048), '2 KB');
    expect(formatFileSize(3 * 1024 * 1024), '3.0 MB');
  });
}
