import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mengyu_app/app.dart';
import 'support/fake_audio_engine.dart';
import 'package:mengyu_app/core/routes/app_routes.dart';
import 'package:mengyu_app/models/audio_item.dart';
import 'package:mengyu_app/models/diary_entry.dart';
import 'package:mengyu_app/models/sleep_session.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    // 已登录：MainShell 的首帧登录检查会放行，路由测试才能直接开 tab 路由。
    SharedPreferences.setMockInitialValues(<String, Object>{
      'welcome_seen': true,
      'auth.is_logged_in': true,
      'auth.username': 'xiaoyu',
      'auth.nickname': '小鱼',
      'auth.remember_me': true,
    });
  });

  testWidgets('14 条路由在 360×800 下都能打开且无溢出', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(MengYuApp(audioEngineFactory: () => FakeAudioEngine()));
    // 欢迎页自动分流到 /home（已登录），等定时器与转场都结束
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.text('今夜推荐'), findsOneWidget);

    final NavigatorState navigator = tester.state<NavigatorState>(
      find.byType(Navigator).first,
    );

    Future<void> open(String name, {Object? arguments, required Finder expectFinder}) async {
      navigator.pushNamed(name, arguments: arguments);
      await tester.pumpAndSettle();
      expect(expectFinder, findsWidgets, reason: '路由 $name 没有打开预期页面');
      navigator.pop();
      await tester.pumpAndSettle();
    }

    // 4 个 tab 路由各自能独立打开（initialTab 生效）
    await open(AppRoutes.sound, expectFinder: find.text('把世界调成静音'));
    await open(AppRoutes.report, expectFinder: find.text('月迹'));
    await open(AppRoutes.profile, expectFinder: find.text('我的'));

    await open(AppRoutes.upload, expectFinder: find.text('选择音频文件'));

    await open(
      AppRoutes.player,
      arguments: const AudioItem.builtIn(
        id: 'local_rain',
        title: '雨声',
        category: '雨',
        assetPath: 'audio/rain.wav',
        durationSec: 300,
      ),
      expectFinder: find.text('正在播放'),
    );

    await open(AppRoutes.timer, arguments: 30, expectFinder: find.text('30'));
    await open(AppRoutes.timer, expectFinder: find.text('30'));

    await open(AppRoutes.breathing, expectFinder: find.text('4-7-8 呼吸'));
    // /breathing_session 有持续动画，不能 pumpAndSettle；由 breathing_session_test 单独覆盖。

    // VM 没有 sqflite 插件，日记页会走真实 Local 仓库的失败态；真机首次启动才建表。
    await open(AppRoutes.diary, expectFinder: find.text('睡前日记'));
    await open(AppRoutes.diaryEdit, expectFinder: find.text('写日记'));
    await open(
      AppRoutes.diaryEdit,
      arguments: DiaryEntry(entryDate: DateTime(2026, 11, 8), mood: 3, content: '今晚的风很轻'),
      expectFinder: find.text('编辑日记'),
    );

    await open(AppRoutes.sleepLogForm, expectFinder: find.text('补记睡眠'));
    await open(
      AppRoutes.sleepLogForm,
      arguments: SleepSession(
        bedTime: DateTime(2026, 11, 8, 23, 30),
        wakeTime: DateTime(2026, 11, 9, 7, 15),
        quality: 4,
      ),
      expectFinder: find.text('睡眠时长'),
    );

    // 未知路由兜底
    await open('/not_exist', expectFinder: find.text('走丢了'));
    // 参数类型不符也兜底
    await open(AppRoutes.player, arguments: 'wrong', expectFinder: find.text('走丢了'));

    expect(tester.takeException(), isNull);
  });
}
