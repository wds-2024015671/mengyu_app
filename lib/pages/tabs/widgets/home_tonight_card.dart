import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../models/audio_item.dart';
import '../../../widgets/audio_cover.dart';
import '../../../widgets/glass_card.dart';
import 'sound_list_entry.dart';

/// 今夜推荐：一个外框内上下两行，上视频、下音频。
class TonightCard extends StatelessWidget {
  const TonightCard({
    super.key,
    required this.video,
    required this.audio,
    required this.onPlayVideo,
    required this.onPlayAudio,
  });

  final VideoEntry? video;
  final AudioItem? audio;
  final ValueChanged<VideoEntry> onPlayVideo;
  final ValueChanged<AudioItem> onPlayAudio;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      outlined: true,
      padding: EdgeInsets.zero,
      child: Column(
        children: <Widget>[
          _RecommendRow(
            cover: _videoCover(context),
            title: video?.title ?? '还没有视频',
            enabled: video != null,
            onTap: video == null ? null : () => onPlayVideo(video!),
          ),
          Divider(
            height: 1,
            thickness: 1,
            indent: AppSpacing.lg,
            endIndent: AppSpacing.lg,
            color: context.c.stroke,
          ),
          _RecommendRow(
            cover: _audioCover(context),
            title: audio?.title ?? '还没有音频',
            enabled: audio != null,
            onTap: audio == null ? null : () => onPlayAudio(audio!),
          ),
        ],
      ),
    );
  }

  Widget _videoCover(BuildContext context) {
    final String? asset = video?.coverAsset;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.control),
      child: SizedBox(
        width: 64,
        height: 64,
        child: asset == null
            ? ColoredBox(
                color: context.c.cover,
                child: Icon(
                  Icons.videocam_outlined,
                  size: 20,
                  color: context.c.textSecondary,
                ),
              )
            : Image.asset(
                asset,
                fit: BoxFit.cover,
                errorBuilder: (
                  BuildContext context,
                  Object error,
                  StackTrace? stackTrace,
                ) =>
                    ColoredBox(
                  color: context.c.cover,
                  child: Icon(
                    Icons.videocam_outlined,
                    size: 20,
                    color: context.c.textSecondary,
                  ),
                ),
              ),
      ),
    );
  }

  Widget _audioCover(BuildContext context) {
    final AudioItem? item = audio;
    if (item == null) {
      return Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: context.c.cover,
          borderRadius: BorderRadius.circular(AppRadius.control),
        ),
        child: Icon(
          Icons.graphic_eq,
          size: 20,
          color: context.c.textSecondary,
        ),
      );
    }
    return AudioCover(
      item: item,
      width: 64,
      height: 64,
      radius: AppRadius.control,
      iconSize: 20,
    );
  }
}

class _RecommendRow extends StatelessWidget {
  const _RecommendRow({
    required this.cover,
    required this.title,
    required this.enabled,
    required this.onTap,
  });

  final Widget cover;
  final String title;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 80,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: <Widget>[
                cover,
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.s.subtitle,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: context.c.stroke),
                  ),
                  child: Icon(
                    Icons.play_arrow,
                    size: 20,
                    color: enabled
                        ? context.c.textSecondary
                        : context.c.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
