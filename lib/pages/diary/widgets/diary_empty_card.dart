import 'package:mengyu_app/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// v7 日记空态：24 图标 + 标题/说明，不使用玻璃卡。
class DiaryEmptyCard extends StatelessWidget {
  const DiaryEmptyCard({super.key, required this.onWrite});

  final VoidCallback onWrite;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
      child: Column(
        children: <Widget>[
          Icon(
            Icons.menu_book_outlined,
            size: 24,
            color: context.c.textTertiary,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text('还没有日记', style: context.s.subtitle),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '第一篇会出现在这里，从今晚的一句话开始。',
            textAlign: TextAlign.center,
            style: context.s.caption.copyWith(
              color: context.c.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton(
            onPressed: onWrite,
            style: TextButton.styleFrom(
              foregroundColor: context.c.textSecondary,
              textStyle: context.s.caption,
            ),
            child: const Text('写第一篇'),
          ),
        ],
      ),
    );
  }
}
