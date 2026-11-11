import 'package:flutter/material.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_tokens.dart';
import 'media_select_circle.dart';

class MediaBatchBar extends StatelessWidget {
  const MediaBatchBar({
    super.key,
    required this.selectedCount,
    required this.total,
    required this.allSelected,
    required this.onToggleAll,
    required this.onDelete,
  });

  final int selectedCount;
  final int total;
  final bool allSelected;
  final VoidCallback onToggleAll;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final bool enabled = selectedCount > 0;
    return Container(
      decoration: BoxDecoration(
        color: context.c.bgDeep,
        border: Border(top: BorderSide(color: context.c.stroke)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
            child: Row(
            children: <Widget>[
              Expanded(
                child: InkWell(
                  onTap: onToggleAll,
                  child: Row(
                    children: <Widget>[
                      MediaSelectCircle(selected: allSelected),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        '全选',
                        style: AppTextStyles.body.copyWith(
                          color: context.c.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Text(
                '已选 $selectedCount / $total',
                style: context.s.captionMuted,
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Opacity(
                    opacity: enabled ? 1 : 0.35,
                    child: InkWell(
                      onTap: onDelete,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            Icons.delete_outline,
                            size: 16,
                            color: context.c.primary,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            '删除',
                            style: AppTextStyles.body.copyWith(
                              color: context.c.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
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
