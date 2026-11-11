import 'package:mengyu_app/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

/// v7 主按钮：44 高、14 圆角、gold 实底、13/600 深色文字。
///
/// 无渐变、无发光阴影；禁用态用 t3 实底，loading 时保留原宽度。
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.loading = false,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;

  /// 默认撑满父级宽度；放在 Row/Wrap 里请传 false，避免无界宽度报错。
  final bool expand;

  static const double _height = 44;

  @override
  Widget build(BuildContext context) {
    final bool hasAction = onPressed != null;
    final bool interactive = hasAction && !loading;
    final Color background = hasAction
        ? context.c.primary
        : context.c.textTertiary;
    final Color foreground = context.c.onGold;
    final BorderRadius radius = BorderRadius.circular(AppRadius.control);

    final Widget content;
    if (loading) {
      content = SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: foreground,
        ),
      );
    } else {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: 20, color: foreground),
            const SizedBox(width: AppSpacing.sm),
          ],
          Text(
            label,
            style: context.s.buttonLabel.copyWith(color: foreground),
          ),
        ],
      );
    }

    return Semantics(
      button: true,
      enabled: interactive,
      label: loading ? '$label，处理中' : label,
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: background,
          borderRadius: radius,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: radius,
          child: InkWell(
            onTap: interactive ? onPressed : null,
            borderRadius: radius,
            child: SizedBox(
              height: _height,
              width: expand ? double.infinity : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                ),
                child: Center(widthFactor: expand ? null : 1, child: content),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
