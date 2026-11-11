import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mengyu_app/core/routes/app_routes.dart';
import 'package:mengyu_app/core/theme/app_theme.dart';
import 'package:mengyu_app/models/diary_entry.dart';
import 'package:mengyu_app/pages/diary/diary_edit_page.dart';
import 'package:mengyu_app/pages/diary/diary_list_page.dart';
import 'package:mengyu_app/providers/diary_provider.dart';
import 'package:mengyu_app/widgets/primary_button.dart';
import 'package:provider/provider.dart';

import 'support/fake_diary_repository.dart';

typedef DiaryHarness = ({DiaryProvider provider, FakeDiaryRepository repository});

Future<DiaryHarness> _pumpDiary(
  WidgetTester tester,
  FakeDiaryRepository repository,
) async {
  tester.view.physicalSize = const Size(360, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final DiaryProvider provider = DiaryProvider(repository);
  addTearDown(provider.dispose);

  await tester.pumpWidget(
    ChangeNotifierProvider<DiaryProvider>.value(
      value: provider,
      child: MaterialApp(
        theme: AppTheme.dark,
        home: const DiaryListPage(),
        onGenerateRoute: (RouteSettings settings) {
          if (settings.name == AppRoutes.diaryEdit) {
            return MaterialPageRoute<DiaryEntry?>(
              builder: (BuildContext context) => DiaryEditPage(
                entry: settings.arguments as DiaryEntry?,
              ),
            );
          }
          return null;
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
  return (provider: provider, repository: repository);
}

Future<void> _fillAndSaveNewEntry(WidgetTester tester) async {
  await tester.tap(find.byType(FloatingActionButton));
  await tester.pumpAndSettle();

  await tester.tap(find.byIcon(Icons.sentiment_satisfied));
  await tester.pump();

  const String content = '今晚的雨声很轻，慢慢就睡着了。';
  await tester.enterText(find.byType(TextFormField), content);
  await tester.ensureVisible(find.widgetWithText(FilterChip, '平静'));
  await tester.tap(find.widgetWithText(FilterChip, '平静'));
  await tester.pump();

  await tester.ensureVisible(find.widgetWithText(PrimaryButton, '保存'));
  await tester.tap(find.widgetWithText(PrimaryButton, '保存'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('日记：空态 → 新建 → 列表回显', (WidgetTester tester) async {
    final FakeDiaryRepository repository = FakeDiaryRepository();
    final DiaryHarness harness = await _pumpDiary(tester, repository);

    expect(find.text('还没有日记'), findsOneWidget);
    await _fillAndSaveNewEntry(tester);

    expect(find.text('今晚的雨声很轻，慢慢就睡着了。'), findsOneWidget);
    expect(harness.provider.entries.length, 1);
    expect(harness.repository.entries.single.mood, 4);
    expect(harness.repository.entries.single.tags, contains('平静'));
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('日记：分组、编辑预填、删除二次确认', (WidgetTester tester) async {
    final FakeDiaryRepository repository = FakeDiaryRepository(
      seed: <DiaryEntry>[
        DiaryEntry(
          id: 1,
          entryDate: DateTime(2026, 11, 8),
          mood: 2,
          content: '昨天没睡好。',
          tags: const <String>['疲惫'],
          createdAt: DateTime(2026, 11, 8, 22),
        ),
        DiaryEntry(
          id: 2,
          entryDate: DateTime(2026, 11, 9),
          mood: 5,
          content: '今天完成了呼吸练习。',
          tags: const <String>['平静', '开心'],
          createdAt: DateTime(2026, 11, 9, 22),
        ),
      ],
    );
    final DiaryHarness harness = await _pumpDiary(tester, repository);

    expect(find.text('今天完成了呼吸练习。'), findsOneWidget);
    expect(find.text('昨天没睡好。'), findsOneWidget);
    expect(find.textContaining('11 月 9 日'), findsWidgets);
    expect(find.textContaining('11 月 8 日'), findsWidgets);

    await tester.tap(find.text('今天完成了呼吸练习。'));
    await tester.pumpAndSettle();
    expect(find.text('编辑日记'), findsOneWidget);
    final TextFormField field = tester.widget<TextFormField>(
      find.byType(TextFormField),
    );
    expect(field.controller?.text, '今天完成了呼吸练习。');

    const String updated = '今天呼吸完，心里安静了很多。';
    await tester.enterText(find.byType(TextFormField), updated);
    await tester.ensureVisible(find.widgetWithText(PrimaryButton, '保存修改'));
    await tester.tap(find.widgetWithText(PrimaryButton, '保存修改'));
    await tester.pumpAndSettle();

    expect(find.text(updated), findsOneWidget);
    expect(harness.repository.entries.length, 2);
    expect(
      harness.repository.entries.firstWhere((DiaryEntry e) => e.id == 2).content,
      updated,
    );

    // 删除昨天那条：更多 → 删除 → 确认删除
    await tester.tap(find.byIcon(Icons.more_horiz).at(1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('删除'));
    await tester.pumpAndSettle();
    expect(find.text('删除这篇日记？'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, '删除'));
    await tester.pumpAndSettle();

    expect(find.text('昨天没睡好。'), findsNothing);
    expect(harness.provider.entries.length, 1);
    expect(harness.repository.entries.length, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('日记编辑：心情必选、正文至少 5 个字', (WidgetTester tester) async {
    final FakeDiaryRepository repository = FakeDiaryRepository();
    final DiaryHarness harness = await _pumpDiary(tester, repository);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), '短');
    await tester.ensureVisible(find.widgetWithText(PrimaryButton, '保存'));
    await tester.tap(find.widgetWithText(PrimaryButton, '保存'));
    await tester.pumpAndSettle();

    expect(find.text('请选择今天的心情'), findsOneWidget);
    expect(find.text('至少写 5 个字'), findsOneWidget);
    expect(harness.repository.entries, isEmpty);
    expect(find.text('写日记'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
