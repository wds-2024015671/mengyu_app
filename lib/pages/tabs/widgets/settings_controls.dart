import 'package:mengyu_app/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// v7 设置选择按钮：44 高、14 圆角；选中 lav 填充，未选中 1px stroke。
class SettingsChoiceButton extends StatelessWidget {
  const SettingsChoiceButton({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(AppRadius.control);
    return Material(
      color: selected
          ? context.c.secondary.withOpacity(0.12)
          : Colors.transparent,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: radius,
            border: selected ? null : Border.all(color: context.c.stroke),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (icon != null) ...<Widget>[
                Icon(
                  icon,
                  size: 16,
                  color: selected
                      ? context.c.secondary
                      : context.c.textSecondary,
                ),
                const SizedBox(width: AppSpacing.xs),
              ],
              Text(
                label,
                style: context.s.body.copyWith(
                  color: selected
                      ? context.c.secondary
                      : context.c.textSecondary,
                  fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// v7 设置菜单行：48 高、上下 1px stroke。
class SettingsMenuRow extends StatelessWidget {
  const SettingsMenuRow({
    super.key,
    required this.label,
    required this.trailing,
    required this.onTap,
  });

  final String label;
  final String trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: context.c.stroke),
          ),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                label,
                style: context.s.body.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(trailing, style: context.s.captionMuted),
            const SizedBox(width: AppSpacing.xs),
            Icon(
              Icons.chevron_right,
              size: 16,
              color: context.c.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
