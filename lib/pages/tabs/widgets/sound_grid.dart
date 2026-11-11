import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/audio_item.dart';
import '../../../providers/favorite_provider.dart';
import 'sound_card.dart';

/// v7 声屿 2 列网格：间距 12，卡片固定 112 高。
class SoundGrid extends StatelessWidget {
  const SoundGrid({
    super.key,
    required this.items,
    required this.favorites,
    required this.onOpen,
    required this.onToggleFavorite,
  });

  final List<AudioItem> items;
  final FavoriteProvider favorites;
  final ValueChanged<AudioItem> onOpen;
  final ValueChanged<AudioItem> onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.sm,
        AppSpacing.page,
        AppSpacing.xxxl,
      ),
      physics: const AlwaysScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        mainAxisExtent: 112,
      ),
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        final AudioItem item = items[index];
        return SoundCard(
          item: item,
          isFavorite: favorites.isFavorite(item.id),
          onTap: () => onOpen(item),
          onToggleFavorite: () => onToggleFavorite(item),
        );
      },
    );
  }
}
