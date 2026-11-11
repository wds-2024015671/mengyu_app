import 'package:mengyu_app/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// v7 声屿头部：20/600 标题 + 11 t2 副标题 + 右侧收藏筛选心。
class SoundHeader extends StatelessWidget {
  const SoundHeader({
    super.key,
    required this.onlyFavorites,
    required this.onToggleFavorites,
  });

  final bool onlyFavorites;
  final VoidCallback onToggleFavorites;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.page,
        AppSpacing.sm,
        0,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('声屿', style: context.s.title),
                const SizedBox(height: AppSpacing.xs),
                Text('把世界调成静音', style: context.s.caption),
              ],
            ),
          ),
          SizedBox(
            width: 44,
            height: 44,
            child: IconButton(
              onPressed: onToggleFavorites,
              tooltip: '仅看收藏',
              padding: EdgeInsets.zero,
              iconSize: 20,
              icon: Icon(
                onlyFavorites ? Icons.favorite : Icons.favorite_border,
                color: onlyFavorites
                    ? context.c.secondary
                    : context.c.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
