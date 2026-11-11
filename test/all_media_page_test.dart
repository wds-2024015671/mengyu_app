import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mengyu_app/app.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fake_audio_engine.dart';

void _phone(WidgetTester tester) {
  tester.view.physicalSize = const Size(360, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> _openSound(WidgetTester tester) async {
  await tester.pumpWidget(
    MengYuApp(audioEngineFactory: () => FakeAudioEngine()),
  );
  await tester.pump(const Duration(milliseconds: 2600));
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(InkWell, '声屿'));
  await tester.pumpAndSettle();
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

  testWidgets('全部声音：更多进入 / 管理 / 全选 / 退出选择态', (
    WidgetTester tester,
  ) async {
    _phone(tester);
    await _openSound(tester);
    await tester.tap(find.text('更多 ›').first);
    await tester.pumpAndSettle();

    expect(find.text('全部声音'), findsOneWidget);
    expect(find.text('共 6 段'), findsOneWidget);
    expect(find.text('管理'), findsOneWidget);
    expect(find.text('雨落窗台'), findsOneWidget);
    expect(find.text('ASMR'), findsNothing);
    expect(find.text('Nature'), findsNothing);

    await tester.tap(find.text('管理'));
    await tester.pumpAndSettle();
    expect(find.text('已选 0 / 6'), findsWidgets);
    expect(find.text('全选'), findsOneWidget);

    await tester.tap(find.text('雨落窗台'));
    await tester.pumpAndSettle();
    expect(find.text('已选 1 / 6'), findsWidgets);

    await tester.tap(find.text('全选'));
    await tester.pumpAndSettle();
    expect(find.text('已选 6 / 6'), findsWidgets);

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
    await tester.pumpAndSettle();
    expect(find.text('全部声音'), findsOneWidget);
    expect(find.text('管理'), findsOneWidget);
    expect(find.text('取消'), findsNothing);

    await tester.tap(find.text('管理'));
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('全部声音'), findsOneWidget);
    expect(find.text('管理'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('把世界调成静音'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('全部声音：全选删除，返回声屿同步消失', (
    WidgetTester tester,
  ) async {
    _phone(tester);
    await _openSound(tester);
    await tester.tap(find.text('更多 ›').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('管理'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('全选'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('删除'));
    await tester.pumpAndSettle();
    expect(find.text('删除 6 项？'), findsOneWidget);
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.widgetWithText(TextButton, '取消'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('已选 6 / 6'), findsWidgets);

    await tester.tap(find.text('删除'));
    await tester.pumpAndSettle();
    expect(find.text('删除 6 项？'), findsOneWidget);
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.widgetWithText(TextButton, '删除'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('还没有音频'), findsOneWidget);
    expect(find.text('共 0 段'), findsOneWidget);
    expect(find.text('管理'), findsNothing);
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
    await tester.pumpAndSettle();
    expect(find.text('雨落窗台'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('全部声音 393×852：管理态无溢出', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await _openSound(tester);
    await tester.tap(find.text('更多 ›').first);
    await tester.pumpAndSettle();
    expect(find.text('共 6 段'), findsOneWidget);
    await tester.tap(find.text('管理'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('全选'));
    await tester.pumpAndSettle();
    expect(find.text('已选 6 / 6'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('全部视频：2 列大框 / 无来源 / 无 tabbar', (
    WidgetTester tester,
  ) async {
    _phone(tester);
    await _openSound(tester);
    await tester.tap(find.text('更多 ›').at(1));
    await tester.pumpAndSettle();

    expect(find.text('全部视频'), findsOneWidget);
    expect(find.text('共 8 个'), findsOneWidget);
    expect(find.text('轻触发音'), findsOneWidget);
    expect(find.text('海浪'), findsOneWidget);
    expect(find.text('本地'), findsNothing);
    expect(find.text('Bilibili'), findsNothing);
    expect(find.text('今晚'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
