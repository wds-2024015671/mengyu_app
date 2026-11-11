import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mengyu_app/core/theme/app_theme.dart';
import 'package:mengyu_app/widgets/app_background.dart';
import 'package:mengyu_app/widgets/async_view.dart';
import 'package:mengyu_app/widgets/empty_state.dart';
import 'package:mengyu_app/widgets/glass_card.dart';
import 'package:mengyu_app/widgets/mood_picker.dart';
import 'package:mengyu_app/widgets/primary_button.dart';
import 'package:mengyu_app/widgets/section_header.dart';
import 'package:mengyu_app/widgets/stat_tile.dart';

/// 组件测试统一用 360×800，任何溢出都会变成测试异常。
Widget _host(Widget child) {
  return MaterialApp(
    theme: AppTheme.dark,
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: child,
          ),
        ),
      ),
    ),
  );
}

void _usePhoneSize(WidgetTester tester) {
  tester.view.physicalSize = const Size(360, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  testWidgets('公共组件在 360×800 组合不溢出', (WidgetTester tester) async {
    _usePhoneSize(tester);
    bool emptyActionTapped = false;
    await tester.pumpWidget(
      _host(
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SectionHeader(
              title: '今夜推荐',
              subtitle: '按心情挑一段',
              actionLabel: '查看全部',
              onAction: () {},
            ),
            const SizedBox(height: 16),
            const Row(
              children: <Widget>[
                Expanded(
                  child: StatTile(
                    value: '6 小时 42 分',
                    label: '平均时长',
                    icon: Icons.bedtime_outlined,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(child: StatTile(value: '12', label: '连续天数', unit: '天')),
                SizedBox(width: 12),
                Expanded(child: StatTile(value: '3', label: '仪式次数', emphasize: true)),
              ],
            ),
            const SizedBox(height: 16),
            const GlassCard(child: Text('玻璃卡片')),
            const SizedBox(height: 16),
            EmptyState(
              icon: Icons.menu_book_outlined,
              title: '还没有日记',
              message: '第一篇会出现在这里。',
              actionLabel: '写一篇',
              onAction: () => emptyActionTapped = true,
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('今夜推荐'), findsOneWidget);
    expect(find.text('6 小时 42 分'), findsOneWidget);
    expect(find.text('玻璃卡片'), findsOneWidget);
    expect(find.text('还没有日记'), findsOneWidget);

    await tester.tap(find.text('写一篇'));
    await tester.pumpAndSettle();
    expect(emptyActionTapped, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('PrimaryButton：正常点击、禁用、loading 三种状态', (WidgetTester tester) async {
    _usePhoneSize(tester);
    int taps = 0;

    await tester.pumpWidget(
      _host(
        PrimaryButton(
          label: '开始今夜',
          icon: Icons.play_arrow,
          onPressed: () => taps++,
        ),
      ),
    );
    await tester.tap(find.text('开始今夜'));
    await tester.pumpAndSettle();
    expect(taps, 1);

    await tester.pumpWidget(
      _host(const PrimaryButton(label: '不可用', onPressed: null)),
    );
    await tester.tap(find.text('不可用'));
    await tester.pumpAndSettle();
    expect(taps, 1);

    await tester.pumpWidget(
      _host(
        PrimaryButton(
          label: '提交中',
          loading: true,
          onPressed: () => taps++,
        ),
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.tap(find.byType(CircularProgressIndicator));
    await tester.pump();
    expect(taps, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('AsyncView：loading / error+retry / empty / data 四态', (WidgetTester tester) async {
    _usePhoneSize(tester);
    int retries = 0;

    await tester.pumpWidget(
      _host(
        AsyncView<int>(
          isLoading: true,
          data: null,
          onRetry: () => retries++,
          builder: (BuildContext context, int value) => Text('值 $value'),
        ),
      ),
    );
    expect(find.text('正在加载'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpWidget(
      _host(
        AsyncView<int>(
          isLoading: false,
          data: null,
          error: '网络开小差了',
          onRetry: () => retries++,
          builder: (BuildContext context, int value) => Text('值 $value'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('网络开小差了'), findsOneWidget);
    await tester.tap(find.text('重试'));
    await tester.pumpAndSettle();
    expect(retries, 1);

    await tester.pumpWidget(
      _host(
        AsyncView<List<int>>(
          isLoading: false,
          data: const <int>[],
          isEmpty: true,
          builder: (BuildContext context, List<int> value) => Text('共 ${value.length} 条'),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('这里还是空的'), findsOneWidget);

    await tester.pumpWidget(
      _host(
        AsyncView<int>(
          isLoading: false,
          data: 42,
          builder: (BuildContext context, int value) => Text('值 $value'),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('值 42'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('MoodPicker：点选回调分值，选中项保持放大', (WidgetTester tester) async {
    _usePhoneSize(tester);
    int? picked;

    await tester.pumpWidget(
      _host(MoodPicker(value: 2, onChanged: (int value) => picked = value)),
    );
    await tester.pumpAndSettle();
    expect(find.text('低落'), findsOneWidget);

    await tester.tap(find.text('不错'));
    await tester.pumpAndSettle();
    expect(picked, 4);

    final AnimatedScale selectedScale = tester.widget<AnimatedScale>(
      find.byType(AnimatedScale).at(1),
    );
    expect(selectedScale.scale, 1.12);
    expect(tester.takeException(), isNull);
  });
}
