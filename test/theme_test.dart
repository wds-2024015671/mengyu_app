import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mengyu_app/core/theme/app_theme.dart';
import 'package:mengyu_app/core/theme/app_tokens.dart';

double _contrast(Color a, Color b) {
  final double la = a.computeLuminance();
  final double lb = b.computeLuminance();
  final double hi = la > lb ? la : lb;
  final double lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  test('双主题令牌：正文对比度 ≥4.5，金色按钮深字可读', () {
    for (final AppTokens tokens in <AppTokens>[
      AppTokens.dark,
      AppTokens.light,
    ]) {
      expect(_contrast(tokens.textPrimary, tokens.bgDeep), greaterThan(4.5));
      expect(_contrast(tokens.textSecondary, tokens.bgDeep), greaterThan(4.5));
      expect(_contrast(tokens.onGold, tokens.primary), greaterThan(4.5));
    }
  });

  testWidgets('浅色主题：ThemeExtension、背景和正文色都切换', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Builder(
          builder: (BuildContext context) {
            return Scaffold(
              body: Text('光', style: context.s.body),
            );
          },
        ),
      ),
    );

    final BuildContext context = tester.element(find.text('光'));
    final AppTokens tokens =
        Theme.of(context).extension<AppTokens>()!;
    expect(tokens.bgDeep, AppTokens.light.bgDeep);
    expect(Theme.of(context).scaffoldBackgroundColor, AppTokens.light.bgDeep);
    expect(
      tester.widget<Text>(find.text('光')).style?.color,
      AppTokens.light.textPrimary,
    );
  });

  testWidgets('深色主题仍保持 v7 令牌', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Builder(
          builder: (BuildContext context) {
            return Scaffold(
              body: Text('夜', style: context.s.bodySecondary),
            );
          },
        ),
      ),
    );

    final BuildContext context = tester.element(find.text('夜'));
    expect(
      Theme.of(context).extension<AppTokens>()!.bgDeep,
      AppTokens.dark.bgDeep,
    );
    expect(
      tester.widget<Text>(find.text('夜')).style?.color,
      AppTokens.dark.textSecondary,
    );
  });
}
