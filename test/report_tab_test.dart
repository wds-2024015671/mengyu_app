import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mengyu_app/core/theme/app_theme.dart';
import 'package:mengyu_app/models/sleep_session.dart';
import 'package:mengyu_app/pages/tabs/report_tab.dart';
import 'package:mengyu_app/providers/sleep_provider.dart';
import 'package:mengyu_app/widgets/glass_card.dart';
import 'package:provider/provider.dart';

import 'support/fake_session_repository.dart';

Future<SleepProvider> _pumpReport(
  WidgetTester tester, {
  required List<SleepSession> sessions,
  required DateTime today,
  ValueChanged<Object?>? onSleepRoute,
}) async {
  tester.view.physicalSize = const Size(360, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final SleepProvider provider = SleepProvider(
    FakeSessionRepository(sessions),
    clock: () => today,
  );
  addTearDown(provider.dispose);

  await tester.pumpWidget(
    ChangeNotifierProvider<SleepProvider>.value(
      value: provider,
      child: MaterialApp(
        theme: AppTheme.dark,
        home: const Scaffold(body: ReportTab(active: true)),
        onGenerateRoute: (RouteSettings settings) {
          onSleepRoute?.call(settings.arguments);
          return MaterialPageRoute<bool?>(
            builder: (BuildContext context) =>
                const Scaffold(body: Center(child: Text('补记页'))),
          );
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
  return provider;
}

List<SleepSession> _sessions() {
  return <SleepSession>[
    SleepSession(
      bedTime: DateTime(2026, 11, 9, 23),
      wakeTime: DateTime(2026, 11, 10, 7),
      quality: 4,
    ),
    SleepSession(
      bedTime: DateTime(2026, 11, 10, 23, 30),
      wakeTime: DateTime(2026, 11, 11, 7),
      quality: 3,
    ),
    SleepSession(
      bedTime: DateTime(2026, 11, 11, 23),
      wakeTime: DateTime(2026, 11, 12, 6, 30),
      quality: 4,
    ),
    SleepSession(
      bedTime: DateTime(2026, 11, 3, 23),
      wakeTime: DateTime(2026, 11, 4, 7),
      quality: 4,
    ),
  ];
}

void main() {
  testWidgets('月迹：周汇总 / 7 柱 / 三项统计 / 30 格月相，无最近记录', (
    WidgetTester tester,
  ) async {
    await _pumpReport(
      tester,
      sessions: _sessions(),
      today: DateTime(2026, 11, 12),
    );

    expect(find.text('月迹'), findsOneWidget);
    expect(find.text('11月9日 — 11月15日'), findsOneWidget);
    expect(find.text('本周'), findsOneWidget);
    expect(find.text('本周平均睡眠'), findsOneWidget);
    expect(find.text('7h 40m'), findsOneWidget);
    expect(find.text('↓ 20m'), findsOneWidget);

    expect(find.text('每日睡眠时长（小时）'), findsOneWidget);
    expect(find.text('8h 参考'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (Widget widget) =>
            widget.key is ValueKey<String> &&
            (widget.key! as ValueKey<String>).value.startsWith('report-bar-'),
      ),
      findsNWidgets(7),
    );

    expect(find.text('连续靠岸'), findsOneWidget);
    expect(find.text('平均入睡'), findsOneWidget);
    expect(find.text('23:10'), findsOneWidget);
    expect(find.text('本周仪式'), findsOneWidget);
    expect(find.text('7h30m'), findsNWidgets(2));

    expect(find.text('本月月迹 · 30 天'), findsOneWidget);
    expect(find.text('月相=完成，横条=时长'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (Widget widget) =>
            widget.key is ValueKey<String> &&
            (widget.key! as ValueKey<String>).value.startsWith('moon-'),
      ),
      findsNWidgets(30),
    );
    expect(
      find.byKey(const ValueKey<String>('moon-2026-11-12')),
      findsOneWidget,
    );

    final List<GlassCard> cards = tester
        .widgetList<GlassCard>(find.byType(GlassCard))
        .toList(growable: false);
    expect(cards.length, 3);
    expect(cards.where((GlassCard card) => card.outlined).length, 2);
    expect(find.text('最近记录'), findsNothing);
    expect(find.text('补记'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('月迹：右下角固定补记按钮不随列表滚动', (
    WidgetTester tester,
  ) async {
    await _pumpReport(
      tester,
      sessions: _sessions(),
      today: DateTime(2026, 11, 12),
    );

    final Finder button = find.byKey(const ValueKey<String>('report-add'));
    expect(button, findsOneWidget);
    final Offset before = tester.getCenter(button);

    await tester.drag(find.byType(ListView).first, const Offset(0, -260));
    await tester.pumpAndSettle();
    expect(tester.getCenter(button), before);

    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(find.text('补记页'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('月迹：点哪一天就用哪一天作为补记入睡日', (
    WidgetTester tester,
  ) async {
    Object? arguments;
    await _pumpReport(
      tester,
      sessions: _sessions(),
      today: DateTime(2026, 11, 12),
      onSleepRoute: (Object? value) => arguments = value,
    );

    final Finder cell = find.byKey(
      const ValueKey<String>('moon-2026-11-08'),
    );
    await tester.ensureVisible(cell);
    await tester.tap(cell);
    await tester.pumpAndSettle();

    expect(arguments, isA<SleepSession>());
    final SleepSession session = arguments! as SleepSession;
    expect(session.bedTime, DateTime(2026, 11, 8, 23));
    expect(session.wakeTime, DateTime(2026, 11, 9, 7));
    expect(tester.takeException(), isNull);
  });

  testWidgets('月迹：无记录只保留头部与补记昨晚空态', (WidgetTester tester) async {
    await _pumpReport(
      tester,
      sessions: <SleepSession>[],
      today: DateTime(2026, 11, 12),
    );

    expect(find.text('还没有睡眠记录'), findsOneWidget);
    expect(find.text('补记昨晚'), findsOneWidget);
    expect(find.text('本周平均睡眠'), findsNothing);
    expect(find.text('每日睡眠时长（小时）'), findsNothing);
    expect(find.text('连续靠岸'), findsNothing);
    expect(find.text('本月月迹 · 30 天'), findsNothing);
    expect(find.text('补记'), findsNothing);
    expect(find.byType(GlassCard), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('月迹：不足 3 晚不画柱，显示图表空态', (WidgetTester tester) async {
    await _pumpReport(
      tester,
      sessions: <SleepSession>[
        SleepSession(
          bedTime: DateTime(2026, 11, 9, 23),
          wakeTime: DateTime(2026, 11, 10, 7),
          quality: 4,
        ),
      ],
      today: DateTime(2026, 11, 12),
    );

    expect(find.text('8h'), findsWidgets);
    expect(find.text('记录满 3 晚后生成周图'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (Widget widget) =>
            widget.key is ValueKey<String> &&
            (widget.key! as ValueKey<String>).value.startsWith('report-bar-'),
      ),
      findsNothing,
    );
    expect(find.text('连续靠岸'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('月迹：周切换只过滤本地 sessions', (WidgetTester tester) async {
    await _pumpReport(
      tester,
      sessions: _sessions(),
      today: DateTime(2026, 11, 12),
    );
    expect(find.text('11月9日 — 11月15日'), findsOneWidget);

    await tester.tap(find.byTooltip('上一周'));
    await tester.pumpAndSettle();
    expect(find.text('上周'), findsOneWidget);
    expect(find.text('11月2日 — 11月8日'), findsOneWidget);
    expect(find.text('8h'), findsWidgets);

    await tester.tap(find.byTooltip('下一周'));
    await tester.pumpAndSettle();
    expect(find.text('本周'), findsOneWidget);
    expect(find.text('11月9日 — 11月15日'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
