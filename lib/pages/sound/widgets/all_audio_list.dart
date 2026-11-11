import 'package:flutter/material.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_tokens.dart';
import '../all_media_item.dart';
import 'media_select_circle.dart';

class AllAudioList extends StatelessWidget {
  const AllAudioList({
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
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: context.c.stroke),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: <Widget>[
          for (int i = 0; i < items.length; i++) ...<Widget>[
            _AudioRow(
              item: items[i],
              selectionMode: selectionMode,
              selected: selectedKeys.contains(items[i].key),
              onTap: () => onTap(items[i]),
            ),
            if (i != items.length - 1)
              Divider(height: 1, thickness: 1, color: context.c.stroke),
          ],
        ],
      ),
    );
  }
}

class _AudioRow extends StatelessWidget {
  const _AudioRow({
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
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        color: selected ? context.c.secondary.withOpacity(0.08) : null,
        child: Row(
          children: <Widget>[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: context.c.cover,
                borderRadius: BorderRadius.circular(AppRadius.control),
              ),
              child: Icon(item.icon, size: 20, color: context.c.textSecondary),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body.copyWith(
                  color: context.c.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(item.durationLabel, style: context.s.micro),
            const SizedBox(width: AppSpacing.md),
            if (selectionMode)
              MediaSelectCircle(selected: selected)
            else
              Icon(
                Icons.play_arrow,
                size: 16,
                color: context.c.textSecondary,
              ),
          ],
        ),
      ),
    );
  }
}
