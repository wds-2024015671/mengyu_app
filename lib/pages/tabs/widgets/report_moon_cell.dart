import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mengyu_app/core/theme/app_tokens.dart';

import '../../../core/theme/app_theme.dart';
import '../../../utils/formatters.dart';

enum _MoonPhase { empty, left, full, right }

/// 单个月迹格：月相 = 完成，横条 = 时长，今天 lav 描边。
class MoonCell extends StatelessWidget {
  const MoonCell({
    super.key,
    required this.date,
    required this.minutes,
    required this.maxMinutes,
    required this.isToday,
    required this.onTap,
    required this.onLongPress,
    this.manual = false,
  });

  final DateTime date;
  final int minutes;
  final int maxMinutes;
  final bool isToday;
  final bool manual;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  bool get _hasRecord => minutes > 0;
  double get _barRatio =>
      _hasRecord && maxMinutes > 0 ? minutes / maxMinutes : 0;

  _MoonPhase get _phase {
    if (!_hasRecord) {
      return _MoonPhase.empty;
    }
    return _MoonPhase.values[1 + ((date.day + date.month) % 3)];
  }

  @override
  Widget build(BuildContext context) {
    final Color color = _hasRecord
        ? context.c.primary
        : context.c.textTertiary;
    return Semantics(
      button: true,
      label: '${formatMonthDay(date)}${_hasRecord ? ' 已记录' : ' 未记录'}',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.chip),
            border: isToday
                ? Border.all(color: context.c.secondary)
                : null,
          ),
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final double barWidth =
                        math.max(0, constraints.maxWidth - 10) * _barRatio;
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: _MoonMark(phase: _phase, color: color),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: SizedBox(
                            width: barWidth,
                            height: 2,
                            child: ColoredBox(color: context.c.primary),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              if (manual)
                Positioned(
                  right: 3,
                  top: 3,
                  child: Container(
                    width: 3,
                    height: 3,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.c.secondary,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoonMark extends StatelessWidget {
  const _MoonMark({required this.phase, required this.color});

  final _MoonPhase phase;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size.square(10),
      painter: _MoonPainter(phase: phase, color: color),
    );
  }
}

class _MoonPainter extends CustomPainter {
  const _MoonPainter({required this.phase, required this.color});

  final _MoonPhase phase;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final Path circle = Path()..addOval(rect.deflate(0.5));
    final Paint stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = color;
    final Paint fill = Paint()
      ..style = PaintingStyle.fill
      ..color = color;

    switch (phase) {
      case _MoonPhase.empty:
        canvas.drawPath(circle, stroke);
        break;
      case _MoonPhase.left:
        canvas.save();
        canvas.clipPath(circle);
        canvas.drawRect(
          Rect.fromLTWH(0, 0, size.width / 2, size.height),
          fill,
        );
        canvas.restore();
        canvas.drawPath(circle, stroke);
        break;
      case _MoonPhase.full:
        canvas.drawPath(circle, fill);
        break;
      case _MoonPhase.right:
        canvas.save();
        canvas.clipPath(circle);
        canvas.drawRect(
          Rect.fromLTWH(size.width / 2, 0, size.width / 2, size.height),
          fill,
        );
        canvas.restore();
        canvas.drawPath(circle, stroke);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _MoonPainter oldDelegate) {
    return oldDelegate.phase != phase || oldDelegate.color != color;
  }
}
