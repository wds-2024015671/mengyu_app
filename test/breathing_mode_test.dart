import 'package:flutter_test/flutter_test.dart';
import 'package:mengyu_app/models/breathing_mode.dart';

void main() {
  test('三种呼吸预设与方块第四段时长', () {
    expect(BreathingMode.presets.length, 3);

    final BreathingMode fourSevenEight = BreathingMode.presets[0];
    expect(fourSevenEight.roundSec, 19);
    expect(fourSevenEight.totalSec, 76);
    expect(fourSevenEight.hasHoldAfterExhale, isFalse);

    final BreathingMode square = BreathingMode.presets[1];
    expect(square.roundSec, 16);
    expect(square.totalSec, 64);
    expect(square.holdAfterExhale, 4);
    expect(square.hasHoldAfterExhale, isTrue);

    final BreathingMode fourFourSix = BreathingMode.presets[2];
    expect(fourFourSix.roundSec, 14);
    expect(fourFourSix.totalSec, 70);
  });
}
