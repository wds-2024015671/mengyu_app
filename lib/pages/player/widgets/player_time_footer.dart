import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../models/audio_item.dart';
import '../../../providers/player_provider.dart';
import '../../../utils/formatters.dart';

/// 播放进度刷新区：只让这一小块随时间重建，不刷新整页。
class PlayerTimeFooter extends StatelessWidget {
  const PlayerTimeFooter({
    super.key,
    required this.player,
    required this.audio,
  });

  final PlayerProvider player;
  final AudioItem audio;

  @override
  Widget build(BuildContext context) {
    return Selector<PlayerProvider, _Timeline>(
      selector: (_, PlayerProvider provider) {
        final Duration duration = provider.duration > Duration.zero
            ? provider.duration
            : Duration(seconds: audio.durationSec);
        final int maxMs = duration.inMilliseconds;
        final int posMs = provider.position.inMilliseconds.clamp(
          0,
          maxMs > 0 ? maxMs : 0,
        );
        return _Timeline(
          position: Duration(milliseconds: posMs),
          remaining: Duration(milliseconds: maxMs > 0 ? maxMs - posMs : 0),
          timer: provider.remaining,
        );
      },
      builder: (BuildContext context, _Timeline timeline, Widget? _) {
        return Column(
          children: <Widget>[
            Text(
              '${formatSeconds(timeline.position.inSeconds)} · '
              '剩余 ${formatSeconds(timeline.remaining.inSeconds)}',
              textAlign: TextAlign.center,
              style: context.s.captionMuted.copyWith(
                fontFeatures: const <FontFeature>[
                  FontFeature.tabularFigures(),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _timerLabel(timeline.timer),
              textAlign: TextAlign.center,
              style: context.s.captionMuted.copyWith(
                fontFeatures: const <FontFeature>[
                  FontFeature.tabularFigures(),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  String _timerLabel(Duration? remaining) {
    if (remaining == null) {
      return '未设定时';
    }
    return '定时 ${formatSeconds(remaining.inSeconds)} · 到点自动停';
  }
}

class _Timeline {
  const _Timeline({
    required this.position,
    required this.remaining,
    required this.timer,
  });

  final Duration position;
  final Duration remaining;
  final Duration? timer;

  @override
  bool operator ==(Object other) {
    return other is _Timeline &&
        other.position == position &&
        other.remaining == remaining &&
        other.timer == timer;
  }

  @override
  int get hashCode => Object.hash(position, remaining, timer);
}
