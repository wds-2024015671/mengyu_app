import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mengyu_app/app.dart';
import 'support/fake_audio_engine.dart';
import 'package:mengyu_app/core/routes/app_routes.dart';
import 'package:mengyu_app/pages/tabs/widgets/home_shortcuts.dart';
import 'package:shared_preferences/shared_preferences.dart';

void _usePhoneSize(WidgetTester tester) {
  tester.view.physicalSize = const Size(360, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'welcome_seen': true,
      'auth.is_logged_in': true,
      'auth.username': 'xiaoyu',
      'auth.nickname': '小鱼',
      'auth.remember_me': true,
    });
  });

  test('月亮插画资源已打包', () async {
    final ByteData data = await rootBundle.load('assets/images/moon.png');
    expect(data.lengthInBytes, greaterThan(1000));
  });

  testWidgets('首页：推荐卡 / 快捷入口 / 下拉刷新', (WidgetTester tester) async {
    _usePhoneSize(tester);
    await tester.pumpWidget(MengYuApp(audioEngineFactory: () => FakeAudioEngine()));
    await tester.pump(const Duration(milliseconds: 2600));
    await tester.pumpAndSettle();

    expect(find.text('今夜推荐'), findsOneWidget);
    expect(find.text('轻触发音'), findsOneWidget);
    expect(find.text('雨落窗台'), findsOneWidget);
    expect(find.text('最近播放'), findsNothing);
    expect(find.text('呼吸'), findsOneWidget);
    expect(find.text('日记'), findsOneWidget);
    expect(find.byType(RefreshIndicator), findsOneWidget);

    // 推荐卡音频行 → /player（带 AudioItem）
    await tester.tap(find.text('雨落窗台'));
    await tester.pumpAndSettle();
    expect(find.text('正在播放'), findsOneWidget);

    await tester.tap(find.byTooltip('返回'));
    await tester.pumpAndSettle();
    if (find.text('要开始记录睡眠吗？').evaluate().isNotEmpty) {
      await tester.tap(find.text('不用了'));
      await tester.pumpAndSettle();
    }
    expect(find.text('今夜推荐'), findsOneWidget);

    // 查看全部：切到声屿 tab，而不是 push 第二个 MainShell
    await tester.tap(find.text('查看全部 ›'));
    await tester.pumpAndSettle();
    IndexedStack soundStack = tester.widget<IndexedStack>(
      find.byType(IndexedStack).first,
    );
    expect(soundStack.index, 1);
    await tester.tap(find.widgetWithText(InkWell, '今晚'));
    await tester.pumpAndSettle();

    // 月迹快捷入口：切当前 Shell 的 tab，而不是再 push 一个 MainShell
    await tester.tap(
      find.descendant(
        of: find.byType(HomeShortcuts),
        matching: find.text('月迹'),
      ),
    );
    await tester.pumpAndSettle();
    IndexedStack stack = tester.widget<IndexedStack>(
      find.byType(IndexedStack).first,
    );
    expect(stack.index, 2);

    // 回首页下拉刷新
    await tester.tap(find.widgetWithText(InkWell, '今晚'));
    await tester.pumpAndSettle();
    await tester.fling(
      find.byType(ListView).first,
      const Offset(0, 320),
      1200,
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('未登录访问 /home 会被首帧重定向到 /login', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'welcome_seen': true,
    });
    _usePhoneSize(tester);

    await tester.pumpWidget(MengYuApp(audioEngineFactory: () => FakeAudioEngine()));
    await tester.pump(const Duration(milliseconds: 2600));
    await tester.pumpAndSettle();
    expect(find.text('欢迎回来'), findsOneWidget);

    final NavigatorState navigator = tester.state<NavigatorState>(
      find.byType(Navigator).first,
    );
    navigator.pushNamed(AppRoutes.home);
    await tester.pumpAndSettle();

    expect(find.text('今夜推荐'), findsNothing);
    expect(find.text('欢迎回来'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
