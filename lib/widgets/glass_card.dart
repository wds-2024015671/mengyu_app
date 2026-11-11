import 'package:mengyu_app/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

/// v7 卡片：填充或 1px 描边二选一，20 圆角，无渐变、无阴影、无模糊。
///
/// outlined=false 用 fill；outlined=true 用 stroke。
/// 保留 highlight 参数兼容旧调用，命中时按描边卡处理。
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.margin = EdgeInsets.zero,
    this.onTap,
    this.outlined = false,
    this.highlight = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final VoidCallback? onTap;

  /// 描边卡：背景透明，只留 1px stroke。
  final bool outlined;

  /// 兼容旧 API：命中时使用 primary 描边。
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(AppRadius.card);
    final bool useStroke = outlined || highlight;
    final Widget content = Padding(padding: padding, child: child);

    return Padding(
      padding: margin,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: useStroke ? Colors.transparent : context.c.fill,
          borderRadius: radius,
          border: useStroke
              ? Border.all(
                  color: highlight ? context.c.primary : context.c.stroke,
                )
              : null,
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: Material(
            color: Colors.transparent,
            child: onTap == null
                ? content
                : InkWell(
                    borderRadius: radius,
                    onTap: onTap,
                    child: content,
                  ),
          ),
        ),
      ),
    );
  }
}
