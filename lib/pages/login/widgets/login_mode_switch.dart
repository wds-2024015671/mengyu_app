import 'package:mengyu_app/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// v7 登录/注册切换：36 高、999 圆角、1px stroke，选中 lav。
class LoginModeSwitch extends StatelessWidget {
  const LoginModeSwitch({
    super.key,
    required this.registerMode,
    required this.onChanged,
  });

  final bool registerMode;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: context.c.stroke),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _LoginModeTab(
              label: '登录',
              selected: !registerMode,
              onTap: () => onChanged(false),
            ),
          ),
          Expanded(
            child: _LoginModeTab(
              label: '注册',
              selected: registerMode,
              onTap: () => onChanged(true),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginModeTab extends StatelessWidget {
  const _LoginModeTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(AppRadius.pill);
    return Material(
      color: selected
          ? context.c.secondary.withOpacity(0.12)
          : Colors.transparent,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Center(
          child: Text(
            label,
            style: context.s.body.copyWith(
              color: selected ? context.c.secondary : context.c.textSecondary,
              fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}
