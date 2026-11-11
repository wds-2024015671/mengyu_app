import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../models/audio_item.dart';
import '../../../providers/player_provider.dart';
import 'player_cover.dart';
import 'player_error_panel.dart';

/// 顶部栏与底部控制之间的封面/标题组，整体垂直居中。
class PlayerNowPlaying extends StatelessWidget {
  const PlayerNowPlaying({
    super.key,
    required this.audio,
    required this.player,
  });

  final AudioItem audio;
  final PlayerProvider player;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          PlayerCover(item: audio),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            audio.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: context.s.title,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${audio.category} · 深度助眠',
            textAlign: TextAlign.center,
            style: context.s.caption,
          ),
          if (player.status == PlayerStatus.error) ...<Widget>[
            const SizedBox(height: AppSpacing.xxl),
            PlayerErrorPanel(player: player),
          ],
        ],
      ),
    );
  }
}
