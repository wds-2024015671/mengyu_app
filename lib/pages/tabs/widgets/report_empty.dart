import 'package:mengyu_app/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// v7 月迹空态：24 图标 + 11 t2 文案；可选文字按钮（补记/重试）。
class ReportEmpty extends StatelessWidget {
  const ReportEmpty({
    super.key,
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.page),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 24, color: context.c.textTertiary),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.s.caption,
            ),
            if (actionLabel != null) ...<Widget>[
              const SizedBox(height: AppSpacing.xs),
              TextButton(
                onPressed: onAction,
                style: TextButton.styleFrom(
                  foregroundColor: context.c.textSecondary,
                  textStyle: context.s.caption,
                  minimumSize: const Size(0, 32),
                ),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
