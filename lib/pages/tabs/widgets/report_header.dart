import 'package:mengyu_app/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// v7 月迹头部：标题 + 周日期范围 + 右侧周期切换。
class ReportHeader extends StatelessWidget {
  const ReportHeader({
    super.key,
    required this.range,
    required this.weekLabel,
    required this.canNext,
    required this.onPrevious,
    required this.onNext,
  });

  final String range;
  final String weekLabel;
  final bool canNext;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.page,
        AppSpacing.page,
        0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('月迹', style: context.s.title),
                const SizedBox(height: AppSpacing.xs),
                Text(range, style: context.s.caption),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _WeekArrow(
                tooltip: '上一周',
                icon: Icons.chevron_left,
                onPressed: onPrevious,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Text(weekLabel, style: context.s.caption),
              ),
              _WeekArrow(
                tooltip: '下一周',
                icon: Icons.chevron_right,
                onPressed: canNext ? onNext : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeekArrow extends StatelessWidget {
  const _WeekArrow({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 32,
      child: IconButton(
        onPressed: onPressed,
        tooltip: tooltip,
        padding: EdgeInsets.zero,
        iconSize: 16,
        icon: Icon(
          icon,
          color: onPressed == null
              ? context.c.textTertiary
              : context.c.textSecondary,
        ),
      ),
    );
  }
}
