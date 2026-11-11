import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mengyu_app/app.dart';
import 'package:mengyu_app/core/routes/app_routes.dart';
import 'package:mengyu_app/widgets/primary_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    // 认证走 prefs，widget 测试里用内存 mock，避免 MissingPluginException。
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('F04 验收：欢迎 → 登录 → 首页 → 4 tab → /upload', (
    WidgetTester tester,
  ) async {
    // 360×800 是验收基准，测试里也按这个尺寸跑，能直接暴露溢出。
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MengYuApp());
    await tester.pumpAndSettle();
    expect(find.text('欢迎来到梦屿'), findsOneWidget);

    // 首启欢迎浮层：点金色按钮关闭，再按登录态分流。
    await tester.tap(
      find.widgetWithText(PrimaryButton, '开始今晚的仪式'),
    );
    await tester.pumpAndSettle();
    expect(find.text('欢迎回来'), findsOneWidget);

    // 空表单提交：校验错误贴着字段显示
    final Finder loginButton = find.widgetWithText(PrimaryButton, '登录');
    await tester.ensureVisible(loginButton);
    await tester.tap(loginButton);
    await tester.pump();
    expect(find.text('用户名需 3–20 个字符'), findsOneWidget);

    // 合法账号登录 → /home
    await tester.enterText(find.byType(TextFormField).at(0), 'xiaoyu');
    await tester.enterText(find.byType(TextFormField).at(1), '123456');
    await tester.tap(loginButton);
    await tester.pumpAndSettle();
    expect(find.text('今夜推荐'), findsOneWidget);

    // 4 个 tab 逐个切换
    await tester.tap(find.widgetWithText(InkWell, '声屿'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(InkWell, '月迹'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(InkWell, '我的'));
    await tester.pumpAndSettle();

    // /upload 仍在路由表，但 v7 我的页不再放上传入口，直接走命名路由。
    final NavigatorState navigator = tester.state<NavigatorState>(
      find.byType(Navigator).first,
    );
    navigator.pushNamed(AppRoutes.upload);
    await tester.pumpAndSettle();
    expect(find.text('上传声音'), findsOneWidget);

    // 返回不白屏（中文环境 tooltip 是“返回”，直接点 BackButton）
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('我的'), findsWidgets);

    expect(tester.takeException(), isNull);
  });
}
