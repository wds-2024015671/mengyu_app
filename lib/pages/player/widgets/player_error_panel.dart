import 'package:mengyu_app/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../providers/player_provider.dart';

/// 播放失败提示：纯文本行，不用 GlassCard、不使用金色。
class PlayerErrorPanel extends StatelessWidget {
  const PlayerErrorPanel({super.key, required this.player});

  final PlayerProvider player;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.error_outline,
            size: 20,
            color: context.c.danger,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              player.error ?? '播放失败，请稍后再试',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.s.caption,
            ),
          ),
          TextButton(
            onPressed: player.retry,
            style: TextButton.styleFrom(
              foregroundColor: context.c.textSecondary,
              textStyle: context.s.caption,
              minimumSize: const Size(0, 32),
            ),
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }
}
