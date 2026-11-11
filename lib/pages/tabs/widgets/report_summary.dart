import 'package:mengyu_app/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../utils/sleep_stats.dart';
import '../../../widgets/glass_card.dart';

/// v7 周汇总：填充卡，平均睡眠 + 较上周变化。
class ReportSummary extends StatelessWidget {
  const ReportSummary({
    super.key,
    required this.stats,
    required this.previousAverage,
    this.label = '本周平均睡眠',
  });

  final SleepWeekStats stats;
  final double previousAverage;
  final String label;

  String get _value {
    final int minutes = stats.averageMinutes.round();
    if (minutes <= 0) {
      return '—';
    }
    final int hours = minutes ~/ 60;
    final int rest = minutes % 60;
    if (hours == 0) {
      return '${rest}m';
    }
    return rest == 0 ? '${hours}h' : '${hours}h ${rest}m';
  }

  String get _delta {
    if (stats.averageMinutes <= 0 || previousAverage <= 0) {
      return '—';
    }
    final int diff =
        stats.averageMinutes.round() - previousAverage.round();
    if (diff == 0) {
      return '持平';
    }
    return '${diff > 0 ? '↑' : '↓'} ${diff.abs()}m';
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: context.s.caption),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: <Widget>[
              Text(
                _value,
                style: context.s.title.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(_delta, style: context.s.caption),
            ],
          ),
        ],
      ),
    );
  }
}
