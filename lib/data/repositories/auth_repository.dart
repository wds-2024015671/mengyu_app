import '../../models/app_user.dart';

/// 认证能力抽象。
///
/// 本阶段由 LocalAuthRepository 实现（prefs 本地登录态）；后端阶段换成
/// ApiAuthRepository 即可，页面与 Provider 一行都不用改。
/// 页面禁止直接 import shared_preferences 或 dio 来做登录。
abstract class AuthRepository {
  /// 登录成功返回当前用户；失败抛异常由 Provider 转成 error 文案。
  Future<AppUser> login(String username, String password);

  /// 注册成功即视为已登录。
  Future<AppUser> register(String username, String password, String nickname);

  Future<void> logout();

  /// 冷启动恢复登录态；未登录返回 null。
  Future<AppUser?> currentUser();

  /// 「记住我」偏好：只影响下一次冷启动是否恢复登录态。
  ///
  /// 默认实现返回 true（API 实现可以忽略这个偏好，token 本来就持久化）；
  /// Local 实现会读写 prefs，登录时按它决定 isLoggedIn 落不落盘。
  Future<bool> rememberMe() async => true;

  /// 保存「记住我」；默认实现不持久化，Api 实现可忽略。
  Future<void> setRememberMe(bool value) async {}
}
