import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mengyu_app/core/theme/app_theme.dart';
import 'package:mengyu_app/models/audio_item.dart';
import 'package:mengyu_app/models/sleep_session.dart';
import 'package:mengyu_app/pages/tabs/widgets/home_recent_list.dart';

void main() {
  testWidgets('最近播放：56 高行，匹配音景打开播放器，否则打开记录', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const AudioItem rain = AudioItem.builtIn(
      id: 'local_rain',
      title: '雨声',
      category: '雨声',
      assetPath: 'audio/rain_loop.wav',
    );
    final DateTime now = DateTime.now();
    final DateTime bed = now.subtract(const Duration(hours: 8));
    final SleepSession played = SleepSession(
      bedTime: bed,
      wakeTime: now,
      quality: 4,
      note: '声音仪式：雨声',
    );
    final SleepSession manual = SleepSession(
      bedTime: bed.subtract(const Duration(days: 1)),
      wakeTime: now.subtract(const Duration(days: 1)),
      quality: 3,
      note: '补记的睡眠',
    );

    AudioItem? openedAudio;
    SleepSession? openedSession;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: HomeRecentList(
              sessions: <SleepSession>[played, manual],
              audios: const <AudioItem>[rain],
              onOpenAudio: (AudioItem item) => openedAudio = item,
              onOpenSession: (SleepSession session) =>
                  openedSession = session,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('雨声'), findsOneWidget);
    expect(find.text('补记的睡眠'), findsOneWidget);
    expect(tester.getSize(find.byType(InkWell).first).height, 56);

    await tester.tap(find.text('雨声'));
    await tester.pump();
    expect(openedAudio?.id, 'local_rain');

    await tester.tap(find.text('补记的睡眠'));
    await tester.pump();
    expect(openedSession?.note, '补记的睡眠');
    expect(tester.takeException(), isNull);
  });
}
