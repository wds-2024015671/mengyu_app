import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mengyu_app/core/theme/app_theme.dart';
import 'package:mengyu_app/data/services/sleep_tracking_service.dart';
import 'package:mengyu_app/models/sleep_tracking_record.dart';
import 'package:mengyu_app/pages/tabs/widgets/sleep_confirm_dialog.dart';
import 'package:mengyu_app/pages/tabs/widgets/sleep_pending_banner.dart';
import 'package:mengyu_app/providers/sleep_tracking_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fake_session_repository.dart';
import 'support/fake_sleep_tracking.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('待确认 banner：点击进入确认，确认后写入一条自动记录', (
    WidgetTester tester,
  ) async {
    final DateTime now = DateTime(2026, 11, 11, 7, 31);
    final SleepTrackingRecord pending = SleepTrackingRecord(
      id: 1,
      nightKey: '2026-11-10',
      startAt: DateTime(2026, 11, 10, 23),
      status: SleepTrackingStatus.pending,
      createdAt: DateTime(2026, 11, 10, 23),
    );
    final FakeSleepTrackingRepository tracking =
        FakeSleepTrackingRepository(pending);
    final FakeSessionRepository sessions = FakeSessionRepository();
    final SleepTrackingProvider provider = SleepTrackingProvider(
      SleepTrackingService(
        tracking: tracking,
        sessions: sessions,
        notifications: FakeSleepNotificationService(),
        clock: () => now,
      ),
    );
    addTearDown(provider.dispose);
    await provider.initialize();
    expect(provider.pending, isNotNull);
    expect(provider.needsPrompt, isTrue);

    await tester.pumpWidget(
      ChangeNotifierProvider<SleepTrackingProvider>.value(
        value: provider,
        child: MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(
            body: SleepPendingBanner(
              record: provider.pending!,
              onTap: () => showSleepConfirmDialog(
                tester.element(find.byType(SleepPendingBanner)),
                record: provider.pending!,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('昨晚记录待确认'), findsOneWidget);
    await tester.tap(find.text('昨晚记录待确认'));
    await tester.pumpAndSettle();
    expect(find.text('昨晚睡眠待确认'), findsOneWidget);

    await tester.tap(find.text('确认'));
    await tester.pumpAndSettle();

    expect(sessions.saved.length, 1);
    expect(provider.pending, isNull);
    expect(tester.takeException(), isNull);
  });
}
