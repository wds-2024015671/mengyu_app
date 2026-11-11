import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mengyu_app/core/routes/app_routes.dart';
import 'package:mengyu_app/core/theme/app_theme.dart';
import 'package:mengyu_app/models/breathing_mode.dart';
import 'package:mengyu_app/pages/breathing/breathing_session_page.dart';

const BreathingMode _fastMode = BreathingMode(
  name: '测试呼吸',
  description: '1-1-1，两轮',
  inhale: 1,
  hold: 1,
  exhale: 1,
  cycles: 2,
);

Future<Future<int?>> _pushSession(
  WidgetTester tester,
  BreathingMode mode,
) async {
  tester.view.physicalSize = const Size(360, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  late Future<int?> result;
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark,
      home: Builder(
        builder: (BuildContext context) {
          return Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () {
                  result = Navigator.pushNamed<int?>(
                    context,
                    AppRoutes.breathingSession,
                    arguments: mode,
                  );
                },
                child: const Text('开始'),
              ),
            ),
          );
        },
      ),
      onGenerateRoute: (RouteSettings settings) {
        if (settings.name == AppRoutes.breathingSession) {
          return MaterialPageRoute<int?>(
            builder: (BuildContext context) => BreathingSessionPage(
              mode: settings.arguments as BreathingMode,
            ),
          );
        }
        return null;
      },
    ),
  );

  await tester.tap(find.text('开始'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  return result;
}

void main() {
  testWidgets('呼吸进行页：阶段/轮次/完成弹窗后 pop(cycles)', (
    WidgetTester tester,
  ) async {
    final Future<int?> result = await _pushSession(tester, _fastMode);

    expect(find.text('吸气'), findsOneWidget);
    expect(find.text('第 1 / 2 轮'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1100));
    expect(find.text('屏息'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1200));
    expect(find.text('呼气'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1200));
    expect(find.text('第 2 / 2 轮'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 3000));
    await tester.pumpAndSettle();
    expect(find.text('完成 2 轮呼吸'), findsOneWidget);

    await tester.tap(find.text('完成'));
    await tester.pumpAndSettle();

    expect(await result, 2);
    expect(find.text('开始'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('未完成返回先弹确认，确认结束后 pop(null)', (
    WidgetTester tester,
  ) async {
    final Future<int?> result = await _pushSession(tester, _fastMode);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('结束这次呼吸？'), findsOneWidget);

    await tester.tap(find.text('结束'));
    await tester.pumpAndSettle();

    expect(await result, isNull);
    expect(find.text('开始'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
