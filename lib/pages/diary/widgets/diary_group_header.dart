import 'package:mengyu_app/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../utils/formatters.dart';

/// 日记列表的日期分组标题：今天/昨天优先，其余显示月日。
class DiaryGroupHeader extends StatelessWidget {
  const DiaryGroupHeader({
    super.key,
    required this.date,
    required this.count,
  });

  final DateTime date;
  final int count;

  String _label() {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime day = DateTime(date.year, date.month, date.day);
    final int diff = today.difference(day).inDays;
    if (diff == 0) {
      return '今天 · ${formatMonthDay(date)}';
    }
    if (diff == 1) {
      return '昨天 · ${formatMonthDay(date)}';
    }
    return formatMonthDay(date);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppSpacing.lg,
        bottom: AppSpacing.sm,
      ),
      child: Row(
        children: <Widget>[
          Text(_label(), style: context.s.captionMuted),
          const Spacer(),
          Text('$count 篇', style: context.s.captionMuted),
        ],
      ),
    );
  }
}
