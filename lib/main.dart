import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/constants/app_settings.dart';
import 'data/repositories/local/local_settings_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AppThemeMode initialTheme = kDefaultThemeMode;
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    initialTheme = AppThemeMode.fromName(
      prefs.getString(LocalSettingsRepository.themeKey),
    );
  } catch (_) {
    // 读设置失败时仍要能进入 App；后续 SettingsProvider 会重试。
  }

  // 锁定竖屏：360×800 是验收基准，横屏会让图表与播放器排版失去意义。
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);

  // 第一帧就按已保存主题设置状态栏，避免浅色主题闪一下深色图标。
  final bool dark = initialTheme == AppThemeMode.dark ||
      (initialTheme == AppThemeMode.system &&
          WidgetsBinding.instance.platformDispatcher.platformBrightness ==
              Brightness.dark);
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
      statusBarBrightness: dark ? Brightness.dark : Brightness.light,
    ),
  );

  runApp(MengYuApp(initialThemeMode: initialTheme));
}
