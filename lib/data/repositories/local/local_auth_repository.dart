import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/errors/app_exception.dart';
import '../../../models/app_user.dart';
import '../auth_repository.dart';

/// 本地认证实现：账号信息只存 shared_preferences，不发任何网络请求。
///
/// 为什么登录不校验密码：本阶段没有服务端，按 F03 约定“任意合法输入即成功”；
/// 但空用户名/空密码仍然拒绝，避免生成一个没有身份的登录态。
class LocalAuthRepository implements AuthRepository {
  const LocalAuthRepository();

  static const String _loggedInKey = 'auth.is_logged_in';
  static const String _usernameKey = 'auth.username';
  static const String _nicknameKey = 'auth.nickname';
  static const String _joinedAtKey = 'auth.joined_at';
  static const String _rememberKey = 'auth.remember_me';
  static const String _avatarPathKey = 'avatar_path';

  @override
  Future<AppUser> login(String username, String password) async {
    final String name = username.trim();
    if (name.isEmpty || password.isEmpty) {
      throw const AppException('请输入用户名和密码');
    }
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? storedName = prefs.getString(_usernameKey);
    // 同名账号沿用注册时的昵称，换账号则用用户名兜底。
    final String nickname = storedName == name
        ? (prefs.getString(_nicknameKey) ?? name)
        : name;
    final DateTime joinedAt = _readJoinedAt(prefs) ?? DateTime.now();

    // 「记住我」只决定登录态要不要写盘；本会话内 Provider 仍持有 user。
    final bool remember = prefs.getBool(_rememberKey) ?? true;
    await prefs.setBool(_loggedInKey, remember);
    await prefs.setString(_usernameKey, name);
    await prefs.setString(_nicknameKey, nickname);
    await prefs.setString(_joinedAtKey, joinedAt.toIso8601String());

    return AppUser(
      username: name,
      nickname: nickname,
      joinedAt: joinedAt,
      avatarPath: prefs.getString(_avatarPathKey),
    );
  }

  @override
  Future<AppUser> register(
    String username,
    String password,
    String nickname,
  ) async {
    final String name = username.trim();
    final String nick = nickname.trim();
    if (name.isEmpty || password.isEmpty) {
      throw const AppException('请输入用户名和密码');
    }
    if (nick.isEmpty) {
      throw const AppException('请输入昵称');
    }
    final DateTime joinedAt = DateTime.now();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool remember = prefs.getBool(_rememberKey) ?? true;
    await prefs.setBool(_loggedInKey, remember);
    await prefs.setString(_usernameKey, name);
    await prefs.setString(_nicknameKey, nick);
    await prefs.setString(_joinedAtKey, joinedAt.toIso8601String());

    return AppUser(
      username: name,
      nickname: nick,
      joinedAt: joinedAt,
      avatarPath: prefs.getString(_avatarPathKey),
    );
  }

  @override
  Future<void> logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // 只清登录态，保留账号资料，下次登录仍能恢复昵称。
    await prefs.setBool(_loggedInKey, false);
  }

  @override
  Future<AppUser?> currentUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool(_loggedInKey) ?? false)) {
      return null;
    }
    final String? username = prefs.getString(_usernameKey);
    if (username == null || username.isEmpty) {
      return null;
    }
    return AppUser(
      username: username,
      nickname: prefs.getString(_nicknameKey) ?? username,
      joinedAt: _readJoinedAt(prefs),
      avatarPath: prefs.getString(_avatarPathKey),
    );
  }

  @override
  Future<bool> rememberMe() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_rememberKey) ?? true;
  }

  @override
  Future<void> setRememberMe(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberKey, value);
  }

  DateTime? _readJoinedAt(SharedPreferences prefs) {
    final String? raw = prefs.getString(_joinedAtKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return DateTime.tryParse(raw);
  }
}
