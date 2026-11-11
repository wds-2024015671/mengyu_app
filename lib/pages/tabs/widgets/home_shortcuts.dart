import 'package:mengyu_app/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_theme.dart';

/// v7 快捷入口：3 等分纯文字/图标入口，不再使用玻璃卡和大圆按钮。
class HomeShortcuts extends StatelessWidget {
  const HomeShortcuts({super.key, required this.onOpenReport});

  final VoidCallback onOpenReport;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _Shortcut(
            icon: Icons.air,
            label: '呼吸',
            onTap: () => Navigator.pushNamed(context, AppRoutes.breathing),
          ),
        ),
        Expanded(
          child: _Shortcut(
            icon: Icons.menu_book_outlined,
            label: '日记',
            onTap: () => Navigator.pushNamed(context, AppRoutes.diary),
          ),
        ),
        Expanded(
          child: _Shortcut(
            icon: Icons.nightlight_outlined,
            label: '月迹',
            onTap: onOpenReport,
          ),
        ),
      ],
    );
  }
}

class _Shortcut extends StatelessWidget {
  const _Shortcut({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Column(
          children: <Widget>[
            Icon(icon, size: 20, color: context.c.textSecondary),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              style: context.s.caption.copyWith(
                color: context.c.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
