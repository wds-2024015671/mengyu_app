import 'package:mengyu_app/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../models/breathing_mode.dart';
import '../../widgets/app_background.dart';
import '../../widgets/glass_card.dart';

/// 呼吸选择页：三种节奏，点击后带 BreathingMode 进进行页。
///
/// 为什么参数直接传对象：模式只有 3 个且字段稳定，传对象比传 id
/// 少一次查表，也不用给路由加字符串解析。
class BreathingPage extends StatelessWidget {
  const BreathingPage({super.key});

  Future<void> _start(BuildContext context, BreathingMode mode) async {
    final int? completed = await Navigator.pushNamed<int?>(
      context,
      AppRoutes.breathingSession,
      arguments: mode,
    );
    if (!context.mounted || completed == null) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('完成 $completed 轮呼吸')),
    );
  }

  @override
  Widget build(BuildContext context) {
    const List<IconData> icons = <IconData>[
      Icons.air,
      Icons.crop_square,
      Icons.waves,
    ];
    return Scaffold(
      backgroundColor: context.c.bgDeep,
      appBar: AppBar(title: const Text('呼吸')),
      body: AppBackground(
        tint: context.c.tintSound,
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.page,
              AppSpacing.lg,
              AppSpacing.page,
              AppSpacing.xxl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const _BreathingIntro(),
                const SizedBox(height: AppSpacing.xl),
                for (int i = 0; i < BreathingMode.presets.length; i++) ...<Widget>[
                  _BreathingModeCard(
                    mode: BreathingMode.presets[i],
                    icon: icons[i],
                    onTap: () => _start(context, BreathingMode.presets[i]),
                  ),
                  if (i < BreathingMode.presets.length - 1)
                    const SizedBox(height: AppSpacing.md),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BreathingModeCard extends StatelessWidget {
  const _BreathingModeCard({
    required this.mode,
    required this.icon,
    required this.onTap,
  });

  final BreathingMode mode;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      outlined: true,
      child: Row(
        children: <Widget>[
          Icon(icon, color: context.c.secondary, size: 20),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(mode.name, style: context.s.subtitle),
                const SizedBox(height: AppSpacing.xs),
                Text(mode.description, style: context.s.caption),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${mode.cycles} 轮 · 约 ${mode.totalSec} 秒',
                  style: context.s.captionMuted,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Icon(
            Icons.chevron_right,
            size: 16,
            color: context.c.textTertiary,
          ),
        ],
      ),
    );
  }
}

class _BreathingIntro extends StatelessWidget {
  const _BreathingIntro();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Icon(Icons.self_improvement, color: context.c.secondary, size: 24),
        const SizedBox(height: AppSpacing.md),
        Text(
          '三种节奏，把注意力从思绪里捞回来。',
          textAlign: TextAlign.center,
          style: context.s.subtitle,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          '建议坐直、用鼻子吸气；感到头晕就停下来，不用勉强完成全部轮次。',
          textAlign: TextAlign.center,
          style: context.s.captionMuted,
        ),
      ],
    );
  }
}
