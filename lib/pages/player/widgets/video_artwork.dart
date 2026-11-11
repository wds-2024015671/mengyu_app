import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_tokens.dart';
import '../../tabs/widgets/sound_list_entry.dart';
import 'player_cover.dart';

/// 视频分支的 230 虚线圆 + 180 圆形视频窗口，无默认控制条 / 黑边。
class VideoArtwork extends StatelessWidget {
  const VideoArtwork({
    super.key,
    required this.video,
    required this.controller,
    required this.ready,
    required this.failed,
  });

  final VideoEntry video;
  final VideoPlayerController? controller;
  final bool ready;
  final bool failed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 230,
      height: 230,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          CustomPaint(
            size: const Size.square(230),
            painter: PlayerDashedRing(
              context.c.textPrimary.withOpacity(0.12),
            ),
          ),
          ClipOval(
            child: SizedBox(
              width: 180,
              height: 180,
              child: ColoredBox(
                color: context.c.cover,
                child: _content(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _content(BuildContext context) {
    final VideoPlayerController? value = controller;
    if (!ready || value == null) {
      return Center(
        child: Icon(
          failed ? Icons.videocam_off_outlined : Icons.play_circle_outline,
          size: 64,
          color: context.c.textSecondary,
        ),
      );
    }
    final Size size = value.value.size;
    if (size.width <= 0 || size.height <= 0) {
      return Center(
        child: Icon(
          Icons.play_circle_outline,
          size: 64,
          color: context.c.textSecondary,
        ),
      );
    }
    return FittedBox(
      fit: BoxFit.cover,
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: VideoPlayer(value),
      ),
    );
  }
}

/// 视频页的标题/副标题组，保持与音频页相同的中部结构。
class VideoNowPlaying extends StatelessWidget {
  const VideoNowPlaying({
    super.key,
    required this.video,
    required this.controller,
    required this.ready,
    required this.failed,
  });

  final VideoEntry video;
  final VideoPlayerController? controller;
  final bool ready;
  final bool failed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          VideoArtwork(
            video: video,
            controller: controller,
            ready: ready,
            failed: failed,
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            video.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: context.s.title,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '视频 · 深度助眠',
            textAlign: TextAlign.center,
            style: context.s.caption,
          ),
        ],
      ),
    );
  }
}
