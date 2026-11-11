import 'package:flutter/material.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/app_theme.dart';
import 'sound_list_entry.dart';

/// 六个视频共用一个外框，内部视频项不再加边框。
class VideoGroup extends StatelessWidget {
  const VideoGroup({
    super.key,
    required this.videos,
    required this.onOpen,
  });

  final List<VideoEntry> videos;
  final ValueChanged<VideoEntry> onOpen;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: context.c.stroke),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          mainAxisExtent: 142,
        ),
        itemCount: videos.length,
        itemBuilder: (BuildContext context, int index) {
          final VideoEntry video = videos[index];
          return _VideoTile(video: video, onTap: () => onOpen(video));
        },
      ),
    );
  }
}

class _VideoTile extends StatelessWidget {
  const _VideoTile({required this.video, required this.onTap});

  final VideoEntry video;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.control),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 76,
            width: double.infinity,
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: context.c.cover,
                      borderRadius: BorderRadius.circular(AppRadius.control),
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.c.sheet.withOpacity(0.45),
                      border: Border.all(color: context.c.stroke),
                    ),
                    child: Icon(
                      Icons.play_arrow,
                      size: 16,
                      color: context.c.textPrimary,
                    ),
                  ),
                ),
                Positioned(
                  right: AppSpacing.xs,
                  bottom: AppSpacing.xs,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: context.c.sheet.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(video.durationLabel, style: context.s.micro),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            video.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.s.body.copyWith(
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
          Text(
            video.platform,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.s.micro,
          ),
        ],
      ),
    );
  }
}
