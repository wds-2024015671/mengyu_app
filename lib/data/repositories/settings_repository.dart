import '../../core/constants/app_settings.dart';

/// 设置数据源：主题、默认定时、睡眠自动记录与晨间提醒。
abstract class SettingsRepository {
  Future<AppThemeMode> readThemeMode();

  Future<int> readDefaultTimerMinutes();

  Future<bool> readAutoSleepTracking();

  Future<bool> readMorningReminder();

  Future<int> readReminderMinutes();

  Future<void> writeThemeMode(AppThemeMode mode);

  Future<void> writeDefaultTimerMinutes(int minutes);

  Future<void> writeAutoSleepTracking(bool enabled);

  Future<void> writeMorningReminder(bool enabled);

  Future<void> writeReminderMinutes(int minutes);
}
