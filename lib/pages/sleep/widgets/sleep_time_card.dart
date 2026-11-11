import 'package:mengyu_app/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../utils/formatters.dart';

/// v7 睡眠时间行：48 高、底部 1px stroke，无卡片。
class SleepTimeCard extends StatelessWidget {
  const SleepTimeCard({
    super.key,
    required this.label,
    required this.icon,
    required this.time,
    required this.onPickDate,
    required this.onPickTime,
  });

  final String label;
  final IconData icon;
  final DateTime time;
  final VoidCallback onPickDate;
  final VoidCallback onPickTime;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: context.c.stroke)),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 20, color: context.c.textSecondary),
          const SizedBox(width: AppSpacing.sm),
          Text(label, style: context.s.captionMuted),
          const Spacer(),
          _TimeButton(
            text: formatMonthDay(time),
            tooltip: '选择日期',
            onTap: onPickDate,
          ),
          const SizedBox(width: AppSpacing.xs),
          _TimeButton(
            text: formatClock(time),
            tooltip: '选择时间',
            onTap: onPickTime,
          ),
        ],
      ),
    );
  }
}

class _TimeButton extends StatelessWidget {
  const _TimeButton({
    required this.text,
    required this.tooltip,
    required this.onTap,
  });

  final String text;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.chip),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          child: Text(
            text,
            style: context.s.body.copyWith(fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}
