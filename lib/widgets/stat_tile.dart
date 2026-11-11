import 'package:mengyu_app/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import 'glass_card.dart';

/// v7 统计小卡：16/600 数字 + 10 t3 标签，填充卡，无阴影。
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.value,
    required this.label,
    this.unit,
    this.hint,
    this.icon,
    this.onTap,
    this.emphasize = false,
  });

  final String value;
  final String label;
  final String? unit;
  final String? hint;
  final IconData? icon;
  final VoidCallback? onTap;

  /// 最佳值用 gold；字号仍保持 v7 的 16/600。
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              if (icon != null) ...<Widget>[
                Icon(icon, size: 16, color: context.c.textTertiary),
                const SizedBox(width: AppSpacing.xs),
              ],
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.s.micro,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text.rich(
              TextSpan(
                children: <InlineSpan>[
                  TextSpan(
                    text: value,
                    style: context.s.subtitle.copyWith(
                      fontWeight: FontWeight.w600,
                      color: emphasize
                          ? context.c.primary
                          : context.c.textPrimary,
                    ),
                  ),
                  if (unit != null)
                    TextSpan(
                      text: ' $unit',
                      style: context.s.micro,
                    ),
                ],
              ),
            ),
          ),
          if (hint != null) ...<Widget>[
            const SizedBox(height: AppSpacing.xs),
            Text(
              hint!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.s.micro,
            ),
          ],
        ],
      ),
    );
  }
}
