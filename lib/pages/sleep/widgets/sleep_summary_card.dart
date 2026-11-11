import 'package:mengyu_app/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../widgets/glass_card.dart';

/// 时长 + 评分摘要：时长由入睡/起床自动推导，不能手填。
class SleepSummaryCard extends StatelessWidget {
  const SleepSummaryCard({
    super.key,
    required this.durationText,
    required this.quality,
  });

  final String durationText;
  final int quality;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      outlined: true,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('睡眠时长', style: context.s.captionMuted),
                const SizedBox(height: AppSpacing.xs),
                Text(durationText, style: context.s.title),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('睡眠评分', style: context.s.captionMuted),
                const SizedBox(height: AppSpacing.xs),
                Text('$quality / 5', style: context.s.title),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
