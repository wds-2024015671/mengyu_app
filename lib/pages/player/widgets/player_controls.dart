import 'package:mengyu_app/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';

import '../../../providers/player_provider.dart';

/// v7 播放控制：收藏 / 上一首 / 金色播放 / 下一首 / 定时列表。
class PlayerControls extends StatelessWidget {
  const PlayerControls({
    super.key,
    required this.player,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.onOpenTimer,
    required this.canPrevious,
    required this.canNext,
    required this.onPrevious,
    required this.onNext,
  });

  final PlayerProvider player;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final VoidCallback onOpenTimer;
  final bool canPrevious;
  final bool canNext;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final bool loading = player.status == PlayerStatus.loading;
    return Row(
      children: <Widget>[
        Expanded(
          child: _IconControl(
            tooltip: isFavorite ? '取消收藏' : '收藏',
            icon: isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? context.c.secondary : context.c.textSecondary,
            onPressed: onToggleFavorite,
          ),
        ),
        Expanded(
          child: _IconControl(
            tooltip: '上一首',
            icon: Icons.skip_previous,
            color: canPrevious && !loading
                ? context.c.textSecondary
                : context.c.textTertiary,
            onPressed: canPrevious && !loading ? onPrevious : null,
          ),
        ),
        Expanded(child: _PlayButton(player: player)),
        Expanded(
          child: _IconControl(
            tooltip: '下一首',
            icon: Icons.skip_next,
            color: canNext && !loading
                ? context.c.textSecondary
                : context.c.textTertiary,
            onPressed: canNext && !loading ? onNext : null,
          ),
        ),
        Expanded(
          child: _IconControl(
            tooltip: '定时',
            icon: Icons.format_list_bulleted,
            color: context.c.textSecondary,
            onPressed: onOpenTimer,
          ),
        ),
      ],
    );
  }
}

class _IconControl extends StatelessWidget {
  const _IconControl({
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
    return Center(
      child: SizedBox(
        width: 44,
        height: 44,
        child: IconButton(
          onPressed: onPressed,
          tooltip: tooltip,
          padding: EdgeInsets.zero,
          iconSize: 20,
          icon: Icon(icon, color: color),
        ),
      ),
    );
  }
}

class _PlayButton extends StatelessWidget {
  const _PlayButton({required this.player});

  final PlayerProvider player;

  @override
  Widget build(BuildContext context) {
    final bool loading = player.status == PlayerStatus.loading;
    return Center(
      child: Tooltip(
        message: player.isPlaying ? '暂停' : '播放',
        child: Material(
          color: context.c.primary,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: loading ? null : () => player.togglePlay(),
            child: SizedBox(
              width: 64,
              height: 64,
              child: Center(
                child: loading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: context.c.onGold,
                        ),
                      )
                    : Icon(
                        player.isPlaying ? Icons.pause : Icons.play_arrow,
                        size: 20,
                        color: context.c.onGold,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
