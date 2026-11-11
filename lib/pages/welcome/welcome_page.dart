import 'package:mengyu_app/core/theme/app_tokens.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/routes/app_routes.dart';
import '../../providers/auth_provider.dart';
import 'welcome_backdrop.dart';
import 'welcome_modal.dart';

/// v7 欢迎浮层：今晚页底图 + 300 宽弹窗；首次显示，已看过 300ms 淡出分流。
class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  static const String _seenKey = 'welcome_seen';

  late final Future<void> _authReady;
  Timer? _redirectTimer;
  bool _visible = true;
  bool _showModal = false;
  bool _closing = false;

  @override
  void initState() {
    super.initState();
    _authReady = context.read<AuthProvider>().ensureLoaded();
    _decide();
  }

  Future<void> _decide() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool seen = prefs.getBool(_seenKey) ?? false;
    if (!mounted) {
      return;
    }
    if (seen) {
      setState(() => _visible = false);
      _redirectTimer = Timer(
        const Duration(milliseconds: 300),
        _goNext,
      );
    } else {
      setState(() => _showModal = true);
    }
  }

  Future<void> _close() async {
    if (_closing) {
      return;
    }
    _closing = true;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_seenKey, true);
    await _goNext();
  }

  Future<void> _goNext() async {
    await _authReady;
    if (!mounted) {
      return;
    }
    final AuthProvider auth = context.read<AuthProvider>();
    Navigator.pushReplacementNamed(
      context,
      auth.hasSession ? AppRoutes.home : AppRoutes.login,
    );
  }

  @override
  void dispose() {
    _redirectTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        body: AnimatedOpacity(
          opacity: _visible ? 1 : 0,
          duration: const Duration(milliseconds: 300),
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              const WelcomeBackdrop(),
              if (_showModal) ...<Widget>[
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _close,
                    child: ColoredBox(color: context.c.overlay),
                  ),
                ),
                Center(
                  child: WelcomeModal(
                    onClose: _close,
                    onStart: _close,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
