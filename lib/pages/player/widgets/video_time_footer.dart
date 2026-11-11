import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../utils/formatters.dart';

class VideoTimeFooter extends StatelessWidget {
  const VideoTimeFooter({
    super.key,
    required this.position,
    required this.duration,
    required this.timer,
  });

  final Duration position;
  final Duration duration;
  final Duration? timer;

  @override
  Widget build(BuildContext context) {
    final int maxMs = duration.inMilliseconds;
    final int posMs = position.inMilliseconds.clamp(0, maxMs > 0 ? maxMs : 0);
    final int remainingMs = maxMs > 0 ? maxMs - posMs : 0;
    final TextStyle style = context.s.captionMuted.copyWith(
      fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
    );
    return Column(
      children: <Widget>[
        Text(
          '${formatSeconds(posMs ~/ 1000)} · '
          '剩余 ${formatSeconds(remainingMs ~/ 1000)}',
          textAlign: TextAlign.center,
          style: style,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          timer == null
              ? '未设定时'
              : '定时 ${formatSeconds(timer!.inSeconds)} · 到点自动停',
          textAlign: TextAlign.center,
          style: style,
        ),
      ],
    );
  }
}
