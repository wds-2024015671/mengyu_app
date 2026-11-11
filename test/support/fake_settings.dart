import 'package:mengyu_app/core/constants/app_settings.dart';
import 'package:mengyu_app/core/constants/sleep_settings.dart';
import 'package:mengyu_app/data/repositories/settings_repository.dart';
import 'package:mengyu_app/data/services/app_data_cleaner.dart';

class FakeSettingsRepository implements SettingsRepository {
  FakeSettingsRepository({
    this.themeMode = kDefaultThemeMode,
    this.defaultTimerMinutes = kDefaultTimerMinutes,
    this.autoSleepTracking = true,
    this.morningReminder = true,
    this.reminderMinutes = kDefaultReminderMinutes,
  });

  AppThemeMode themeMode;
  int defaultTimerMinutes;
  bool autoSleepTracking;
  bool morningReminder;
  int reminderMinutes;
  bool fail = false;

  @override
  Future<bool> readAutoSleepTracking() async {
    if (fail) {
      throw Exception('读取睡眠记录开关失败');
    }
    return autoSleepTracking;
  }

  @override
  Future<bool> readMorningReminder() async {
    if (fail) {
      throw Exception('读取晨间提醒失败');
    }
    return morningReminder;
  }

  @override
  Future<int> readReminderMinutes() async {
    if (fail) {
      throw Exception('读取提醒时间失败');
    }
    return reminderMinutes;
  }

  @override
  Future<void> writeAutoSleepTracking(bool enabled) async {
    if (fail) {
      throw Exception('保存睡眠记录开关失败');
    }
    autoSleepTracking = enabled;
  }

  @override
  Future<void> writeMorningReminder(bool enabled) async {
    if (fail) {
      throw Exception('保存晨间提醒失败');
    }
    morningReminder = enabled;
  }

  @override
  Future<void> writeReminderMinutes(int minutes) async {
    if (fail) {
      throw Exception('保存提醒时间失败');
    }
    reminderMinutes = minutes;
  }

  @override
  Future<AppThemeMode> readThemeMode() async {
    if (fail) {
      throw Exception('读取主题失败');
    }
    return themeMode;
  }

  @override
  Future<int> readDefaultTimerMinutes() async {
    if (fail) {
      throw Exception('读取默认定时失败');
    }
    return defaultTimerMinutes;
  }

  @override
  Future<void> writeThemeMode(AppThemeMode mode) async {    if (fail) {
      throw Exception('保存主题失败');
    }
    themeMode = mode;
  }

  @override
  Future<void> writeDefaultTimerMinutes(int minutes) async {
    if (fail) {
      throw Exception('保存默认定时失败');
    }
    defaultTimerMinutes = minutes;
  }
}

class FakeAppDataCleaner implements AppDataCleaner {
  bool cleared = false;
  bool fail = false;

  @override
  Future<void> clear() async {
    if (fail) {
      throw Exception('清除数据失败');
    }
    cleared = true;
  }
}
