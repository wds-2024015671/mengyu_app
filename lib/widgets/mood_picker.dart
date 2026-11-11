import 'package:mengyu_app/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

/// 心情选择器：1–5，选中项放大并用 lav 描边，不再发光。
class MoodPicker extends StatelessWidget {
  const MoodPicker({
    super.key,
    required this.value,
    this.onChanged,
  });

  /// 当前心情 1–5；null 表示未选择。
  final int? value;

  /// 点击回调；为 null 时只读展示。
  final ValueChanged<int>? onChanged;

  static const List<IconData> _icons = <IconData>[
    Icons.sentiment_very_dissatisfied,
    Icons.sentiment_dissatisfied,
    Icons.sentiment_neutral,
    Icons.sentiment_satisfied,
    Icons.sentiment_very_satisfied,
  ];

  static const List<String> _labels = <String>['糟糕', '低落', '平静', '不错', '很好'];

  @override
  Widget build(BuildContext context) {
    final ValueChanged<int>? onSelect = onChanged;
    return Row(
      children: <Widget>[
        for (int i = 0; i < _icons.length; i++) ...<Widget>[
          if (i > 0) const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _MoodOption(
              icon: _icons[i],
              label: _labels[i],
              selected: value == i + 1,
              onTap: onSelect == null ? null : () => onSelect(i + 1),
            ),
          ),
        ],
      ],
    );
  }
}

class _MoodOption extends StatelessWidget {
  const _MoodOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color tint = selected ? context.c.secondary : context.c.textTertiary;
    return Semantics(
      button: onTap != null,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AnimatedScale(
              scale: selected ? 1.12 : 1,
              duration: AppMotion.base,
              curve: AppMotion.curve,
              child: AnimatedContainer(
                duration: AppMotion.base,
                curve: AppMotion.curve,
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.transparent,
                  border: Border.all(
                    color: selected ? context.c.secondary : context.c.stroke,
                  ),
                ),
                child: Icon(icon, size: 20, color: tint),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: context.s.micro.copyWith(
                color: tint,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
