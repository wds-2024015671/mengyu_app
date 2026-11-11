import 'package:flutter/material.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/sleep_tracking_record.dart';
import '../../../utils/formatters.dart';
import '../../../widgets/glass_card.dart';

/// 今晚页的待确认提示：不打断，点击再确认。
class SleepPendingBanner extends StatelessWidget {
  const SleepPendingBanner({
    super.key,
    required this.record,
    required this.onTap,
  });

  final SleepTrackingRecord record;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      outlined: true,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      onTap: onTap,
      child: Row(
        children: <Widget>[
          Icon(
            Icons.nightlight_outlined,
            size: 20,
            color: context.c.secondary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '昨晚记录待确认',
                  style: context.s.body.copyWith(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  '${formatClock(record.startAt)} 开始 · 点击确认',
                  style: context.s.captionMuted,
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            size: 18,
            color: context.c.textSecondary,
          ),
        ],
      ),
    );
  }
}
