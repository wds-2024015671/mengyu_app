import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mengyu_app/core/theme/app_tokens.dart';

import '../../../models/audio_item.dart';
import '../../../widgets/audio_cover.dart';

/// v7 播放页封面：230 虚线外圈 + 180 内圈 + 64 图标，无发光阴影。
class PlayerCover extends StatelessWidget {
  const PlayerCover({super.key, required this.item});

  final AudioItem item;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 230,
      height: 230,
      child: Hero(
        tag: audioCoverTag(item.id),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            CustomPaint(
              size: const Size.square(230),
              painter: _DashedRing(
                context.c.textPrimary.withOpacity(0.12),
              ),
            ),
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: const Alignment(-0.25, -0.3),
                  radius: 0.9,
                  colors: <Color>[
                    context.c.secondary.withOpacity(0.30),
                    context.c.cover,
                  ],
                ),
              ),
              child: Icon(
                Icons.graphic_eq,
                size: 64,
                color: context.c.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedRing extends CustomPainter {
  const _DashedRing(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = color;
    final Rect rect = Rect.fromCircle(
      center: size.center(Offset.zero),
      radius: size.width / 2 - 0.5,
    );
    const int count = 48;
    for (int i = 0; i < count; i++) {
      canvas.drawArc(rect, i * 2 * math.pi / count, 0.045, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRing oldDelegate) =>
      oldDelegate.color != color;
}
