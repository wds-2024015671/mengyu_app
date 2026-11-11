import 'package:flutter/material.dart';

/// 主题三档：深色 / 浅色 / 跟随系统。
enum AppThemeMode {
  dark,
  light,
  system;

  String get label {
    return switch (this) {
      AppThemeMode.dark => '深色',
      AppThemeMode.light => '浅色',
      AppThemeMode.system => '跟随系统',
    };
  }

  IconData get icon {
    return switch (this) {
      AppThemeMode.dark => Icons.dark_mode_outlined,
      AppThemeMode.light => Icons.light_mode_outlined,
      AppThemeMode.system => Icons.brightness_auto_outlined,
    };
  }

  ThemeMode get themeMode {
    return switch (this) {
      AppThemeMode.dark => ThemeMode.dark,
      AppThemeMode.light => ThemeMode.light,
      AppThemeMode.system => ThemeMode.system,
    };
  }

  static AppThemeMode fromName(String? value) {
    return AppThemeMode.values.firstWhere(
      (AppThemeMode mode) => mode.name == value,
      orElse: () => AppThemeMode.dark,
    );
  }
}

/// 默认定时与设置弹窗共用同一组选项。
const List<int> kTimerOptions = <int>[15, 30, 45, 60, 90];

/// 设置 prefs 的默认值。
const AppThemeMode kDefaultThemeMode = AppThemeMode.dark;
const int kDefaultTimerMinutes = 30;
