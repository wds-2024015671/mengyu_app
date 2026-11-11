import 'package:mengyu_app/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../widgets/primary_button.dart';

/// v7 欢迎浮层：300 宽 #12152B 弹窗，X / 按钮关闭。
class WelcomeModal extends StatelessWidget {
  const WelcomeModal({
    super.key,
    required this.onClose,
    required this.onStart,
  });

  final VoidCallback onClose;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxl,
          vertical: AppSpacing.xl,
        ),
        decoration: BoxDecoration(
          color: context.c.sheet,
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Align(
              alignment: Alignment.topRight,
              child: SizedBox(
                width: 24,
                height: 24,
                child: IconButton(
                  onPressed: onClose,
                  tooltip: '关闭',
                  padding: EdgeInsets.zero,
                  iconSize: 20,
                  icon: Icon(
                    Icons.close,
                    color: context.c.textSecondary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Icon(
              Icons.nightlight_round,
              size: 48,
              color: context.c.textPrimary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'WELCOME TO MENGYU',
              textAlign: TextAlign.center,
              style: context.s.kicker,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '欢迎来到梦屿',
              textAlign: TextAlign.center,
              style: context.s.title,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              '今晚，把世界调成静音。给自己 15 分钟：呼吸、声音、写一句晚安。',
              textAlign: TextAlign.center,
              style: context.s.bodySecondary,
            ),
            const SizedBox(height: AppSpacing.xxl),
            PrimaryButton(
              label: '开始今晚的仪式',
              onPressed: onStart,
            ),
          ],
        ),
      ),
    );
  }
}
