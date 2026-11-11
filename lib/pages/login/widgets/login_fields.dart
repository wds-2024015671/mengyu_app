import 'package:mengyu_app/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';


String? validateUsername(String? value) {
  final String text = (value ?? '').trim();
  if (text.length < 3 || text.length > 20) {
    return '用户名需 3–20 个字符';
  }
  return null;
}

String? validatePassword(String? value) {
  final String text = value ?? '';
  if (text.length < 6 || text.length > 32) {
    return '密码需 6–32 个字符';
  }
  return null;
}

String? validateNickname(String? value) {
  final String text = (value ?? '').trim();
  if (text.isEmpty || text.length > 32) {
    return '昵称需 1–32 个字符';
  }
  return null;
}

class LoginUsernameField extends StatelessWidget {
  const LoginUsernameField({
    super.key,
    required this.controller,
    required this.enabled,
  });

  final TextEditingController controller;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      textInputAction: TextInputAction.next,
      autofillHints: const <String>[AutofillHints.username],
      decoration: InputDecoration(
        hintText: '用户名',
        hintStyle: context.s.caption,
        filled: false,
        isDense: true,
        prefixIcon: Icon(
          Icons.person_outline,
          size: 20,
          color: context.c.textSecondary,
        ),
      ),
      validator: validateUsername,
    );
  }
}

class LoginPasswordField extends StatelessWidget {
  const LoginPasswordField({
    super.key,
    required this.controller,
    required this.enabled,
    required this.obscured,
    required this.registerMode,
    required this.onToggleVisibility,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final bool enabled;
  final bool obscured;
  final bool registerMode;
  final VoidCallback onToggleVisibility;
  final VoidCallback onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      obscureText: obscured,
      textInputAction:
          registerMode ? TextInputAction.next : TextInputAction.done,
      onFieldSubmitted: (_) {
        if (!registerMode) {
          onSubmitted();
        }
      },
      autofillHints: const <String>[AutofillHints.password],
      decoration: InputDecoration(
        hintText: '密码',
        hintStyle: context.s.caption,
        filled: false,
        isDense: true,
        prefixIcon: Icon(
          Icons.lock_outline,
          size: 20,
          color: context.c.textSecondary,
        ),
        suffixIcon: IconButton(
          onPressed: onToggleVisibility,
          tooltip: obscured ? '显示密码' : '隐藏密码',
          iconSize: 20,
          icon: Icon(
            obscured
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: context.c.textSecondary,
          ),
        ),
      ),
      validator: validatePassword,
    );
  }
}

class LoginNicknameField extends StatelessWidget {
  const LoginNicknameField({
    super.key,
    required this.controller,
    required this.enabled,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final bool enabled;
  final VoidCallback onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      textInputAction: TextInputAction.done,
      maxLength: 32,
      decoration: InputDecoration(
        hintText: '昵称',
        hintStyle: context.s.caption,
        filled: false,
        isDense: true,
        prefixIcon: Icon(
          Icons.badge_outlined,
          size: 20,
          color: context.c.textSecondary,
        ),
        counterText: '',
      ),
      validator: validateNickname,
      onFieldSubmitted: (_) => onSubmitted(),
    );
  }
}
