import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mengyu_app/core/constants/app_limits.dart';
import 'package:mengyu_app/widgets/primary_button.dart';

import 'support/upload_test_harness.dart';

Future<void> _fillValidForm(WidgetTester tester) async {
  await tester.ensureVisible(find.byType(TextFormField).at(0));
  await tester.enterText(find.byType(TextFormField).at(0), '我的雨声');

  final Finder category = find.byType(DropdownButtonFormField<String>);
  await tester.ensureVisible(category);
  await tester.tap(category);
  await tester.pumpAndSettle();
  await tester.tap(find.text('雨声').last);
  await tester.pumpAndSettle();

  await tester.ensureVisible(find.byType(Checkbox));
  await tester.tap(find.byType(Checkbox));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('上传页：选文件 / 空表单校验 / 提交成功 pop(true)', (
    WidgetTester tester,
  ) async {
    final UploadHarness harness = await openUploadPage(
      tester,
      picker: () async => pickedAudioFile(),
    );
    expect(find.text('上传声音'), findsOneWidget);

    // 选文件后显示文件名与大小
    await tester.tap(find.text('选择音频文件'));
    await tester.pumpAndSettle();
    expect(find.text('rain.wav'), findsOneWidget);
    expect(find.text('2 KB'), findsOneWidget);

    // 直接提交：标题 / 分类 / 版权承诺三处校验
    final Finder submit = find.widgetWithText(PrimaryButton, '提交审核');
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pumpAndSettle();
    expect(find.text('请填写标题'), findsOneWidget);
    expect(find.text('请选择分类'), findsOneWidget);
    expect(find.text('请勾选版权承诺后再提交'), findsOneWidget);

    await _fillValidForm(tester);
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pumpAndSettle();

    expect(harness.repository.lastPath, '/tmp/rain.wav');
    expect(harness.repository.lastTitle, '我的雨声');
    expect(harness.repository.lastCategory, '雨声');
    expect(harness.repository.lastDescription, '');
    expect(await harness.result, isTrue);

    // pop 回 host，页面已关闭
    expect(find.text('host'), findsOneWidget);
    expect(find.text('上传声音'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('超过 20MB 在选文件阶段被拦下', (WidgetTester tester) async {
    await openUploadPage(
      tester,
      picker: () async => pickedAudioFile(
        size: kMaxAudioUploadBytes + 1,
        name: 'big.wav',
      ),
    );

    await tester.tap(find.text('选择音频文件'));
    await tester.pumpAndSettle();

    expect(find.text('音频文件不能超过 20MB'), findsOneWidget);
    expect(find.text('big.wav'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('本地复制失败显示 SnackBar，页面不关闭', (
    WidgetTester tester,
  ) async {
    await openUploadPage(
      tester,
      picker: () async => pickedAudioFile(),
      uploadRepository: FakeUploadRepository(fail: true),
    );

    await tester.tap(find.text('选择音频文件'));
    await tester.pumpAndSettle();
    await _fillValidForm(tester);

    final Finder submit = find.widgetWithText(PrimaryButton, '提交审核');
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('文件复制失败，请检查存储空间后重试'), findsOneWidget);
    expect(find.text('上传声音'), findsOneWidget);
    expect(tester.takeException(), isNull);

    // 等 SnackBar 自动收起，避免残留计时器
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });

  testWidgets('未登录（含游客）进入 /upload 跳 /login', (
    WidgetTester tester,
  ) async {
    await openUploadPage(
      tester,
      picker: () async => null,
      authRepository: FakeAuthRepository(),
    );

    expect(find.text('login-page'), findsOneWidget);
    expect(find.text('上传声音'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
