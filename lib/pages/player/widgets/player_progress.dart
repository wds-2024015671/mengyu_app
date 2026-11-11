import 'package:mengyu_app/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../utils/formatters.dart';

/// v7 播放进度：2px 线 + 10px 圆点，可点/拖 seek；右侧显示剩余时间。
class PlayerProgress extends StatelessWidget {
  const PlayerProgress({
    super.key,
    required this.position,
    required this.duration,
    required this.enabled,
    required this.onSeek,
  });

  final Duration position;
  final Duration duration;
  final bool enabled;
  final ValueChanged<Duration> onSeek;

  static const double _thumb = 10;

  @override
  Widget build(BuildContext context) {
    final int maxMs = duration.inMilliseconds;
    final int posMs = position.inMilliseconds.clamp(0, maxMs > 0 ? maxMs : 0);
    final double fraction = maxMs > 0 ? posMs / maxMs : 0;
    final Duration remaining = maxMs > 0
        ? Duration(milliseconds: (maxMs - posMs).clamp(0, maxMs))
        : Duration.zero;

    return Column(
      children: <Widget>[
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double width = constraints.maxWidth;
            void seekAt(Offset local) {
              if (!enabled || maxMs <= 0) {
                return;
              }
              final double ratio = (local.dx / width).clamp(0.0, 1.0);
              onSeek(Duration(milliseconds: (ratio * maxMs).round()));
            }

            return Semantics(
              slider: true,
              value:
                  '${formatSeconds(position.inSeconds)} / ${formatSeconds(duration.inSeconds)}',
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: enabled && maxMs > 0
                    ? (TapDownDetails details) => seekAt(details.localPosition)
                    : null,
                onHorizontalDragStart: enabled && maxMs > 0
                    ? (DragStartDetails details) =>
                        seekAt(details.localPosition)
                    : null,
                onHorizontalDragUpdate: enabled && maxMs > 0
                    ? (DragUpdateDetails details) =>
                        seekAt(details.localPosition)
                    : null,
                child: SizedBox(
                  height: 24,
                  child: Stack(
                    children: <Widget>[
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 11,
                        child: Container(
                          height: 2,
                          color: context.c.stroke,
                        ),
                      ),
                      if (fraction > 0)
                        Positioned(
                          left: 0,
                          top: 11,
                          width: width * fraction,
                          child: Container(
                            height: 2,
                            color: context.c.primary,
                          ),
                        ),
                      Positioned(
                        left: (width - _thumb) * fraction,
                        top: 7,
                        child: Container(
                          width: _thumb,
                          height: _thumb,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: context.c.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: <Widget>[
            Text(
              formatSeconds(position.inSeconds),
              style: context.s.captionMuted,
            ),
            const Spacer(),
            Text(
              '剩余 ${formatSeconds(remaining.inSeconds)}',
              style: context.s.captionMuted,
            ),
          ],
        ),
      ],
    );
  }
}
