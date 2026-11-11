import 'package:mengyu_app/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/sleep_session.dart';
import '../../../utils/sleep_stats.dart';

/// 本周三项统计：无卡片底，数值 16/600、标签 10 t3。
class ReportStats extends StatelessWidget {
  const ReportStats({
    super.key,
    required this.stats,
    required this.averageBedtime,
  });

  final SleepWeekStats stats;
  final String averageBedtime;

  static String bedtimeLabel(List<SleepSession> sessions) {
    if (sessions.isEmpty) {
      return '—';
    }
    // 以 18:00 为锚点做环形平均，避免 23:30 与 00:30 被简单平均到中午。
    int total = 0;
    for (final SleepSession session in sessions) {
      final int minutes = session.bedTime.hour * 60 + session.bedTime.minute;
      total += (minutes - 18 * 60 + 1440) % 1440;
    }
    final int shifted = (total / sessions.length).round();
    final int minutes = (shifted + 18 * 60) % 1440;
    final String hh = (minutes ~/ 60).toString().padLeft(2, '0');
    final String mm = (minutes % 60).toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _Stat(value: '${stats.streakDays}', label: '连续靠岸'),
        ),
        Expanded(child: _Stat(value: averageBedtime, label: '平均入睡')),
        Expanded(
          child: _Stat(value: '${stats.sessionCount}', label: '本周仪式'),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: context.s.subtitle.copyWith(
              fontWeight: FontWeight.w600,
              color: context.c.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(label, style: context.s.micro),
      ],
    );
  }
}
