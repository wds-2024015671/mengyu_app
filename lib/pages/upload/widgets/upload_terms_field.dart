import 'package:mengyu_app/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// 版权承诺：FormField 包住 Checkbox，提交时和普通字段一起校验，
/// 避免用 SnackBar 提示“还没勾选”导致用户不知道要回滚到哪一项。
class UploadTermsField extends StatelessWidget {
  const UploadTermsField({super.key, required this.enabled});

  final bool enabled;

  static const String _termsText =
      '我确认拥有这段音频的版权或已获得授权，并同意审核通过后公开到梦屿公共声库。';

  @override
  Widget build(BuildContext context) {
    return FormField<bool>(
      initialValue: false,
      validator: (bool? value) =>
          value == true ? null : '请勾选版权承诺后再提交',
      builder: (FormFieldState<bool> state) {
        final bool checked = state.value ?? false;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: checked,
                    onChanged: enabled
                        ? (bool? value) => state.didChange(value ?? false)
                        : null,
                    activeColor: context.c.secondary,
                    checkColor: context.c.onGold,
                    side: BorderSide(color: context.c.stroke),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: enabled
                        ? () => state.didChange(!checked)
                        : null,
                    child: Text(
                      _termsText,
                      style: context.s.caption,
                    ),
                  ),
                ),
              ],
            ),
            if (state.hasError) ...<Widget>[
              const SizedBox(height: AppSpacing.xs),
              Padding(
                padding: const EdgeInsets.only(left: 32),
                child: Text(
                  state.errorText!,
                  style: context.s.caption.copyWith(
                    color: context.c.danger,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
