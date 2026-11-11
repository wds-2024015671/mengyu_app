import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mengyu_app/core/routes/app_routes.dart';
import 'package:mengyu_app/core/theme/app_theme.dart';
import 'package:mengyu_app/models/sleep_session.dart';
import 'package:mengyu_app/pages/sleep/sleep_log_form_page.dart';
import 'package:mengyu_app/providers/sleep_provider.dart';
import 'package:mengyu_app/widgets/primary_button.dart';
import 'package:provider/provider.dart';

import 'support/fake_session_repository.dart';

Future<Future<bool?>> _pushForm(
  WidgetTester tester, {
  required SleepProvider provider,
  SleepSession? session,
}) async {
  tester.view.physicalSize = const Size(360, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  late Future<bool?> result;
  await tester.pumpWidget(
    ChangeNotifierProvider<SleepProvider>.value(
      value: provider,
      child: MaterialApp(
        theme: AppTheme.dark,
        home: Builder(
          builder: (BuildContext context) {
            return Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    result = Navigator.pushNamed<bool>(
                      context,
                      AppRoutes.sleepLogForm,
                      arguments: session,
                    );
                  },
                  child: const Text('打开补记'),
                ),
              ),
            );
          },
        ),
        onGenerateRoute: (RouteSettings settings) {
          if (settings.name == AppRoutes.sleepLogForm) {
            return MaterialPageRoute<bool>(
              builder: (BuildContext context) => SleepLogFormPage(
                session: settings.arguments as SleepSession?,
              ),
            );
          }
          return null;
        },
      ),
    ),
  );

  await tester.tap(find.text('打开补记'));
  await tester.pumpAndSettle();
  return result;
}

void main() {
  testWidgets('补记页：默认 8 小时、评分/备注保存并 pop(true)', (
    WidgetTester tester,
  ) async {
    final FakeSessionRepository repository = FakeSessionRepository();
    final SleepProvider provider = SleepProvider(repository);
    addTearDown(provider.dispose);

    final Future<bool?> result = await _pushForm(tester, provider: provider);

    expect(find.text('补记睡眠'), findsOneWidget);
    expect(find.text('8 小时'), findsOneWidget);

    // 点第五颗星，评分从默认 3 改为 5
    await tester.tap(find.byIcon(Icons.star_border_rounded).last);
    await tester.pumpAndSettle();
    expect(find.text('5 / 5'), findsWidgets);

    await tester.enterText(
      find.byType(TextField),
      '雨声很轻，醒来说明睡得不错。',
    );
    await tester.ensureVisible(
      find.widgetWithText(PrimaryButton, '保存记录'),
    );
    await tester.tap(find.widgetWithText(PrimaryButton, '保存记录'));
    await tester.pumpAndSettle();

    expect(await result, isTrue);
    expect(repository.saved.length, 1);
    expect(provider.sessions.length, 1);
    expect(repository.saved.single.quality, 5);
    expect(repository.saved.single.durationMin, 480);
    expect(repository.saved.single.note, contains('雨声很轻'));
    expect(find.text('打开补记'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('日期预填：仍显示补记，不误判为编辑', (WidgetTester tester) async {
    final SleepProvider provider = SleepProvider(FakeSessionRepository());
    addTearDown(provider.dispose);

    await _pushForm(
      tester,
      provider: provider,
      session: SleepSession(
        bedTime: DateTime(2026, 11, 7, 23),
        wakeTime: DateTime(2026, 11, 8, 7),
        quality: 3,
      ),
    );

    expect(find.text('补记睡眠'), findsOneWidget);
    expect(find.text('编辑睡眠记录'), findsNothing);
    expect(find.text('8 小时'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('补记冲突：合并为同一天一条', (WidgetTester tester) async {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final SleepSession existing = SleepSession(
      id: 1,
      bedTime: today.subtract(const Duration(days: 1, hours: 1)),
      wakeTime: today.subtract(const Duration(minutes: 30)),
      quality: 4,
    );
    final FakeSessionRepository repository =
        FakeSessionRepository(<SleepSession>[existing]);
    final SleepProvider provider = SleepProvider(repository);
    addTearDown(provider.dispose);
    await provider.load();

    final Future<bool?> result = await _pushForm(tester, provider: provider);
    await tester.ensureVisible(
      find.widgetWithText(PrimaryButton, '保存记录'),
    );
    await tester.tap(find.widgetWithText(PrimaryButton, '保存记录'));
    await tester.pumpAndSettle();
    expect(find.text('同一天已有睡眠记录'), findsOneWidget);
    await tester.tap(find.text('合并'));
    await tester.pumpAndSettle();

    expect(await result, isTrue);
    expect(repository.saved.length, 1);
    expect(repository.saved.single.id, 1);
    expect(provider.sessions.length, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('补记冲突：覆盖当天旧记录', (WidgetTester tester) async {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final FakeSessionRepository repository = FakeSessionRepository(
      <SleepSession>[
        SleepSession(
          id: 1,
          bedTime: today.subtract(const Duration(days: 1, hours: 1)),
          wakeTime: today.subtract(const Duration(minutes: 30)),
          quality: 4,
        ),
      ],
    );
    final SleepProvider provider = SleepProvider(repository);
    addTearDown(provider.dispose);
    await provider.load();

    final Future<bool?> result = await _pushForm(tester, provider: provider);
    await tester.ensureVisible(
      find.widgetWithText(PrimaryButton, '保存记录'),
    );
    await tester.tap(find.widgetWithText(PrimaryButton, '保存记录'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('覆盖'));
    await tester.pumpAndSettle();

    expect(await result, isTrue);
    expect(repository.saved.length, 1);
    expect(provider.sessions.length, 1);
    expect(provider.sessions.single.quality, 3);
    expect(tester.takeException(), isNull);
  });
}
