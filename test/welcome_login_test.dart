import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mengyu_app/app.dart';
import 'package:mengyu_app/core/errors/app_exception.dart';
import 'package:mengyu_app/core/theme/app_theme.dart';
import 'package:mengyu_app/data/repositories/auth_repository.dart';
import 'package:mengyu_app/models/app_user.dart';
import 'package:mengyu_app/pages/login/login_page.dart';
import 'package:mengyu_app/providers/auth_provider.dart';
import 'package:mengyu_app/widgets/primary_button.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 登录必失败：用来验证页面把 Provider.error 变成 SnackBar。
class _FailingAuthRepository extends AuthRepository {
  @override
  Future<AppUser> login(String username, String password) async {
    throw const AppException('账号或密码不正确');
  }

  @override
  Future<AppUser> register(
    String username,
    String password,
    String nickname,
  ) async {
    throw const AppException('注册失败');
  }

  @override
  Future<void> logout() async {}

  @override
  Future<AppUser?> currentUser() async => null;
}

void _usePhoneSize(WidgetTester tester) {
  tester.view.physicalSize = const Size(360, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> _pumpToLogin(WidgetTester tester) async {
  await tester.pumpWidget(const MengYuApp());
  await tester.pumpAndSettle();
  expect(find.text('欢迎来到梦屿'), findsOneWidget);
  await tester.tap(find.byTooltip('关闭'));
  await tester.pumpAndSettle();
  expect(find.text('欢迎回来'), findsOneWidget);
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('首次冷启动显示欢迎浮层，按钮关闭后写 welcome_seen', (
    WidgetTester tester,
  ) async {
    _usePhoneSize(tester);
    await tester.pumpWidget(const MengYuApp());
    await tester.pumpAndSettle();

    expect(find.text('欢迎来到梦屿'), findsOneWidget);
    expect(find.text('WELCOME TO MENGYU'), findsOneWidget);
    expect(find.text('今夜推荐'), findsOneWidget);

    await tester.tap(
      find.widgetWithText(PrimaryButton, '开始今晚的仪式'),
    );
    await tester.pumpAndSettle();
    expect(find.text('欢迎回来'), findsOneWidget);

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('welcome_seen'), isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('游客体验：不进登录态也能打开首页', (WidgetTester tester) async {
    _usePhoneSize(tester);
    await _pumpToLogin(tester);

    final Finder guest = find.text('游客体验');
    await tester.ensureVisible(guest);
    await tester.tap(guest);
    await tester.pumpAndSettle();

    expect(find.text('今夜推荐'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('注册切换：昵称字段出现并成功进入首页', (WidgetTester tester) async {
    _usePhoneSize(tester);
    await _pumpToLogin(tester);

    await tester.tap(find.text('注册'));
    await tester.pumpAndSettle();
    expect(find.text('初次见你'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(3));

    await tester.enterText(find.byType(TextFormField).at(0), 'newuser');
    await tester.enterText(find.byType(TextFormField).at(1), '123456');
    await tester.enterText(find.byType(TextFormField).at(2), '小鱼');

    final Finder submit = find.widgetWithText(PrimaryButton, '注册并进入');
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pumpAndSettle();

    expect(find.text('今夜推荐'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('登录失败显示 SnackBar', (WidgetTester tester) async {
    _usePhoneSize(tester);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>(
            create: (_) => AuthProvider(_FailingAuthRepository()),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.dark,
          home: const LoginPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'xiaoyu');
    await tester.enterText(find.byType(TextFormField).at(1), '123456');
    await tester.tap(find.widgetWithText(PrimaryButton, '登录'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('账号或密码不正确'), findsOneWidget);

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('已看过欢迎：冷启动淡出后直接进首页', (WidgetTester tester) async {
    _usePhoneSize(tester);
    SharedPreferences.setMockInitialValues(<String, Object>{
      'welcome_seen': true,
      'auth.is_logged_in': true,
      'auth.username': 'xiaoyu',
      'auth.nickname': '小鱼',
      'auth.remember_me': true,
    });

    await tester.pumpWidget(const MengYuApp());
    await tester.pumpAndSettle();

    expect(find.text('欢迎来到梦屿'), findsNothing);
    expect(find.text('今夜推荐'), findsOneWidget);
    expect(find.text('欢迎回来'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
