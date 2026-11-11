import 'package:mengyu_app/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/audio_item.dart';
import '../../../utils/formatters.dart';
import '../../../widgets/audio_cover.dart';
import '../../../widgets/glass_card.dart';

/// v7 声屿卡片：描边 20 圆角，透明卡体，封面 64 + 底部分隔。
class SoundCard extends StatelessWidget {
  const SoundCard({
    super.key,
    required this.item,
    required this.isFavorite,
    required this.onTap,
    required this.onToggleFavorite,
  });

  final AudioItem item;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      outlined: true,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Hero(
            tag: audioCoverTag(item.id),
            child: _SoundCover(
              item: item,
              isFavorite: isFavorite,
              onToggleFavorite: onToggleFavorite,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: 10,
            ),
            child: Text(
              item.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.s.subtitle,
            ),
          ),
        ],
      ),
    );
  }
}

class _SoundCover extends StatelessWidget {
  const _SoundCover({
    required this.item,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  final AudioItem item;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  static const Set<String> _fireIds = <String>{'local_fire'};

  IconData get _icon {
    if (item.id == 'local_rain') {
      return Icons.grain;
    }
    if (item.id == 'local_ocean') {
      return Icons.waves;
    }
    if (item.id == 'local_stream') {
      return Icons.water;
    }
    if (item.id == 'local_wind') {
      return Icons.air;
    }
    if (_fireIds.contains(item.id)) {
      return Icons.local_fire_department_outlined;
    }
    if (item.id == 'local_noise') {
      return Icons.blur_on;
    }
    return Icons.graphic_eq;
  }

  String get _duration =>
      item.durationSec > 0 ? formatSeconds(item.durationSec) : '循环';

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: context.c.cover,
        border: Border(bottom: BorderSide(color: context.c.stroke)),
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            left: 10,
            bottom: 10,
            child: Icon(_icon, size: 20, color: context.c.textSecondary),
          ),
          Positioned(
            right: 6,
            top: 6,
            child: SizedBox(
              width: 28,
              height: 28,
              child: IconButton(
                onPressed: onToggleFavorite,
                padding: EdgeInsets.zero,
                tooltip: isFavorite ? '取消收藏' : '收藏',
                iconSize: 16,
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite
                      ? context.c.secondary
                      : context.c.textSecondary,
                ),
              ),
            ),
          ),
          Positioned(
            right: 10,
            bottom: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: context.c.sheet.withOpacity(0.55),
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Text(
                _duration,
                style: context.s.micro.copyWith(
                  color: context.c.textTertiary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
