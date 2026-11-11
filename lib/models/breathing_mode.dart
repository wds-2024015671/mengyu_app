/// 呼吸训练模式。
///
/// 字段按 F09 约定：name / inhale / hold / exhale / cycles（秒、轮次）。
/// 方块呼吸需要在呼气后再屏息一次，因此额外记一个 [holdAfterExhale]；
/// 其余模式该值为 0，进行页按 3 段或 4 段播放即可。
class BreathingMode {
  const BreathingMode({
    required this.name,
    required this.description,
    required this.inhale,
    required this.hold,
    required this.exhale,
    required this.cycles,
    this.holdAfterExhale = 0,
  });

  final String name;
  final String description;
  final int inhale;
  final int hold;
  final int exhale;
  final int cycles;

  /// 呼气后的屏息秒数；方块呼吸为 4，其余为 0。
  final int holdAfterExhale;

  bool get hasHoldAfterExhale => holdAfterExhale > 0;

  /// 整轮秒数（方块呼吸包含第四段屏息）。
  int get roundSec => inhale + hold + exhale + holdAfterExhale;

  int get totalSec => roundSec * cycles;

  /// 三种内置模式；选择页直接遍历，避免在页面里硬编码参数。
  static const List<BreathingMode> presets = <BreathingMode>[
    BreathingMode(
      name: '4-7-8 呼吸',
      description: '吸气 4 秒 · 屏息 7 秒 · 呼气 8 秒',
      inhale: 4,
      hold: 7,
      exhale: 8,
      cycles: 4,
    ),
    BreathingMode(
      name: '方块呼吸',
      description: '吸气 4 秒 · 屏息 4 秒 · 呼气 4 秒 · 再屏息 4 秒',
      inhale: 4,
      hold: 4,
      exhale: 4,
      cycles: 4,
      holdAfterExhale: 4,
    ),
    BreathingMode(
      name: '4-4-6 呼吸',
      description: '呼气略长，帮助心率回落',
      inhale: 4,
      hold: 4,
      exhale: 6,
      cycles: 5,
    ),
  ];
}
