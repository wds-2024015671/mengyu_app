import 'package:flutter/material.dart';

import '../../../core/theme/app_tokens.dart';
import 'player_progress_ring.dart';

/// 视频页复用音频页的五控制布局与环形进度。
class VideoControls extends StatelessWidget {
  const VideoControls({
    super.key,
    required this.progress,
    required this.isPlaying,
    required this.canPrevious,
    required this.canNext,
    required this.onPrevious,
    required this.onNext,
    required this.onTogglePlay,
  });

  final double progress;
  final bool isPlaying;
  final bool canPrevious;
  final bool canNext;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onTogglePlay;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        _VideoIcon(
          tooltip: '上一首',
          icon: Icons.skip_previous,
          color: canPrevious
              ? context.c.textSecondary
              : context.c.textTertiary,
          onPressed: canPrevious ? onPrevious : null,
        ),
        SizedBox(
          width: PlayerProgressRing.size,
          height: PlayerProgressRing.size,
          child: Center(
            child: PlayerProgressRing(
              progress: progress,
              child: Tooltip(
                message: isPlaying ? '暂停' : '播放',
                child: Material(
                  color: context.c.primary,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: onTogglePlay,
                    child: SizedBox(
                      width: 64,
                      height: 64,
                      child: Icon(
                        isPlaying ? Icons.pause : Icons.play_arrow,
                        size: 20,
                        color: context.c.onGold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        _VideoIcon(
          tooltip: '下一首',
          icon: Icons.skip_next,
          color: canNext ? context.c.textSecondary : context.c.textTertiary,
          onPressed: canNext ? onNext : null,
        ),
      ],
    );
  }
}

class _VideoIcon extends StatelessWidget {
  const _VideoIcon({
    required this.tooltip,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: IconButton(
        onPressed: onPressed,
        tooltip: tooltip,
        padding: EdgeInsets.zero,
        iconSize: 20,
        icon: Icon(icon, color: color),
      ),
    );
  }
}
