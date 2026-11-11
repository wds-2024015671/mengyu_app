import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_tokens.dart';

/// 播放进度：0..1，duration 未知或异常时回到 0。
double mediaProgress(Duration position, Duration duration) {
  final int total = duration.inMilliseconds;
  if (total <= 0) {
    return 0;
  }
  final int current = position.inMilliseconds;
  return (current / total).clamp(0.0, 1.0);
}

/// 环绕 64 播放键的 80 外径进度环；环本身不参与点击。
class PlayerProgressRing extends StatelessWidget {
  const PlayerProgressRing({
    super.key,
    required this.progress,
    required this.child,
  });

  final double progress;
  final Widget child;

  static const double size = 80;
  static const double stroke = 2;

  @override
  Widget build(BuildContext context) {
    final double target =
        progress.isFinite ? progress.clamp(0.0, 1.0).toDouble() : 0;
    return SizedBox.square(
      dimension: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(end: target),
        duration: const Duration(milliseconds: 220),
        curve: Curves.linear,
        builder: (BuildContext context, double value, Widget? _) {
          return Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _RingPainter(
                      progress: value,
                      track: context.c.textPrimary.withOpacity(0.10),
                      gold: context.c.primary,
                    ),
                  ),
                ),
              ),
              child,
            ],
          );
        },
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.progress,
    required this.track,
    required this.gold,
  });

  final double progress;
  final Color track;
  final Color gold;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Rect.fromCircle(
      center: size.center(Offset.zero),
      radius: size.width / 2 - PlayerProgressRing.stroke / 2,
    );
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = PlayerProgressRing.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, -math.pi / 2, math.pi * 2, false, paint..color = track);
    if (progress > 0) {
      canvas.drawArc(
        rect,
        -math.pi / 2,
        math.pi * 2 * progress,
        false,
        paint..color = gold,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.track != track ||
      oldDelegate.gold != gold;
}
