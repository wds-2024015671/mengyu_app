import 'package:mengyu_app/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// v7 日记标签：chip 8 圆角，选中 lav 淡填充，未选中 1px stroke。
class DiaryTagChips extends StatelessWidget {
  const DiaryTagChips({
    super.key,
    required this.available,
    required this.selected,
    required this.onToggle,
  });

  final List<String> available;
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: <Widget>[
        for (final String tag in available)
          FilterChip(
            label: Text(tag),
            selected: selected.contains(tag),
            onSelected: (bool _) => onToggle(tag),
            showCheckmark: false,
            backgroundColor: Colors.transparent,
            selectedColor: context.c.secondary.withOpacity(0.12),
            labelStyle: context.s.caption.copyWith(
              color: selected.contains(tag)
                  ? context.c.secondary
                  : context.c.textSecondary,
              fontWeight: selected.contains(tag)
                  ? FontWeight.w500
                  : FontWeight.w400,
            ),
            side: BorderSide(
              color: selected.contains(tag)
                  ? Colors.transparent
                  : context.c.stroke,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.chip),
            ),
            visualDensity: VisualDensity.compact,
          ),
      ],
    );
  }
}
