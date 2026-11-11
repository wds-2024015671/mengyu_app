import 'package:flutter_test/flutter_test.dart';
import 'package:mengyu_app/core/errors/app_exception.dart';
import 'package:mengyu_app/data/repositories/local/local_auth_repository.dart';
import 'package:mengyu_app/models/app_user.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('登录态跨实例保留（模拟杀进程重开）', () async {
    const LocalAuthRepository repository = LocalAuthRepository();
    await repository.login('xiaoyu', '123456');

    // 新实例 = 冷启动后重新 new 出来的 Repository，只能从 prefs 读。
    const LocalAuthRepository afterRestart = LocalAuthRepository();
    final AppUser? user = await afterRestart.currentUser();
    expect(user?.username, 'xiaoyu');
    expect(user?.nickname, 'xiaoyu');
  });

  test('注册昵称在退出后再次登录仍保留', () async {
    const LocalAuthRepository repository = LocalAuthRepository();
    await repository.register('xiaoyu', '123456', '小鱼');
    expect((await repository.currentUser())?.nickname, '小鱼');

    await repository.logout();
    expect(await repository.currentUser(), isNull);

    await repository.login('xiaoyu', '123456');
    expect((await repository.currentUser())?.nickname, '小鱼');
  });

  test('取消记住我后重启不恢复登录态', () async {
    const LocalAuthRepository repository = LocalAuthRepository();
    await repository.setRememberMe(false);
    expect(await repository.rememberMe(), isFalse);

    await repository.login('xiaoyu', '123456');
    const LocalAuthRepository afterRestart = LocalAuthRepository();
    expect(await afterRestart.currentUser(), isNull);
  });

  test('冷启动恢复头像路径', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'auth.is_logged_in': true,
      'auth.username': 'xiaoyu',
      'avatar_path': '/data/avatars/avatar_1.jpg',
    });
    const LocalAuthRepository repository = LocalAuthRepository();
    expect(
      (await repository.currentUser())?.avatarPath,
      '/data/avatars/avatar_1.jpg',
    );
  });

  test('空用户名 / 空密码 / 空昵称被拒绝', () async {
    const LocalAuthRepository repository = LocalAuthRepository();
    await expectLater(repository.login('', ''), throwsA(isA<AppException>()));
    await expectLater(
      repository.register('xiaoyu', '123456', ''),
      throwsA(isA<AppException>()),
    );
  });
}
