import 'package:flutter/material.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_tokens.dart';

class AllMediaHeader extends StatelessWidget {
  const AllMediaHeader({
    super.key,
    required this.title,
    required this.countLabel,
    required this.selectionMode,
    required this.onBack,
    required this.onModeToggle,
    this.showManage = true,
  });

  final String title;
  final String countLabel;
  final bool selectionMode;
  final VoidCallback onBack;
  final VoidCallback onModeToggle;
  final bool showManage;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Row(
        children: <Widget>[
          InkWell(
            onTap: onBack,
            customBorder: const CircleBorder(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: context.c.stroke),
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 20,
                color: context.c.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.title.copyWith(
                    color: context.c.textPrimary,
                  ),
                ),
                Text(countLabel, style: context.s.captionMuted),
              ],
            ),
          ),
          if (showManage)
            TextButton(
              onPressed: onModeToggle,
              style: TextButton.styleFrom(
                minimumSize: const Size(44, 44),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                foregroundColor: selectionMode
                    ? context.c.secondary
                    : context.c.textSecondary,
              ),
              child: Text(
                selectionMode ? '取消' : '管理',
                style: AppTextStyles.body.copyWith(
                  color: selectionMode
                      ? context.c.secondary
                      : context.c.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
