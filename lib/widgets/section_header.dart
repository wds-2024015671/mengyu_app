import 'package:mengyu_app/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

/// v7 区块标题：20/600 标题 + 可选说明 + 右侧 11/400 t2 文字链。
///
/// 默认上下留 24/8；页面需要贴合自定义布局时可传 padding 覆盖。
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.padding = const EdgeInsets.only(
      top: AppSpacing.section,
      bottom: AppSpacing.sm,
    ),
  });

  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final bool showAction = actionLabel != null && onAction != null;
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(title, style: context.s.title),
                if (subtitle != null) ...<Widget>[
                  const SizedBox(height: AppSpacing.xs),
                  Text(subtitle!, style: context.s.captionMuted),
                ],
              ],
            ),
          ),
          if (showAction)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 24),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                foregroundColor: context.c.textSecondary,
              ),
              child: Text(
                '$actionLabel ›',
                style: context.s.caption,
              ),
            ),
        ],
      ),
    );
  }
}
