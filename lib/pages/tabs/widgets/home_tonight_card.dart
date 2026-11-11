import 'package:mengyu_app/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/audio_item.dart';
import '../../../widgets/audio_cover.dart';
import '../../../widgets/glass_card.dart';

/// v7 今夜推荐卡：描边卡 + 64 封面 + 16/11/11 文案 + 36 圆形播放按钮。
///
/// 加载/错误/空态都收在卡内，不使用第二个金色主按钮。
class TonightCard extends StatelessWidget {
  const TonightCard({
    super.key,
    required this.item,
    required this.isLoading,
    required this.error,
    required this.onRetry,
    required this.onPlay,
  });

  final AudioItem? item;
  final bool isLoading;
  final String? error;
  final VoidCallback onRetry;
  final ValueChanged<AudioItem> onPlay;

  @override
  Widget build(BuildContext context) {
    final AudioItem? current = item;
    if (current == null) {
      return GlassCard(
        outlined: true,
        child: Row(
          children: <Widget>[
            if (isLoading)
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: context.c.secondary,
                ),
              )
            else
              Icon(
                Icons.graphic_eq,
                size: 24,
                color: context.c.textTertiary,
              ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    isLoading ? '正在挑选今夜的声音…' : '音景还没到岛上',
                    style: context.s.subtitle,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    isLoading ? '马上就好' : (error ?? '稍后下拉刷新再试试。'),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.s.caption,
                  ),
                ],
              ),
            ),
            if (!isLoading)
              TextButton(
                onPressed: onRetry,
                style: TextButton.styleFrom(
                  foregroundColor: context.c.textSecondary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                  ),
                  minimumSize: const Size(0, 32),
                  textStyle: context.s.caption,
                ),
                child: const Text('重试'),
              ),
          ],
        ),
      );
    }

    return GlassCard(
      outlined: true,
      onTap: () => onPlay(current),
      child: Row(
        children: <Widget>[
          AudioCover(
            item: current,
            width: 64,
            height: 64,
            radius: AppRadius.control,
            iconSize: 20,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(current.title, style: context.s.subtitle),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${current.category} · ${_durationText(current)}',
                  style: context.s.caption,
                ),
                if (current.description.isNotEmpty) ...<Widget>[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    current.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.s.captionMuted,
                  ),
                ],
              ],
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
              color: context.c.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _durationText(AudioItem item) {
    if (item.durationSec <= 0) {
      return '循环';
    }
    return '${(item.durationSec / 60).ceil()} 分钟';
  }
}
