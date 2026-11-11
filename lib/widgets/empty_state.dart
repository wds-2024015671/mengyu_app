import 'package:mengyu_app/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import 'primary_button.dart';

/// v7 空态：24 图标 + 16/500 标题 + 11 t2 说明 + 可选 44 高主按钮。
///
/// 不再使用圆形玻璃底、28 圆角或渐变。
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.compact = false,
  });

  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  /// 卡片内的小空态用 compact，减少上下留白。
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.page,
        vertical: compact ? AppSpacing.lg : AppSpacing.xxl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 24, color: context.c.textTertiary),
          const SizedBox(height: AppSpacing.sm),
          Text(
            title,
            textAlign: TextAlign.center,
            style: context.s.subtitle,
          ),
          if (message != null) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: context.s.caption.copyWith(
                color: context.c.textSecondary,
              ),
            ),
          ],
          if (actionLabel != null) ...<Widget>[
            const SizedBox(height: AppSpacing.lg),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 220),
              child: PrimaryButton(
                label: actionLabel!,
                onPressed: onAction,
                expand: false,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
