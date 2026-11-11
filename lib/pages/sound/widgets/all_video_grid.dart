import 'package:flutter/material.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_tokens.dart';
import '../all_media_item.dart';
import 'media_select_circle.dart';

class AllVideoGrid extends StatelessWidget {
  const AllVideoGrid({
    super.key,
    required this.items,
    required this.selectionMode,
    required this.selectedKeys,
    required this.onTap,
  });

  final List<AllMediaItem> items;
  final bool selectionMode;
  final Set<String> selectedKeys;
  final ValueChanged<AllMediaItem> onTap;

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
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.lg,
          mainAxisExtent: 128,
        ),
        itemBuilder: (BuildContext context, int index) {
          final AllMediaItem item = items[index];
          return _VideoTile(
            item: item,
            selectionMode: selectionMode,
            selected: selectedKeys.contains(item.key),
            onTap: () => onTap(item),
          );
        },
      ),
    );
  }
}

class _VideoTile extends StatelessWidget {
  const _VideoTile({
    required this.item,
    required this.selectionMode,
    required this.selected,
    required this.onTap,
  });

  final AllMediaItem item;
  final bool selectionMode;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.control),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(
            height: 96,
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    color: context.c.cover,
                    borderRadius: BorderRadius.circular(AppRadius.control),
                    border: selected
                        ? Border.all(
                            color: context.c.secondary.withOpacity(0.55),
                          )
                        : null,
                  ),
                  child: Center(
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: context.c.sheet.withOpacity(0.55),
                        border: Border.all(color: context.c.textTertiary),
                      ),
                      child: Icon(
                        Icons.play_arrow,
                        size: 16,
                        color: context.c.textSecondary,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 6,
                  bottom: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: context.c.bgDeep.withOpacity(0.72),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(item.durationLabel, style: context.s.micro),
                  ),
                ),
                if (selectionMode)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: MediaSelectCircle(selected: selected),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.body.copyWith(
              color: context.c.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
