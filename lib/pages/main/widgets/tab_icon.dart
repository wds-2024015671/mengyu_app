import 'dart:math' as math;

import 'package:flutter/material.dart';

/// v7 底部 tab 的 4 个线性图标，按 24 视窗手绘，保证 stroke 1.5、round cap。
enum TabIconKind { moon, sound, phase, person }

class TabIcon extends StatelessWidget {
  const TabIcon({
    super.key,
    required this.kind,
    required this.color,
    this.size = 20,
  });

  final TabIconKind kind;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _TabIconPainter(kind: kind, color: color),
      ),
    );
  }
}

class _TabIconPainter extends CustomPainter {
  const _TabIconPainter({required this.kind, required this.color});

  final TabIconKind kind;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5 * (24 / size.width)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = color;

    canvas.save();
    canvas.scale(size.width / 24);
    switch (kind) {
      case TabIconKind.moon:
        _paintMoon(canvas, paint);
        break;
      case TabIconKind.sound:
        _paintSound(canvas, paint);
        break;
      case TabIconKind.phase:
        _paintPhase(canvas, paint);
        break;
      case TabIconKind.person:
        _paintPerson(canvas, paint);
        break;
    }
    canvas.restore();
  }

  void _paintMoon(Canvas canvas, Paint paint) {
    final Path outer = Path()
      ..addOval(Rect.fromCircle(center: const Offset(12, 12), radius: 8.8));
    final Path cut = Path()
      ..addOval(Rect.fromCircle(center: const Offset(17.2, 8.2), radius: 8.4));
    canvas.drawPath(
      Path.combine(PathOperation.difference, outer, cut),
      paint,
    );
  }

  void _paintSound(Canvas canvas, Paint paint) {
    final Path upper = Path()
      ..moveTo(4, 14)
      ..cubicTo(6.5, 12.6, 8, 10, 8, 7.5)
      ..cubicTo(8, 6, 9.5, 4.5, 11, 4.5)
      ..cubicTo(12.5, 4.5, 14, 6, 14, 7.5)
      ..cubicTo(14, 10, 15.5, 12.6, 18, 14);
    final Path lower = Path()
      ..moveTo(3, 17)
      ..cubicTo(6, 18.8, 9, 18.8, 12, 17)
      ..cubicTo(15, 15.2, 18, 15.2, 21, 17);
    canvas.drawPath(upper, paint);
    canvas.drawPath(lower, paint);
  }

  void _paintPhase(Canvas canvas, Paint paint) {
    final Rect ring = Rect.fromCircle(center: const Offset(12, 12), radius: 8);
    for (int i = 0; i < 8; i++) {
      canvas.drawArc(
        ring,
        i * math.pi / 4,
        math.pi / 8,
        false,
        paint,
      );
    }
    final Path outer = Path()
      ..addOval(Rect.fromCircle(center: const Offset(11.5, 12), radius: 6.5));
    final Path cut = Path()
      ..addOval(Rect.fromCircle(center: const Offset(15, 9), radius: 6.1));
    canvas.drawPath(
      Path.combine(PathOperation.difference, outer, cut),
      paint,
    );
  }

  void _paintPerson(Canvas canvas, Paint paint) {
    canvas.drawCircle(const Offset(12, 8.4), 3.4, paint);
    final Path shoulders = Path()
      ..moveTo(4.8, 19.5)
      ..cubicTo(5.5, 16.1, 8.4, 14.1, 12, 14.1)
      ..cubicTo(15.6, 14.1, 18.5, 16.1, 19.2, 19.5);
    canvas.drawPath(shoulders, paint);
  }

  @override
  bool shouldRepaint(covariant _TabIconPainter oldDelegate) {
    return oldDelegate.kind != kind || oldDelegate.color != color;
  }
}
