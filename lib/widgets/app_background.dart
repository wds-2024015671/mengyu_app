import 'package:mengyu_app/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';


/// v7 页面底图：唯一基底 #070B1A + 最多 5 个星点。
///
/// 背景保持纯色，不再叠加径向 tint，避免不同 GPU 上出现可见的大圆环。
/// tint 参数保留用于兼容旧调用，但不参与绘制。
class AppBackground extends StatelessWidget {
  const AppBackground({
    super.key,
    required this.child,
    this.tint,
    this.showStars = true,
  });

  final Widget child;
  final Color? tint;

  /// 极简页面可以关掉星点；开启时固定 5 个，透明度 ≤ .8。
  final bool showStars;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.c.bgDeep,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          if (showStars)
            CustomPaint(painter: _StarPainter(context.c.star)),
          child,
        ],
      ),
    );
  }
}

/// 固定 5 个星点，位置写死，避免每帧随机闪烁。
class _StarPainter extends CustomPainter {
  const _StarPainter(this.color);

  final Color color;

  static const List<_Star> _stars = <_Star>[
    _Star(0.12, 0.16, 1.2, 0.55),
    _Star(0.78, 0.12, 1.5, 0.8),
    _Star(0.66, 0.30, 0.9, 0.4),
    _Star(0.28, 0.38, 0.7, 0.35),
    _Star(0.88, 0.48, 1.0, 0.45),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint();
    for (final _Star star in _stars) {
      paint.color = color.withOpacity(star.opacity);
      canvas.drawCircle(
        Offset(star.dx * size.width, star.dy * size.height),
        star.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StarPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _Star {
  const _Star(this.dx, this.dy, this.radius, this.opacity);

  final double dx;
  final double dy;
  final double radius;
  final double opacity;
}
