import 'package:mengyu_app/core/theme/app_tokens.dart';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../utils/formatters.dart';
import '../../../utils/sleep_stats.dart';
import '../../../widgets/glass_card.dart';

/// v7 周柱状图：7 根柱、8h 虚线、最高 gold、今天 lav，不依赖图表库。
class ReportWeekChart extends StatelessWidget {
  const ReportWeekChart({
    super.key,
    required this.stats,
    required this.today,
  });

  final SleepWeekStats stats;
  final DateTime today;

  static const List<String> _dayLabels = <String>['一', '二', '三', '四', '五', '六', '日'];

  String _short(int minutes) {
    final int hours = minutes ~/ 60;
    final int rest = minutes % 60;
    if (hours <= 0) {
      return '${rest}m';
    }
    return rest == 0 ? '${hours}h' : '${hours}h${rest}m';
  }

  @override
  Widget build(BuildContext context) {
    final int maxMinutes = stats.days.fold<int>(
      0,
      (int max, SleepDayStat day) => math.max(max, day.minutes),
    );
    final double scale = math.max(480, maxMinutes).toDouble();
    final String todayKey = formatDateKey(today);
    final int nights = stats.days.where((SleepDayStat day) => day.hasData).length;
    const double labelHeight = 16;
    const double plotHeight = 72;
    const double referenceMinutes = 480;
    final double referenceTop =
        labelHeight + (1 - referenceMinutes / scale) * plotHeight;

    return GlassCard(
      outlined: true,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  '每日睡眠时长（小时）',
                  style: context.s.subtitle,
                ),
              ),
              Text('8h 参考', style: context.s.micro),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (nights < 3)
            const _ChartEmpty()
          else ...<Widget>[
            SizedBox(
              height: 88,
              child: Stack(
                children: <Widget>[
                  Positioned(
                    left: 0,
                    right: 24,
                    top: referenceTop,
                    child: SizedBox(
                      height: 1,
                      child: CustomPaint(
                        painter: _DashedLine(context.c.stroke),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: referenceTop - 6,
                    child: Text('8h', style: context.s.micro),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      for (int i = 0; i < stats.days.length; i++) ...<Widget>[
                        if (i > 0) const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _Bar(
                            key: ValueKey<String>('report-bar-$i'),
                            minutes: stats.days[i].minutes,
                            ratio: stats.days[i].minutes / scale,
                            isToday: formatDateKey(stats.days[i].date) ==
                                todayKey,
                            isMax: stats.days[i].minutes == maxMinutes &&
                                maxMinutes > 0,
                            label: _short(stats.days[i].minutes),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: <Widget>[
                for (int i = 0; i < stats.days.length; i++)
                  Expanded(
                    child: Center(
                      child: Text(
                        _dayLabels[i],
                        style: context.s.micro.copyWith(
                          color: formatDateKey(stats.days[i].date) == todayKey
                              ? context.c.secondary
                              : context.c.textTertiary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    super.key,
    required this.minutes,
    required this.ratio,
    required this.isToday,
    required this.isMax,
    required this.label,
  });

  final int minutes;
  final double ratio;
  final bool isToday;
  final bool isMax;
  final String label;

  @override
  Widget build(BuildContext context) {
    final Color color = isToday
        ? context.c.secondary
        : isMax
            ? context.c.primary
            : context.c.secondary.withOpacity(0.45);
    final Color labelColor = isToday
        ? context.c.secondary
        : isMax
            ? context.c.primary
            : context.c.textTertiary;
    final Widget? marker = minutes <= 0
        ? null
        : FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              maxLines: 1,
              style: context.s.micro.copyWith(
                color: labelColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          );

    return Column(
      children: <Widget>[
        SizedBox(height: 16, child: Center(child: marker)),
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              widthFactor: 1,
              heightFactor: ratio.clamp(0, 1),
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ChartEmpty extends StatelessWidget {
  const _ChartEmpty();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
      child: Column(
        children: <Widget>[
          Icon(
            Icons.nightlight_outlined,
            size: 24,
            color: context.c.textTertiary,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '记录满 3 晚后生成周图',
            style: context.s.caption.copyWith(
              color: context.c.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedLine extends CustomPainter {
  const _DashedLine(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 6) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(math.min(x + 3, size.width), 0),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLine oldDelegate) =>
      oldDelegate.color != color;
}
