import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mengyu_app/core/theme/app_tokens.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/sleep_session.dart';
import '../../../utils/formatters.dart';
import '../../../widgets/glass_card.dart';
import 'report_moon_cell.dart';

/// v7 本月 30 天月迹：外框 20 圆角，标题/图例/补记在框内。
class ReportMoonGrid extends StatelessWidget {
  const ReportMoonGrid({
    super.key,
    required this.sessions,
    required this.today,
    required this.onAdd,
    required this.onPickDate,
    required this.onEditSession,
  });

  final List<SleepSession> sessions;
  final DateTime today;
  final VoidCallback onAdd;
  final ValueChanged<DateTime> onPickDate;
  final ValueChanged<SleepSession> onEditSession;

  @override
  Widget build(BuildContext context) {
    final DateTime end = DateTime(today.year, today.month, today.day);
    final DateTime start = end.subtract(const Duration(days: 29));
    final Map<String, int> minutesByDay = <String, int>{};
    final Map<String, SleepSession> sessionByDay = <String, SleepSession>{};
    final Set<String> manualDays = <String>{};
    for (final SleepSession session in sessions) {
      final DateTime day = DateTime(
        session.bedTime.year,
        session.bedTime.month,
        session.bedTime.day,
      );
      if (day.isBefore(start) || day.isAfter(end)) {
        continue;
      }
      final String key = formatDateKey(day);
      minutesByDay[key] = (minutesByDay[key] ?? 0) + session.durationMin;
      sessionByDay.putIfAbsent(key, () => session);
      if (session.source == SleepSource.manual) {
        manualDays.add(key);
      }
    }
    final int maxMinutes = minutesByDay.values.fold<int>(
      0,
      (int max, int value) => math.max(max, value),
    );
    final List<DateTime> dates = <DateTime>[
      for (int i = 0; i < 30; i++)
        DateTime(start.year, start.month, start.day + i),
    ];

    return GlassCard(
      outlined: true,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text('本月月迹 · 30 天', style: context.s.title),
              ),
              TextButton(
                onPressed: onAdd,
                style: TextButton.styleFrom(
                  foregroundColor: context.c.textSecondary,
                  textStyle: context.s.caption,
                  minimumSize: const Size(0, 32),
                  padding: EdgeInsets.zero,
                ),
                child: const Text('补记'),
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Text('月相=完成，横条=时长', style: context.s.micro),
          ),
          const SizedBox(height: AppSpacing.md),
          GridView.builder(
            key: const Key('report-moon-grid'),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              mainAxisExtent: 28,
            ),
            itemCount: dates.length,
            itemBuilder: (BuildContext context, int index) {
              final DateTime date = dates[index];
              final String key = formatDateKey(date);
              final int minutes = minutesByDay[key] ?? 0;
              final SleepSession? session = sessionByDay[key];
              void openDate() {
                if (session != null) {
                  onEditSession(session);
                } else {
                  onPickDate(date);
                }
              }

              return MoonCell(
                key: ValueKey<String>('moon-$key'),
                date: date,
                minutes: minutes,
                maxMinutes: maxMinutes,
                isToday: key == formatDateKey(end),
                manual: manualDays.contains(key),
                onTap: openDate,
                onLongPress: openDate,
              );
            },
          ),
        ],
      ),
    );
  }
}
