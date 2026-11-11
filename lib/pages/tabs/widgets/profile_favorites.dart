import 'package:mengyu_app/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/audio_item.dart';
import '../../../widgets/section_header.dart';

/// v7 我的收藏：横向最多 3 张填充卡，全部入口走底部弹层。
class ProfileFavorites extends StatelessWidget {
  const ProfileFavorites({
    super.key,
    required this.items,
    required this.total,
    required this.onOpen,
    required this.onShowAll,
  });

  final List<AudioItem> items;
  final int total;
  final ValueChanged<AudioItem> onOpen;
  final VoidCallback onShowAll;

  @override
  Widget build(BuildContext context) {
    final List<AudioItem> preview = items.take(3).toList(growable: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SectionHeader(
          title: '我的收藏',
          actionLabel: '全部 $total',
          onAction: onShowAll,
        ),
        if (preview.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Text('还没有收藏', style: context.s.caption),
          )
        else
          SizedBox(
            height: 106,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: preview.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: AppSpacing.md),
              itemBuilder: (BuildContext context, int index) {
                return _FavoriteCard(
                  item: preview[index],
                  onTap: () => onOpen(preview[index]),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  const _FavoriteCard({required this.item, required this.onTap});

  final AudioItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(AppRadius.control);
    return SizedBox(
      width: 100,
      height: 106,
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Container(
            decoration: BoxDecoration(
              color: context.c.fill,
              borderRadius: radius,
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  height: 52,
                  color: context.c.cover,
                  child: Icon(
                    Icons.graphic_eq,
                    size: 20,
                    color: context.c.textSecondary,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.s.body.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
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
