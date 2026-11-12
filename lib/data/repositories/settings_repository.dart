import '../../core/constants/app_settings.dart';

/// 设置数据源：主题与默认定时。
abstract class SettingsRepository {
  Future<AppThemeMode> readThemeMode();

  Future<int> readDefaultTimerMinutes();

  Future<void> writeThemeMode(AppThemeMode mode);

  Future<void> writeDefaultTimerMinutes(int minutes);
}
