import 'package:mengyu_app/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// v7 呼吸圆环：lav 描边，阶段 20/600，秒数与轮次 11 t3。
class BreathingCircle extends StatelessWidget {
  const BreathingCircle({
    super.key,
    required this.scale,
    required this.phaseLabel,
    required this.seconds,
    required this.cycle,
    required this.cycles,
  });

  final double scale;
  final String phaseLabel;
  final int seconds;
  final int cycle;
  final int cycles;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      height: 260,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Transform.scale(
            scale: scale,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: context.c.secondary.withOpacity(0.55),
                  width: 2,
                ),
              ),
            ),
          ),
          Transform.scale(
            scale: scale,
            child: Container(
              width: 176,
              height: 176,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.c.fill,
                border: Border.all(color: context.c.stroke),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(phaseLabel, style: context.s.title),
                  const SizedBox(height: AppSpacing.xs),
                  Text('$seconds 秒', style: context.s.captionMuted),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '第 $cycle / $cycles 轮',
                    style: context.s.captionMuted,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
