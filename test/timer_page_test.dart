import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mengyu_app/core/routes/app_routes.dart';
import 'package:mengyu_app/core/theme/app_theme.dart';
import 'package:mengyu_app/pages/timer/timer_page.dart';
import 'package:mengyu_app/widgets/primary_button.dart';

void main() {
  testWidgets('定时页：5/10/15/20 + 自定义，选择 20 后 pop(20)', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: const Scaffold(body: Center(child: Text('host'))),
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
    );

    final NavigatorState navigator = tester.state<NavigatorState>(
      find.byType(Navigator).first,
    );
    final Future<int?> result = navigator.pushNamed<int?>(
      AppRoutes.timer,
      arguments: 15,
    );
    await tester.pumpAndSettle();

    expect(find.text('定时关闭'), findsOneWidget);
    expect(find.text('15'), findsOneWidget); // 圆盘
    for (final String label in <String>['5 分', '10 分', '15 分', '20 分', '自定义']) {
      expect(find.text(label), findsOneWidget);
    }

    await tester.tap(find.text('20 分'));
    await tester.pump();
    expect(find.text('20'), findsOneWidget);

    await tester.tap(find.widgetWithText(PrimaryButton, '开始计时'));
    await tester.pumpAndSettle();

    expect(await result, 20);
    expect(find.text('host'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('定时页：自定义 7 分钟后 pop(7)', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: const Scaffold(body: Center(child: Text('host'))),
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
    );
    final NavigatorState navigator = tester.state<NavigatorState>(
      find.byType(Navigator).first,
    );
    final Future<int?> result = navigator.pushNamed<int?>(
      AppRoutes.timer,
      arguments: 10,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('自定义'));
    await tester.pumpAndSettle();
    expect(find.text('自定义定时'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '7');
    await tester.tap(find.text('确定'));
    await tester.pumpAndSettle();
    expect(find.text('7'), findsOneWidget);

    await tester.tap(find.widgetWithText(PrimaryButton, '开始计时'));
    await tester.pumpAndSettle();
    expect(await result, 7);
    expect(tester.takeException(), isNull);
  });

  testWidgets('定时页：非法初始值回退到 10', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: const TimerPage(initialMinutes: 0),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('10'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
