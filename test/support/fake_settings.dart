import 'package:mengyu_app/core/constants/app_settings.dart';
import 'package:mengyu_app/data/repositories/settings_repository.dart';
import 'package:mengyu_app/data/services/app_data_cleaner.dart';

class FakeSettingsRepository implements SettingsRepository {
  FakeSettingsRepository({
    this.themeMode = kDefaultThemeMode,
    this.defaultTimerMinutes = kDefaultTimerMinutes,
  });

  AppThemeMode themeMode;
  int defaultTimerMinutes;
  bool fail = false;

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
