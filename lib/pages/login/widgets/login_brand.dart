import 'package:mengyu_app/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// v7 登录品牌：48 月亮 + 梦屿 20/600 + 一句 11 t2。
class LoginBrand extends StatelessWidget {
  const LoginBrand({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(
          Icons.nightlight_round,
          size: 48,
          color: context.c.textPrimary,
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('梦屿', style: context.s.title),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '在声音里，慢慢睡着',
                style: context.s.caption.copyWith(
                  color: context.c.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
