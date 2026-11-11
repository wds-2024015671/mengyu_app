import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mengyu_app/app.dart';
import 'package:mengyu_app/data/repositories/local/local_favorite_repository.dart';
import 'package:mengyu_app/pages/tabs/widgets/sound_list_frame.dart';
import 'package:mengyu_app/pages/tabs/widgets/sound_segment_switch.dart';
import 'package:mengyu_app/pages/tabs/widgets/video_group.dart';
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

  testWidgets('声屿 v9：声音列表 / 视频大框 / 搜索 / 分类', (
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
    expect(find.text('私人库'), findsOneWidget);
    expect(find.text('全部声音 · 6'), findsOneWidget);
    expect(find.byType(SoundListFrame), findsOneWidget);
    expect(find.byType(VideoGroup), findsOneWidget);
    expect(find.text('全部视频'), findsOneWidget);
    expect(find.text('雨落窗台'), findsOneWidget);
    expect(find.text('篝火噼啪'), findsOneWidget);
    expect(find.byTooltip('收藏'), findsNothing);
    expect(find.text('最近在听'), findsNothing);

    final Finder search = find.byType(TextField);
    await tester.enterText(search, '雨');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();
    expect(find.text('全部声音 · 1'), findsOneWidget);
    expect(find.text('雨落窗台'), findsOneWidget);
    expect(find.text('篝火噼啪'), findsNothing);

    await tester.enterText(search, '');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();
    expect(find.text('全部声音 · 6'), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byType(SoundSegmentSwitch),
        matching: find.text('Nature'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('全部声音 · 2'), findsOneWidget);
    expect(find.text('海浪白噪'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(SoundListFrame),
        matching: find.text('夏夜虫鸣'),
      ),
      findsOneWidget,
    );
    expect(find.text('雨落窗台'), findsNothing);

    await tester.tap(
      find.descendant(
        of: find.byType(SoundSegmentSwitch),
        matching: find.text('Other'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('全部声音 · 0'), findsOneWidget);
    expect(find.text('没有找到相关声音'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('声屿 393×852：单滚动无溢出', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MengYuApp(audioEngineFactory: () => FakeAudioEngine()),
    );
    await tester.pump(const Duration(milliseconds: 2600));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(InkWell, '声屿'));
    await tester.pumpAndSettle();
    expect(find.text('全部声音 · 6'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -2600));
    await tester.pumpAndSettle();
    expect(find.byType(VideoGroup), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('声屿：私人库弹层 / 无效链接 / 视频点击', (
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

    await tester.tap(find.text('私人库'));
    await tester.pumpAndSettle();
    expect(find.text('添加到私人库'), findsOneWidget);
    expect(find.text('仅音频'), findsOneWidget);
    expect(find.text('视频'), findsOneWidget);
    await tester.tap(find.text('解析并下载'));
    await tester.pumpAndSettle();
    expect(find.text('请输入有效的 http(s) 链接'), findsOneWidget);
    await tester.tap(find.byTooltip('关闭'));
    await tester.pumpAndSettle();

    final Finder video = find.text('轻触发音');
    final BuildContext videoContext = tester.element(video);
    await Scrollable.ensureVisible(videoContext, alignment: 0.35);
    await tester.pumpAndSettle();
    await tester.tap(video);
    await tester.pumpAndSettle();
    expect(find.text('本地 · 01:00'), findsOneWidget);
    await tester.tap(find.byTooltip('关闭'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
