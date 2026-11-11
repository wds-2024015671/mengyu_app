import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mengyu_app/app.dart';
import 'package:mengyu_app/core/theme/app_tokens.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fake_audio_engine.dart';

void main() {
  testWidgets('设置里切换浅/深色立即生效', (WidgetTester tester) async {
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
      'settings.theme_mode': 'dark',
    });

    await tester.pumpWidget(
      MengYuApp(audioEngineFactory: () => FakeAudioEngine()),
    );
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(InkWell, '我的'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('设置'));
    await tester.tap(find.text('设置'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('浅色'));
    await tester.pumpAndSettle();
    MaterialApp app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.light);
    final BuildContext lightContext = tester.element(find.text('主题'));
    expect(
      Theme.of(lightContext).extension<AppTokens>()!.bgDeep,
      AppTokens.light.bgDeep,
    );

    await tester.tap(find.text('深色'));
    await tester.pumpAndSettle();
    app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
    final BuildContext darkContext = tester.element(find.text('主题'));
    expect(
      Theme.of(darkContext).extension<AppTokens>()!.bgDeep,
      AppTokens.dark.bgDeep,
    );

    await tester.tap(find.byTooltip('关闭'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
