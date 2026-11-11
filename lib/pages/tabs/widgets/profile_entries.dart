import 'package:mengyu_app/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import 'info_content.dart';

/// v7 我的菜单：顶部 1px stroke，48 高行，底部 1px stroke，无卡片。
class ProfileEntries extends StatelessWidget {
  const ProfileEntries({
    super.key,
    required this.onSettings,
    required this.onAbout,
    required this.onPurpose,
    required this.onTerms,
    required this.onLogout,
  });

  final VoidCallback onSettings;
  final VoidCallback onAbout;
  final VoidCallback onPurpose;
  final VoidCallback onTerms;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: context.c.stroke)),
      ),
      child: Column(
        children: <Widget>[
          _ProfileEntryRow(
            icon: Icons.tune,
            label: '设置',
            trailing: '主题 · 定时 · 清理',
            onTap: onSettings,
          ),
          _ProfileEntryRow(
            icon: Icons.info_outline,
            label: '关于梦屿',
            trailing: 'v1.0.0',
            onTap: onAbout,
          ),
          _ProfileEntryRow(
            icon: Icons.lightbulb_outline,
            label: AppInfoCopy.purposeTitle,
            trailing: AppInfoCopy.purposeSummary,
            onTap: onPurpose,
          ),
          _ProfileEntryRow(
            icon: Icons.description_outlined,
            label: AppInfoCopy.termsTitle,
            trailing: AppInfoCopy.termsSummary,
            onTap: onTerms,
          ),
          _ProfileEntryRow(
            icon: Icons.logout,
            label: '退出登录',
            onTap: onLogout,
          ),
        ],
      ),
    );
  }
}

class _ProfileEntryRow extends StatelessWidget {
  const _ProfileEntryRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: context.c.stroke)),
        ),
        child: Row(
          children: <Widget>[
            Icon(icon, size: 20, color: context.c.textSecondary),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: context.s.body.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (trailing != null)
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: Text(trailing!, style: context.s.captionMuted),
              ),
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
