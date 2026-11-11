import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mengyu_app/app.dart';
import 'package:mengyu_app/core/theme/app_tokens.dart';
import 'package:mengyu_app/pages/tabs/widgets/sound_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fake_audio_engine.dart';

void main() {
  testWidgets('浅色主题冷启动：4 个主 tab 不溢出且使用 light tokens', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues(<String, Object>{
      'welcome_seen': true,
      'auth.is_logged_in': true,
      'auth.username': 'xiaoyu',
      'auth.nickname': '小鱼',
      'auth.remember_me': true,
      'settings.theme_mode': 'light',
    });

    await tester.pumpWidget(
      MengYuApp(audioEngineFactory: () => FakeAudioEngine()),
    );
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pumpAndSettle();

    final MaterialApp app = tester.widget<MaterialApp>(
      find.byType(MaterialApp),
    );
    expect(app.themeMode, ThemeMode.light);
    expect(
      Theme.of(tester.element(find.text('今夜推荐').first))
          .extension<AppTokens>()!
          .bgDeep,
      AppTokens.light.bgDeep,
    );

    for (final String tab in <String>['声屿', '月迹', '我的', '今晚']) {
      await tester.tap(find.widgetWithText(InkWell, tab));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }

    // 浅色播放器
    await tester.tap(find.widgetWithText(InkWell, '声屿'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(SoundCard, '雨声'));
    await tester.pumpAndSettle();
    expect(find.text('正在播放'), findsOneWidget);
    await tester.tap(find.byTooltip('返回'));
    await tester.pumpAndSettle();
    if (find.text('要开始记录睡眠吗？').evaluate().isNotEmpty) {
      await tester.tap(find.text('不用了'));
      await tester.pumpAndSettle();
    }

    // 浅色设置弹层
    await tester.tap(find.widgetWithText(InkWell, '我的'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('设置'));
    await tester.tap(find.text('设置'));
    await tester.pumpAndSettle();
    expect(find.text('主题'), findsOneWidget);
    await tester.tap(find.byTooltip('关闭'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('浅色主题：欢迎浮层与登录页正常', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues(<String, Object>{
      'settings.theme_mode': 'light',
    });

    await tester.pumpWidget(
      MengYuApp(audioEngineFactory: () => FakeAudioEngine()),
    );
    await tester.pumpAndSettle();
    expect(find.text('欢迎来到梦屿'), findsOneWidget);
    await tester.tap(find.byTooltip('关闭'));
    await tester.pumpAndSettle();
    expect(find.text('欢迎回来'), findsOneWidget);
    final MaterialApp app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.light);
    expect(tester.takeException(), isNull);
  });
}
