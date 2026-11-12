import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mengyu_app/app.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fake_audio_engine.dart';

void _phone(WidgetTester tester) {
  tester.view.physicalSize = const Size(360, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'welcome_seen': true,
      'auth.is_logged_in': true,
      'auth.username': 'xiaoyu',
      'auth.nickname': '小鱼',
      'auth.remember_me': true,
    });
  });

  testWidgets('今晚：睡眠摘要卡与完整详情页', (WidgetTester tester) async {
    _phone(tester);
    await tester.pumpWidget(
      MengYuApp(audioEngineFactory: () => FakeAudioEngine()),
    );
    await tester.pump(const Duration(milliseconds: 2600));
    await tester.pumpAndSettle();

    final Finder title = find.text('睡眠温馨提醒');
    await tester.scrollUntilVisible(
      title,
      260,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(title, findsOneWidget);
    expect(find.text('行为核心'), findsOneWidget);
    expect(find.text('环境、饮食与运动'), findsOneWidget);
    expect(find.text('心理与放松'), findsOneWidget);
    expect(find.text('呼吸法介绍'), findsOneWidget);
    expect(find.text('如果长期失眠，建议寻求专业评估'), findsOneWidget);
    expect(find.text('3 条提醒'), findsNothing);
    expect(find.text('CBT-I'), findsNothing);

    await tester.tap(find.byTooltip('查看睡眠提醒'));
    await tester.pumpAndSettle();

    expect(find.text('睡眠温馨提醒'), findsOneWidget);
    expect(find.text('4 个练习与原则'), findsOneWidget);
    expect(find.text('01'), findsOneWidget);
    expect(find.text('04'), findsOneWidget);
    expect(find.text('4-7-8 呼吸法'), findsOneWidget);
    expect(find.text('方块呼吸法'), findsOneWidget);
    expect(find.text('4-4-6 呼吸法'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.textContaining('CBT-I'),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(
      find.textContaining('寻求专业评估和 CBT-I 治疗'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);

    await tester.tap(find.byTooltip('返回'));
    await tester.pumpAndSettle();
    expect(find.text('今夜推荐'), findsOneWidget);
  });
}
