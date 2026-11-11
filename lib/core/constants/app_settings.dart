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

/// 默认定时与定时页共用同一组快捷选项；自定义范围 1–180 分钟。
const List<int> kTimerOptions = <int>[5, 10, 15, 20];
const int kMinTimerMinutes = 1;
const int kMaxTimerMinutes = 180;

bool isValidTimerMinutes(int minutes) =>
    minutes >= kMinTimerMinutes && minutes <= kMaxTimerMinutes;

/// 设置 prefs 的默认值。
const AppThemeMode kDefaultThemeMode = AppThemeMode.dark;
const int kDefaultTimerMinutes = 10;
