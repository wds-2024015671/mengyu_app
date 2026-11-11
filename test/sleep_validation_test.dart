import 'package:flutter_test/flutter_test.dart';
import 'package:mengyu_app/utils/sleep_validation.dart';

void main() {
  test('补记睡眠：起床晚于入睡，时长 1–16 小时边界', () {
    final DateTime bed = DateTime(2026, 11, 8, 23);

    expect(validateSleepRange(bed, bed), '起床时间要晚于入睡时间');
    expect(
      validateSleepRange(bed, bed.subtract(const Duration(minutes: 1))),
      '起床时间要晚于入睡时间',
    );

    expect(
      validateSleepRange(bed, bed.add(const Duration(minutes: 59))),
      '睡眠时长至少 1 小时',
    );
    expect(
      validateSleepRange(bed, bed.add(const Duration(minutes: 60))),
      isNull,
    );
    expect(
      validateSleepRange(bed, bed.add(const Duration(hours: 16))),
      isNull,
    );
    expect(
      validateSleepRange(bed, bed.add(const Duration(hours: 16, minutes: 1))),
      '睡眠时长不能超过 16 小时',
    );
  });

  test('跨夜：起床早于入睡时自动落到次日', () {
    final DateTime bed = DateTime(2026, 11, 8, 23);
    final DateTime wake = DateTime(2026, 11, 9, 7);
    expect(normalizeWakeTime(bed, DateTime(2026, 11, 8, 7)), wake);
    expect(normalizeWakeTime(bed, wake), wake);
  });
}
