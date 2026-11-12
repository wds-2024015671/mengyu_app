import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_settings.dart';
import '../settings_repository.dart';

/// 本地设置：主题与默认定时写 shared_preferences。
class LocalSettingsRepository implements SettingsRepository {
  const LocalSettingsRepository();

  static const String themeKey = 'settings.theme_mode';
  static const String defaultTimerKey = 'settings.default_timer_minutes';
  static const String timerMigrationKey = 'settings.timer_migration_v2';

  @override
  Future<AppThemeMode> readThemeMode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return AppThemeMode.fromName(prefs.getString(themeKey));
  }

  @override
  Future<int> readDefaultTimerMinutes() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int raw = prefs.getInt(defaultTimerKey) ?? kDefaultTimerMinutes;
    // 旧版本的默认 30 分钟一次性迁移到新的 10 分钟；用户自定义的 45/60 保留。
    if (!(prefs.getBool(timerMigrationKey) ?? false)) {
      final int migrated = raw == 30 ? kDefaultTimerMinutes : raw;
      await prefs.setBool(timerMigrationKey, true);
      if (migrated != raw) {
        await prefs.setInt(defaultTimerKey, migrated);
      }
      return isValidTimerMinutes(migrated) ? migrated : kDefaultTimerMinutes;
    }
    return isValidTimerMinutes(raw) ? raw : kDefaultTimerMinutes;
  }

  @override
  Future<void> writeThemeMode(AppThemeMode mode) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(themeKey, mode.name);
  }

  @override
  Future<void> writeDefaultTimerMinutes(int minutes) async {
    if (!isValidTimerMinutes(minutes)) {
      return;
    }
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(defaultTimerKey, minutes);
  }
}
