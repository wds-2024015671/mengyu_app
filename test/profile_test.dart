import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mengyu_app/core/constants/app_settings.dart';
import 'package:mengyu_app/core/routes/app_routes.dart';
import 'package:mengyu_app/core/theme/app_theme.dart';
import 'package:mengyu_app/data/repositories/local/local_auth_repository.dart';
import 'package:mengyu_app/data/repositories/local/local_sound_repository.dart';
import 'package:mengyu_app/data/services/avatar_service.dart';
import 'package:mengyu_app/models/audio_item.dart';
import 'package:mengyu_app/models/diary_entry.dart';
import 'package:mengyu_app/models/sleep_session.dart';
import 'package:mengyu_app/pages/tabs/profile_tab.dart';
import 'package:mengyu_app/providers/auth_provider.dart';
import 'package:mengyu_app/providers/avatar_provider.dart';
import 'package:mengyu_app/providers/diary_provider.dart';
import 'package:mengyu_app/providers/favorite_provider.dart';
import 'package:mengyu_app/providers/settings_provider.dart';
import 'package:mengyu_app/providers/sleep_provider.dart';
import 'package:mengyu_app/providers/sound_provider.dart';
import 'package:mengyu_app/providers/upload_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fake_avatar_service.dart';
import 'support/fake_diary_repository.dart';
import 'support/fake_favorite_repository.dart';
import 'support/fake_session_repository.dart';
import 'support/fake_settings.dart';
import 'support/fake_upload_repository.dart';

typedef ProfileHarness = ({
  AuthProvider auth,
  SleepProvider sleep,
  UploadProvider upload,
  DiaryProvider diary,
  FavoriteProvider favorite,
  SoundProvider sound,
  SettingsProvider settings,
  AvatarProvider avatar,
  FakeAvatarService avatarService,
  FakeAppDataCleaner cleaner,
});

Future<ProfileHarness> _pumpProfile(WidgetTester tester) async {
  tester.view.physicalSize = const Size(360, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final AuthProvider auth = AuthProvider(const LocalAuthRepository());
  await auth.ensureLoaded();

  final SleepProvider sleep = SleepProvider(
    FakeSessionRepository(<SleepSession>[
      for (int i = 0; i < 4; i++)
        SleepSession(
          bedTime: DateTime(2026, 11, 8 + i, 23),
          wakeTime: DateTime(2026, 11, 9 + i, 7),
          quality: 4,
        ),
    ]),
    clock: () => DateTime(2026, 11, 12),
  );
  final UploadProvider upload = UploadProvider(
    FakeUploadRepository(<AudioItem>[
      const AudioItem(
        id: 'upload_1',
        title: '雨声一',
        category: '雨声',
        sourceType: AudioSourceType.file,
        filePath: '/tmp/a.wav',
      ),
    ]),
  );
  final DiaryProvider diary = DiaryProvider(
    FakeDiaryRepository(
      seed: <DiaryEntry>[
        DiaryEntry(
          entryDate: DateTime(2026, 11, 9),
          mood: 4,
          content: '今晚的雨声很轻。',
        ),
      ],
    ),
  );
  final FavoriteProvider favorite = FavoriteProvider(
    FakeFavoriteRepository(<String>{'local_rain', 'local_fire', 'local_noise'}),
  );
  await favorite.ensureLoaded();
  final SoundProvider sound = SoundProvider(const LocalSoundRepository());
  await sound.loadLocal();
  final FakeAppDataCleaner cleaner = FakeAppDataCleaner();
  final SettingsProvider settings = SettingsProvider(
    FakeSettingsRepository(
      themeMode: AppThemeMode.dark,
      defaultTimerMinutes: 60,
    ),
    cleaner,
  );
  await settings.load();
  await diary.load();
  await upload.loadMyUploads();
  final FakeAvatarService avatarService = FakeAvatarService();
  final AvatarProvider avatar = AvatarProvider(avatarService);
  await avatar.ensureLoaded();

  addTearDown(auth.dispose);
  addTearDown(sleep.dispose);
  addTearDown(upload.dispose);
  addTearDown(diary.dispose);
  addTearDown(favorite.dispose);
  addTearDown(sound.dispose);
  addTearDown(settings.dispose);
  addTearDown(avatar.dispose);

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: auth),
        ChangeNotifierProvider<SleepProvider>.value(value: sleep),
        ChangeNotifierProvider<UploadProvider>.value(value: upload),
        ChangeNotifierProvider<DiaryProvider>.value(value: diary),
        ChangeNotifierProvider<FavoriteProvider>.value(value: favorite),
        ChangeNotifierProvider<SoundProvider>.value(value: sound),
        ChangeNotifierProvider<SettingsProvider>.value(value: settings),
        ChangeNotifierProvider<AvatarProvider>.value(value: avatar),
      ],
      child: MaterialApp(
        theme: AppTheme.dark,
        home: const Scaffold(body: ProfileTab(active: true)),
        onGenerateRoute: (RouteSettings routeSettings) {
          if (routeSettings.name == AppRoutes.login) {
            return MaterialPageRoute<void>(
              builder: (_) => const Scaffold(
                body: Center(child: Text('登录页')),
              ),
            );
          }
          if (routeSettings.name == AppRoutes.player) {
            return MaterialPageRoute<bool?>(
              builder: (_) => Scaffold(
                appBar: AppBar(title: const Text('播放器')),
                body: const SizedBox.shrink(),
              ),
            );
          }
          return null;
        },
      ),
    ),
  );
  await tester.pumpAndSettle();

  return (
    auth: auth,
    sleep: sleep,
    upload: upload,
    diary: diary,
    favorite: favorite,
    sound: sound,
    settings: settings,
    avatar: avatar,
    avatarService: avatarService,
    cleaner: cleaner,
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'auth.is_logged_in': true,
      'auth.username': 'xiaoyu',
      'auth.nickname': '小鱼',
      'auth.joined_at':
          DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
    });
  });

  testWidgets('我的：资料 / 两项统计 / 设置 / 关于', (
    WidgetTester tester,
  ) async {
    final ProfileHarness harness = await _pumpProfile(tester);

    expect(find.text('我的'), findsOneWidget);
    expect(find.text('小鱼的夜晚'), findsOneWidget);
    expect(find.text('小鱼'), findsOneWidget);
    expect(find.text('连续靠岸 4 天 · 加入 3 天'), findsOneWidget);

    expect(find.text('收藏'), findsNothing);
    expect(find.text('日记'), findsOneWidget);
    expect(find.text('仪式'), findsOneWidget);
    expect(find.text('1'), findsWidgets);
    expect(find.text('4'), findsWidgets);
    expect(find.text('我的上传'), findsNothing);
    expect(find.text('上传数量'), findsNothing);
    expect(find.text('加入天数'), findsNothing);

    expect(find.text('我的收藏'), findsNothing);
    expect(find.text('全部 3 ›'), findsNothing);
    expect(find.text('还没有收藏'), findsNothing);
    expect(find.text('雨声'), findsNothing);

    await tester.ensureVisible(find.text('设置'));
    await tester.tap(find.text('设置'));
    await tester.pumpAndSettle();
    expect(find.text('主题'), findsOneWidget);
    expect(find.text('默认定时'), findsOneWidget);
    expect(find.text('睡眠记录'), findsNothing);
    expect(find.text('自动记录睡眠'), findsNothing);
    expect(find.text('晨间确认提醒'), findsNothing);

    await tester.tap(find.text('浅色'));
    await tester.pumpAndSettle();
    expect(harness.settings.themeModeSetting, AppThemeMode.light);
    await tester.ensureVisible(find.text('自定义'));
    await tester.tap(find.text('自定义'));
    await tester.pumpAndSettle();
    expect(find.text('自定义定时'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '45');
    await tester.tap(find.text('确定'));
    await tester.pumpAndSettle();
    expect(harness.settings.defaultTimerMinutes, 45);
    await tester.tap(find.byTooltip('关闭'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('关于梦屿'));
    await tester.tap(find.text('关于梦屿'));
    await tester.pumpAndSettle();
    expect(find.text('关于梦屿'), findsWidgets);
    await tester.tap(find.byTooltip('关闭'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('我们的初衷'));
    await tester.tap(find.text('我们的初衷'));
    await tester.pumpAndSettle();
    expect(
      find.text('梦屿是为失眠、入睡困难的人做的一个睡前工具，不是内容平台。'),
      findsOneWidget,
    );
    await tester.tap(find.byTooltip('关闭'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('使用须知'));
    await tester.tap(find.text('使用须知'));
    await tester.pumpAndSettle();
    expect(
      find.text('梦屿是本地工具，不提供、不存储、不传播任何音频内容。'),
      findsOneWidget,
    );
    await tester.tap(find.byTooltip('关闭'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('退出登录二次确认后清空路由到登录页', (WidgetTester tester) async {
    final ProfileHarness harness = await _pumpProfile(tester);

    await tester.ensureVisible(find.text('退出登录'));
    await tester.tap(find.text('退出登录'));
    await tester.pumpAndSettle();
    expect(find.text('退出登录？'), findsOneWidget);
    await tester.tap(find.text('退出'));
    await tester.pumpAndSettle();

    expect(find.text('登录页'), findsOneWidget);
    expect(harness.auth.hasSession, isFalse);
    final NavigatorState navigator = tester.state<NavigatorState>(
      find.byType(Navigator).first,
    );
    expect(navigator.canPop(), isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('头像：相册入口保存路径并写入 Provider', (WidgetTester tester) async {
    final ProfileHarness harness = await _pumpProfile(tester);

    await tester.tap(find.byKey(const Key('profile-avatar')));
    await tester.pumpAndSettle();
    expect(find.text('更换头像'), findsOneWidget);
    expect(find.text('拍一张'), findsOneWidget);
    expect(find.text('从相册选择'), findsOneWidget);

    await tester.tap(find.text('从相册选择'));
    await tester.pumpAndSettle();
    expect(harness.avatarService.picks, 1);
    expect(harness.avatarService.lastSource, AvatarSource.gallery);
    expect(harness.avatar.path, isNotNull);
    expect(harness.auth.user?.avatarPath, harness.avatar.path);
    expect(find.text('更换头像'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('头像：权限拒绝显示说明和去设置', (WidgetTester tester) async {
    final ProfileHarness harness = await _pumpProfile(tester);
    harness.avatarService.error = '相机权限被拒绝，请到系统设置中开启相机权限';

    await tester.tap(find.byKey(const Key('profile-avatar')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('拍一张'));
    await tester.pumpAndSettle();

    expect(find.text('头像未更新'), findsOneWidget);
    expect(find.textContaining('相机权限被拒绝'), findsOneWidget);
    expect(find.text('去设置'), findsOneWidget);
    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('清除数据重置 Provider 并回到登录页', (WidgetTester tester) async {
    final ProfileHarness harness = await _pumpProfile(tester);
    expect(harness.diary.entries, isNotEmpty);
    expect(harness.sleep.sessions, isNotEmpty);
    expect(harness.upload.uploads, isNotEmpty);

    await tester.tap(find.text('设置'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('清除数据'));
    await tester.pumpAndSettle();
    expect(find.text('清除所有本地数据？'), findsOneWidget);
    await tester.tap(find.text('清除'));
    await tester.pumpAndSettle();

    expect(find.text('登录页'), findsOneWidget);
    expect(harness.cleaner.cleared, isTrue);
    expect(harness.auth.hasSession, isFalse);
    expect(harness.diary.entries, isEmpty);
    expect(harness.sleep.sessions, isEmpty);
    expect(harness.upload.uploads, isEmpty);
    expect(harness.favorite.ids, isEmpty);
    expect(harness.settings.themeModeSetting, AppThemeMode.dark);
    expect(harness.settings.defaultTimerMinutes, 10);
    expect(tester.takeException(), isNull);
  });
}
