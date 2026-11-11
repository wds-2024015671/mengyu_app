import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mengyu_app/core/theme/app_theme.dart';
import 'package:mengyu_app/pages/tabs/widgets/profile_header.dart';

void main() {
  testWidgets('资料头像：56 圆头像、相册角标、无图回退月亮', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: ProfileHeader(
            nickname: '小鱼',
            streakDays: 3,
            joinedDays: 10,
            avatarPath: '/not/exists/avatar.jpg',
            onTap: () {},
            onTapAvatar: () {},
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(Image), findsNothing);
    expect(find.byIcon(Icons.nightlight_outlined), findsOneWidget);
    expect(find.byIcon(Icons.photo_camera_outlined), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const Key('profile-avatar'))),
      const Size(56, 56),
    );
    expect(tester.takeException(), isNull);
  });
}
