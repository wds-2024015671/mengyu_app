import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter/foundation.dart';

import '../core/constants/app_settings.dart';
import '../core/constants/sleep_settings.dart';
import '../core/errors/app_exception.dart';
import '../data/repositories/settings_repository.dart';
import '../data/services/app_data_cleaner.dart';

/// 设置状态：主题、默认定时、清除本地数据。
class SettingsProvider extends ChangeNotifier {
  SettingsProvider(
    this._repository,
    this._cleaner, {
    AppThemeMode? initialThemeMode,
  }) : _themeMode = initialThemeMode ?? kDefaultThemeMode;

  final SettingsRepository _repository;
  final AppDataCleaner _cleaner;

  AppThemeMode _themeMode;
  int _defaultTimerMinutes = kDefaultTimerMinutes;
  bool _autoSleepTracking = true;
  bool _morningReminder = true;
  int _reminderMinutes = kDefaultReminderMinutes;
  bool _loaded = false;
  bool _loading = false;
  bool _clearing = false;
  String? _error;

  AppThemeMode get themeModeSetting => _themeMode;
  ThemeMode get themeMode => _themeMode.themeMode;
  int get defaultTimerMinutes => _defaultTimerMinutes;
  bool get autoSleepTracking => _autoSleepTracking;
  bool get morningReminder => _morningReminder;
  int get reminderMinutes => _reminderMinutes;
  bool get isLoaded => _loaded;
  bool get isLoading => _loading;
  bool get isClearing => _clearing;
  String? get error => _error;

  Future<void> ensureLoaded() {
    if (_loaded || _loading) {
      return Future<void>.value();
    }
    return load();
  }

  Future<void> load() async {
    if (_loading) {
      return;
    }
    _loading = true;
    try {
      _themeMode = await _repository.readThemeMode();
      _defaultTimerMinutes = await _repository.readDefaultTimerMinutes();
      _autoSleepTracking = await _repository.readAutoSleepTracking();
      _morningReminder = await _repository.readMorningReminder();
      _reminderMinutes = await _repository.readReminderMinutes();
      _error = null;
    } catch (error) {
      _error = AppException.describe(error, fallback: '读取设置失败');
    } finally {
      _loading = false;
      _loaded = true;
      notifyListeners();
    }
  }

  Future<bool> setThemeMode(AppThemeMode mode) async {
    if (_themeMode == mode) {
      return true;
    }
    final AppThemeMode previous = _themeMode;
    _themeMode = mode;
    _error = null;
    notifyListeners();
    try {
      await _repository.writeThemeMode(mode);
      return true;
    } catch (error) {
      _themeMode = previous;
      _error = AppException.describe(error, fallback: '保存主题失败');
      notifyListeners();
      return false;
    }
  }

  Future<bool> setDefaultTimerMinutes(int minutes) async {
    if (!kTimerOptions.contains(minutes) ||
        _defaultTimerMinutes == minutes) {
      return true;
    }
    final int previous = _defaultTimerMinutes;
    _defaultTimerMinutes = minutes;
    _error = null;
    notifyListeners();
    try {
      await _repository.writeDefaultTimerMinutes(minutes);
      return true;
    } catch (error) {
      _defaultTimerMinutes = previous;
      _error = AppException.describe(error, fallback: '保存默认定时失败');
      notifyListeners();
      return false;
    }
  }

  Future<bool> setAutoSleepTracking(bool enabled) async {
    if (_autoSleepTracking == enabled) {
      return true;
    }
    final bool previous = _autoSleepTracking;
    _autoSleepTracking = enabled;
    _error = null;
    notifyListeners();
    try {
      await _repository.writeAutoSleepTracking(enabled);
      return true;
    } catch (error) {
      _autoSleepTracking = previous;
      _error = AppException.describe(error, fallback: '保存睡眠记录开关失败');
      notifyListeners();
      return false;
    }
  }

  Future<bool> setMorningReminder(bool enabled) async {
    if (_morningReminder == enabled) {
      return true;
    }
    final bool previous = _morningReminder;
    _morningReminder = enabled;
    _error = null;
    notifyListeners();
    try {
      await _repository.writeMorningReminder(enabled);
      return true;
    } catch (error) {
      _morningReminder = previous;
      _error = AppException.describe(error, fallback: '保存晨间提醒失败');
      notifyListeners();
      return false;
    }
  }

  Future<bool> setReminderMinutes(int minutes) async {
    if (!kReminderOptions.contains(minutes) || _reminderMinutes == minutes) {
      return true;
    }
    final int previous = _reminderMinutes;
    _reminderMinutes = minutes;
    _error = null;
    notifyListeners();
    try {
      await _repository.writeReminderMinutes(minutes);
      return true;
    } catch (error) {
      _reminderMinutes = previous;
      _error = AppException.describe(error, fallback: '保存提醒时间失败');
      notifyListeners();
      return false;
    }
  }

  /// 清除 SQLite + prefs；成功后设置恢复默认（深色 / 30 分钟）。
  Future<bool> clearAllData() async {
    if (_clearing) {
      return false;
    }
    _clearing = true;
    _error = null;
    notifyListeners();
    try {
      await _cleaner.clear();
      _themeMode = kDefaultThemeMode;
      _defaultTimerMinutes = kDefaultTimerMinutes;
      _autoSleepTracking = true;
      _morningReminder = true;
      _reminderMinutes = kDefaultReminderMinutes;
      _loaded = true;
      return true;
    } catch (error) {
      _error = AppException.describe(error, fallback: '清除数据失败，请稍后再试');
      return false;
    } finally {
      _clearing = false;
      notifyListeners();
    }
  }
}
