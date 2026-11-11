import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mengyu_app/app.dart';
import 'package:mengyu_app/core/constants/app_settings.dart';
import 'package:mengyu_app/core/constants/sleep_settings.dart';
import 'package:mengyu_app/data/repositories/local/local_settings_repository.dart';
import 'package:mengyu_app/providers/settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fake_audio_engine.dart';
import 'support/fake_settings.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('主题/默认定时写 prefs，重建 Provider 后仍能读回', () async {
    const LocalSettingsRepository repository = LocalSettingsRepository();
    final SettingsProvider provider = SettingsProvider(
      repository,
      FakeAppDataCleaner(),
    );
    addTearDown(provider.dispose);

    await provider.load();
    expect(provider.themeModeSetting, AppThemeMode.dark);
    expect(provider.defaultTimerMinutes, 10);
    expect(provider.autoSleepTracking, isTrue);
    expect(provider.morningReminder, isTrue);
    expect(provider.reminderMinutes, 450);

    expect(await provider.setThemeMode(AppThemeMode.light), isTrue);
    expect(await provider.setDefaultTimerMinutes(45), isTrue);
    expect(await provider.setAutoSleepTracking(false), isTrue);
    expect(await provider.setMorningReminder(false), isTrue);
    expect(await provider.setReminderMinutes(390), isTrue);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(LocalSettingsRepository.themeKey), 'light');
    expect(prefs.getInt(LocalSettingsRepository.defaultTimerKey), 45);
    expect(prefs.getBool(kAutoSleepTrackingKey), isFalse);
    expect(prefs.getBool(kMorningReminderKey), isFalse);
    expect(prefs.getInt(kReminderMinutesKey), 390);

    final SettingsProvider reloaded = SettingsProvider(
      repository,
      FakeAppDataCleaner(),
    );
    addTearDown(reloaded.dispose);
    await reloaded.load();
    expect(reloaded.themeModeSetting, AppThemeMode.light);
    expect(reloaded.defaultTimerMinutes, 45);
    expect(reloaded.autoSleepTracking, isFalse);
    expect(reloaded.morningReminder, isFalse);
    expect(reloaded.reminderMinutes, 390);
    expect(reloaded.themeMode, ThemeMode.light);

    // 非法时长不覆盖已有值
    expect(await provider.setDefaultTimerMinutes(0), isTrue);
    expect(provider.defaultTimerMinutes, 45);
  });

  test('旧默认 30 分钟迁移到 10，历史自定义 45 保留', () async {
    const LocalSettingsRepository repository = LocalSettingsRepository();

    SharedPreferences.setMockInitialValues(<String, Object>{
      LocalSettingsRepository.defaultTimerKey: 30,
    });
    expect(await repository.readDefaultTimerMinutes(), 10);
    final SharedPreferences migrated = await SharedPreferences.getInstance();
    expect(migrated.getInt(LocalSettingsRepository.defaultTimerKey), 10);

    SharedPreferences.setMockInitialValues(<String, Object>{
      LocalSettingsRepository.defaultTimerKey: 45,
    });
    expect(await repository.readDefaultTimerMinutes(), 45);
  });

  test('清除数据调用 cleaner，并把主题/定时恢复默认', () async {
    final FakeSettingsRepository repository = FakeSettingsRepository(
      themeMode: AppThemeMode.light,
      defaultTimerMinutes: 60,
    );
    final FakeAppDataCleaner cleaner = FakeAppDataCleaner();
    final SettingsProvider provider = SettingsProvider(repository, cleaner);
    addTearDown(provider.dispose);
    await provider.load();
    expect(provider.themeModeSetting, AppThemeMode.light);

    expect(await provider.clearAllData(), isTrue);
    expect(cleaner.cleared, isTrue);
    expect(provider.themeModeSetting, AppThemeMode.dark);
    expect(provider.defaultTimerMinutes, 10);
    expect(provider.isClearing, isFalse);
  });

  testWidgets('预存浅色主题：App 启动后 MaterialApp.themeMode 为 light', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'welcome_seen': true,
      LocalSettingsRepository.themeKey: 'light',
    });
    await tester.pumpWidget(
      MengYuApp(audioEngineFactory: () => FakeAudioEngine()),
    );
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    final MaterialApp app = tester.widget<MaterialApp>(
      find.byType(MaterialApp),
    );
    expect(app.themeMode, ThemeMode.light);
    expect(tester.takeException(), isNull);
  });
}
