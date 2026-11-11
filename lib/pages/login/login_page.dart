import 'package:mengyu_app/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_background.dart';
import '../../widgets/primary_button.dart';
import 'widgets/login_brand.dart';
import 'widgets/login_fields.dart';
import 'widgets/login_mode_switch.dart';
import 'widgets/login_remember_row.dart';

/// 登录 / 注册同页：v7 表单外壳，校验与 AuthProvider 逻辑保持原样。
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _nickname = TextEditingController();

  bool _registerMode = false;
  bool _obscurePassword = true;
  bool _rememberMe = true;

  @override
  void initState() {
    super.initState();
    _rememberMe = context.read<AuthProvider>().rememberMe;
  }

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    _nickname.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AuthProvider auth = context.watch<AuthProvider>();
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness:
            isDark ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: context.c.bgDeep,
        body: AppBackground(
          tint: context.c.tintTonight,
          child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.page,
              AppSpacing.page,
              AppSpacing.page,
              AppSpacing.xxxl,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const LoginBrand(),
                  const SizedBox(height: AppSpacing.xxl),
                  Text(
                    _registerMode ? '初次见你' : '欢迎回来',
                    style: context.s.title,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    _registerMode ? '留下一个名字，岛会记得你。' : '用账号继续今夜的旅程。',
                    style: context.s.bodySecondary,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  LoginModeSwitch(
                    registerMode: _registerMode,
                    onChanged: (bool value) =>
                        setState(() => _registerMode = value),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  LoginUsernameField(
                    controller: _username,
                    enabled: !auth.isLoading,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  LoginPasswordField(
                    controller: _password,
                    enabled: !auth.isLoading,
                    obscured: _obscurePassword,
                    registerMode: _registerMode,
                    onToggleVisibility: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    onSubmitted: _submit,
                  ),
                  if (_registerMode) ...<Widget>[
                    const SizedBox(height: AppSpacing.md),
                    LoginNicknameField(
                      controller: _nickname,
                      enabled: !auth.isLoading,
                      onSubmitted: _submit,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  LoginRememberRow(
                    value: _rememberMe,
                    enabled: !auth.isLoading,
                    onChanged: _onRememberChanged,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  PrimaryButton(
                    label: _registerMode ? '注册并进入' : '登录',
                    loading: auth.isLoading,
                    onPressed: _submit,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextButton(
                    onPressed: auth.isLoading ? null : _enterAsGuest,
                    style: TextButton.styleFrom(
                      foregroundColor: context.c.textSecondary,
                      textStyle: context.s.caption,
                    ),
                    child: const Text('游客体验'),
                  ),
                ],
              ),
            ),
          ),
        ),
        ),
      ),
    );
  }

  void _onRememberChanged(bool value) {
    setState(() => _rememberMe = value);
    context.read<AuthProvider>().setRememberMe(value);
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final AuthProvider auth = context.read<AuthProvider>();
    await auth.setRememberMe(_rememberMe);
    if (!mounted) {
      return;
    }
    final String username = _username.text.trim();
    final String password = _password.text;
    final bool ok = _registerMode
        ? await auth.register(username, password, _nickname.text.trim())
        : await auth.login(username, password);
    if (!mounted) {
      return;
    }
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error ?? '操作失败，请稍后再试')),
      );
      return;
    }
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.home,
      (Route<dynamic> route) => false,
    );
  }

  void _enterAsGuest() {
    context.read<AuthProvider>().continueAsGuest();
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.home,
      (Route<dynamic> route) => false,
    );
  }
}
