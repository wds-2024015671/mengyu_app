import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mengyu_app/core/routes/app_routes.dart';
import 'package:mengyu_app/core/theme/app_theme.dart';
import 'package:mengyu_app/pages/timer/timer_page.dart';
import 'package:mengyu_app/widgets/primary_button.dart';

void main() {
  testWidgets('定时页：5 个选项、默认 30、选择 45 后 pop(45)', (
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
    for (final String label in <String>['15 分', '30 分', '45 分', '60 分', '90 分']) {
      expect(find.text(label), findsOneWidget);
    }

    await tester.tap(find.text('45 分'));
    await tester.pump();
    expect(find.text('45'), findsOneWidget);

    await tester.tap(find.widgetWithText(PrimaryButton, '开始计时'));
    await tester.pumpAndSettle();

    expect(await result, 45);
    expect(find.text('host'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('定时页：非法初始值回退到 30', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: const TimerPage(initialMinutes: 20),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('30'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
