import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_tokens.dart';
import '../../tabs/widgets/sound_list_entry.dart';

/// 视频播放画面：按原始比例铺满宽度，完整显示，不裁切、不套圆形。
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
    final VideoPlayerController? value = controller;
    final double ratio = ready && value != null && value.value.aspectRatio > 0
        ? value.value.aspectRatio
        : 16 / 9;
    return AspectRatio(
      aspectRatio: ratio,
      child: ColoredBox(
        color: context.c.cover,
        child: ready && value != null
            ? VideoPlayer(value)
            : Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  if (video.coverAsset != null)
                    Image.asset(
                      video.coverAsset!,
                      fit: BoxFit.cover,
                      errorBuilder: (
                        BuildContext context,
                        Object error,
                        StackTrace? stackTrace,
                      ) =>
                          ColoredBox(color: context.c.cover),
                    )
                  else
                    ColoredBox(color: context.c.cover),
                  Center(
                    child: Icon(
                      failed
                          ? Icons.videocam_off_outlined
                          : Icons.play_circle_outline,
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

/// 视频页的标题/副标题组。
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
            child: Text(
              video.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: context.s.title,
            ),
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
