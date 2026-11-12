import 'package:mengyu_app/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../utils/formatters.dart';

/// v7 今晚页头部：左侧日期/问候/一句话，右侧 72 月亮（无头像）。
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.nickname,
  });

  final String nickname;

  static const List<String> _weekdays = <String>[
    '周一',
    '周二',
    '周三',
    '周四',
    '周五',
    '周六',
    '周日',
  ];

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final String name = nickname.trim().isEmpty ? '小屿' : nickname.trim();
    final String date =
        '${formatMonthDay(now).replaceAll(' ', '')} · ${_weekdays[now.weekday - 1]}';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(date, style: context.s.caption),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${greetingForHour(now.hour)}，$name',
                style: context.s.display,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '把今天，轻轻放下。',
                style: context.s.bodySecondary,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        const _MoonGroup(),
      ],
    );
  }
}

class _MoonGroup extends StatelessWidget {
  const _MoonGroup();

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.nightlight_round,
      size: 72,
      color: context.c.textPrimary,
    );
  }
}
