import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mengyu_app/core/routes/app_routes.dart';
import 'package:mengyu_app/core/theme/app_theme.dart';
import 'package:mengyu_app/data/repositories/local/local_favorite_repository.dart';
import 'package:mengyu_app/data/repositories/local/local_sound_repository.dart';
import 'package:mengyu_app/pages/player/player_page.dart';
import 'package:mengyu_app/pages/timer/timer_page.dart';
import 'package:mengyu_app/providers/favorite_provider.dart';
import 'package:mengyu_app/providers/player_provider.dart';
import 'package:mengyu_app/providers/settings_provider.dart';
import 'package:mengyu_app/providers/sound_provider.dart';
import 'package:mengyu_app/widgets/primary_button.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fake_audio_engine.dart';
import 'support/fake_session_repository.dart';
import 'support/fake_settings.dart';

typedef PlayerHarness = ({
  PlayerProvider player,
  FavoriteProvider favorites,
  FakeAudioEngine engine,
});

Future<PlayerHarness> _pumpPlayer(
  WidgetTester tester, {
  bool failPlay = false,
  int defaultTimerMinutes = 30,
}) async {
  tester.view.physicalSize = const Size(360, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final FakeAudioEngine engine = FakeAudioEngine()..failPlay = failPlay;
  final PlayerProvider player = PlayerProvider(
    engineFactory: () => engine,
    sessionRepository: FakeSessionRepository(),
    clock: DateTime.now,
  );
  final FavoriteProvider favorites = FavoriteProvider(
    const LocalFavoriteRepository(),
  );
  final SettingsProvider settings = SettingsProvider(
    FakeSettingsRepository(defaultTimerMinutes: defaultTimerMinutes),
    FakeAppDataCleaner(),
  );
  final SoundProvider sound = SoundProvider(const LocalSoundRepository());
  await settings.load();
  await sound.loadLocal();
  addTearDown(player.dispose);
  addTearDown(favorites.dispose);
  addTearDown(settings.dispose);
  addTearDown(sound.dispose);

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<PlayerProvider>.value(value: player),
        ChangeNotifierProvider<FavoriteProvider>.value(value: favorites),
        ChangeNotifierProvider<SettingsProvider>.value(value: settings),
        ChangeNotifierProvider<SoundProvider>.value(value: sound),
      ],
      child: MaterialApp(
        theme: AppTheme.dark,
        home: PlayerPage(audio: rainAsset()),
        onGenerateRoute: (RouteSettings settings) {
          if (settings.name == AppRoutes.timer) {
            return MaterialPageRoute<int?>(
              builder: (BuildContext context) => TimerPage(
                initialMinutes: settings.arguments as int?,
              ),
            );
          }
          return null;
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
  return (player: player, favorites: favorites, engine: engine);
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('播放页：自动播放 / 暂停 / 收藏 / 定时', (WidgetTester tester) async {
    final PlayerHarness harness = await _pumpPlayer(tester);

    expect(find.text('正在播放'), findsOneWidget);
    expect(find.text('雨声'), findsOneWidget);
    expect(find.textContaining('深度助眠'), findsOneWidget);
    expect(find.byType(Hero), findsOneWidget);
    expect(harness.engine.playedAssets, <String>['audio/rain_loop.wav']);
    expect(harness.player.status, PlayerStatus.playing);

    await tester.tap(find.byTooltip('暂停'));
    await tester.pumpAndSettle();
    expect(harness.engine.paused, isTrue);
    expect(harness.player.status, PlayerStatus.paused);
    expect(find.byTooltip('播放'), findsOneWidget);

    await tester.tap(find.byTooltip('收藏'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('取消收藏'), findsOneWidget);
    expect(harness.favorites.isFavorite('local_rain'), isTrue);
    expect(find.text('未设定时'), findsOneWidget);

    await tester.tap(find.byTooltip('定时'));
    await tester.pumpAndSettle();
    expect(find.text('定时关闭'), findsOneWidget);
    await tester.tap(find.text('10 分'));
    await tester.pump();
    await tester.tap(find.widgetWithText(PrimaryButton, '开始计时'));
    await tester.pumpAndSettle();

    expect(harness.player.remaining?.inMinutes, 10);
    expect(find.text('定时 10:00 · 到点自动停'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('上一首 / 下一首切本地声音列表', (WidgetTester tester) async {
    final PlayerHarness harness = await _pumpPlayer(tester);
    expect(find.text('雨声'), findsOneWidget);

    await tester.tap(find.byTooltip('下一首'));
    await tester.pumpAndSettle();
    expect(find.text('海浪'), findsOneWidget);
    expect(harness.engine.playedAssets.last, 'audio/ocean_loop.wav');

    await tester.tap(find.byTooltip('上一首'));
    await tester.pumpAndSettle();
    expect(find.text('雨声'), findsOneWidget);
    expect(harness.engine.playedAssets.last, 'audio/rain_loop.wav');
    expect(tester.takeException(), isNull);
  });

  testWidgets('默认定时来自设置中的分钟数', (WidgetTester tester) async {
    await _pumpPlayer(tester, defaultTimerMinutes: 45);

    await tester.tap(find.byTooltip('定时'));
    await tester.pumpAndSettle();

    expect(find.text('定时关闭'), findsOneWidget);
    expect(find.text('45'), findsOneWidget);
    expect(find.text('自定义'), findsOneWidget);
    expect(find.text('45 分'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('播放失败显示错误面板，重试后恢复', (WidgetTester tester) async {
    final PlayerHarness harness = await _pumpPlayer(tester, failPlay: true);
    expect(find.text('正在播放'), findsOneWidget);
    expect(find.textContaining('模拟音频加载失败'), findsWidgets);

    // 等错误 SnackBar 收起，只点错误面板里的重试
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    harness.engine.failPlay = false;

    await tester.tap(find.widgetWithText(TextButton, '重试'));
    await tester.pumpAndSettle();

    expect(harness.player.status, PlayerStatus.playing);
    expect(harness.engine.playedAssets, isNotEmpty);
    expect(tester.takeException(), isNull);
  });
}
