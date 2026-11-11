import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mengyu_app/core/theme/app_theme.dart';
import 'package:mengyu_app/models/sleep_session.dart';
import 'package:mengyu_app/pages/tabs/widgets/report_moon_grid.dart';
import 'package:mengyu_app/widgets/glass_card.dart';

void main() {
  testWidgets('月迹方框：补记/空格/已记录格都可进入补记', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final DateTime today = DateTime(2026, 11, 12);
    final SleepSession session = SleepSession(
      id: 1,
      bedTime: DateTime(2026, 11, 10, 23),
      wakeTime: DateTime(2026, 11, 11, 7),
      quality: 4,
      note: '睡得不错',
    );
    DateTime? pickedDate;
    SleepSession? edited;
    int adds = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ReportMoonGrid(
              sessions: <SleepSession>[session],
              today: today,
              onAdd: () => adds++,
              onPickDate: (DateTime date) => pickedDate = date,
              onEditSession: (SleepSession value) => edited = value,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('本月月迹 · 30 天'), findsOneWidget);
    expect(find.text('补记'), findsOneWidget);
    expect(find.byType(GlassCard), findsOneWidget);
    expect(
      tester.widget<GlassCard>(find.byType(GlassCard)).outlined,
      isTrue,
    );

    await tester.tap(find.text('补记'));
    expect(adds, 1);

    await tester.tap(find.byKey(const ValueKey<String>('moon-2026-11-08')));
    expect(pickedDate, DateTime(2026, 11, 8));

    await tester.tap(find.byKey(const ValueKey<String>('moon-2026-11-10')));
    expect(edited?.id, 1);

    await tester.longPress(
      find.byKey(const ValueKey<String>('moon-2026-11-09')),
    );
    expect(pickedDate, DateTime(2026, 11, 9));
    expect(tester.takeException(), isNull);
  });
}
