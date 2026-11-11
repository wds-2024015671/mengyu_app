import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mengyu_app/app.dart';
import 'package:mengyu_app/data/repositories/local/local_favorite_repository.dart';
import 'package:mengyu_app/pages/tabs/widgets/sound_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fake_audio_engine.dart';

void _usePhoneSize(WidgetTester tester) {
  tester.view.physicalSize = const Size(360, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'welcome_seen': true,
      'auth.is_logged_in': true,
      'auth.username': 'xiaoyu',
      'auth.nickname': '小鱼',
      'auth.remember_me': true,
    });
  });

  test('收藏 prefs 往返', () async {
    const LocalFavoriteRepository repository = LocalFavoriteRepository();
    await repository.save(<String>{'local_rain', 'local_noise'});
    expect(await repository.load(), <String>{'local_rain', 'local_noise'});
  });

  testWidgets('声屿：6 条 / 搜索 / 收藏 / 三段分类 / 播放入口', (
    WidgetTester tester,
  ) async {
    _usePhoneSize(tester);
    await tester.pumpWidget(
      MengYuApp(audioEngineFactory: () => FakeAudioEngine()),
    );
    await tester.pump(const Duration(milliseconds: 2600));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(InkWell, '声屿'));
    await tester.pumpAndSettle();

    expect(find.text('把世界调成静音'), findsOneWidget);
    expect(find.text('全部声音 · 6'), findsOneWidget);
    expect(find.byType(SoundCard), findsNWidgets(6));
    expect(find.text('公共库'), findsNothing);
    expect(find.text('我的上传'), findsNothing);
    expect(find.text('上传'), findsNothing);

    // 搜索：300ms 防抖后只剩雨声
    final Finder search = find.byType(TextField);
    await tester.enterText(search, '雨');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();
    expect(find.text('全部声音 · 1'), findsOneWidget);
    expect(find.widgetWithText(SoundCard, '雨声'), findsOneWidget);
    expect(find.widgetWithText(SoundCard, '海浪'), findsNothing);

    await tester.enterText(search, '');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();
    expect(find.text('全部声音 · 6'), findsOneWidget);

    // 收藏：卡片心变实心并写 prefs
    final Finder rainCard = find.widgetWithText(SoundCard, '雨声');
    await tester.tap(
      find.descendant(of: rainCard, matching: find.byTooltip('收藏')),
    );
    await tester.pumpAndSettle();
    expect(find.byTooltip('取消收藏'), findsOneWidget);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    expect(
      prefs.getStringList(LocalFavoriteRepository.prefsKey),
      contains('local_rain'),
    );

    // 顶部心形：仅看收藏
    await tester.tap(find.byTooltip('仅看收藏'));
    await tester.pumpAndSettle();
    expect(find.text('全部声音 · 1'), findsOneWidget);
    expect(find.widgetWithText(SoundCard, '雨声'), findsOneWidget);
    expect(find.widgetWithText(SoundCard, '海浪'), findsNothing);
    await tester.tap(find.byTooltip('仅看收藏'));
    await tester.pumpAndSettle();
    expect(find.byType(SoundCard), findsNWidgets(6));

    // 三段分类
    await tester.tap(find.text('Nature'));
    await tester.pumpAndSettle();
    expect(find.text('Nature · 3'), findsOneWidget);
    expect(find.widgetWithText(SoundCard, '海浪'), findsOneWidget);
    expect(find.widgetWithText(SoundCard, '溪流'), findsOneWidget);
    expect(find.widgetWithText(SoundCard, '夜风'), findsOneWidget);
    expect(find.widgetWithText(SoundCard, '雨声'), findsNothing);
    expect(find.widgetWithText(SoundCard, '篝火'), findsNothing);

    await tester.tap(find.text('Other'));
    await tester.pumpAndSettle();
    expect(find.text('Other · 1'), findsOneWidget);
    expect(find.widgetWithText(SoundCard, '白噪'), findsOneWidget);
    expect(find.widgetWithText(SoundCard, '海浪'), findsNothing);

    await tester.tap(find.text('ASMR'));
    await tester.pumpAndSettle();
    expect(find.text('全部声音 · 6'), findsOneWidget);

    // 卡片点击进播放器
    await tester.tap(find.widgetWithText(SoundCard, '雨声'));
    await tester.pumpAndSettle();
    expect(find.text('正在播放'), findsOneWidget);
    await tester.tap(find.byTooltip('返回'));
    await tester.pumpAndSettle();
    if (find.text('要开始记录睡眠吗？').evaluate().isNotEmpty) {
      await tester.tap(find.text('不用了'));
      await tester.pumpAndSettle();
    }

    // 三段 + 搜索 + 收藏叠加：Nature 里只收藏海浪，再搜“海”
    final Finder oceanCard = find.widgetWithText(SoundCard, '海浪');
    await tester.tap(
      find.descendant(of: oceanCard, matching: find.byTooltip('收藏')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('仅看收藏'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nature'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '海');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();
    expect(find.text('Nature · 1'), findsOneWidget);
    expect(find.widgetWithText(SoundCard, '海浪'), findsOneWidget);
    expect(find.widgetWithText(SoundCard, '雨声'), findsNothing);

    expect(tester.takeException(), isNull);
  });
}
