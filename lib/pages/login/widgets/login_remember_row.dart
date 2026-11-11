import 'package:mengyu_app/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// v7 记住我：复选框用 lav，不再抢金色主操作。
class LoginRememberRow extends StatelessWidget {
  const LoginRememberRow({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        SizedBox(
          width: 20,
          height: 20,
          child: Checkbox(
            value: value,
            onChanged: enabled && onChanged != null
                ? (bool? checked) => onChanged!(checked ?? false)
                : null,
            activeColor: context.c.secondary,
            checkColor: context.c.onGold,
            side: BorderSide(color: context.c.stroke),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text('记住我', style: context.s.caption),
        const Spacer(),
        Text('保持登录状态', style: context.s.captionMuted),
      ],
    );
  }
}
