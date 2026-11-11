import 'package:flutter/foundation.dart';

import '../core/errors/app_exception.dart';
import '../data/repositories/auth_repository.dart';
import '../models/app_user.dart';

/// 登录态：只依赖 AuthRepository，页面不直接碰 prefs / 接口实现。
class AuthProvider extends ChangeNotifier {
  AuthProvider(this._repository);

  final AuthRepository _repository;

  AppUser? _user;
  bool _isLoading = false;
  bool _loaded = false;
  bool _rememberMe = true;
  String? _error;
  Future<void>? _inFlight;

  AppUser? get user => _user;

  /// 有会话：账号登录或游客体验，MainShell 用它判断能不能留在主页。
  bool get hasSession => _user != null;

  /// 真实账号登录（游客不算）。
  bool get isLoggedIn => _user != null && !_user!.isAnonymous;

  bool get isGuest => _user?.isAnonymous ?? false;
  bool get isLoading => _isLoading;
  bool get rememberMe => _rememberMe;
  String? get error => _error;
  String get nickname => _user?.nickname ?? AppUser.anonymous.nickname;

  /// 头像写入后同步内存用户，页面无需等下次冷启动。
  void setAvatarPath(String? path) {
    final AppUser? current = _user;
    if (current == null) {
      return;
    }
    _user = AppUser(
      id: current.id,
      username: current.username,
      nickname: current.nickname,
      avatarPath: path,
      joinedAt: current.joinedAt,
    );
    notifyListeners();
  }

  /// 启动时恢复登录态与「记住我」；并发调用共享同一个 Future。
  ///
  /// 为什么不在构造函数里自动执行：Provider 创建于首帧之前，
  /// 此时插件通道可能还没就绪；由欢迎页 / MainShell 显式触发更安全。
  Future<void> ensureLoaded({bool force = false}) {
    final Future<void>? current = _inFlight;
    if (current != null) {
      return current;
    }
    if (_loaded && !force) {
      return Future<void>.value();
    }
    _loaded = true;
    final Future<void> future = _load();
    _inFlight = future;
    return future.whenComplete(() {
      _inFlight = null;
    });
  }

  Future<void> _load() async {
    _isLoading = true;
    _error = null;
    // 不在这里 notify：本方法由欢迎页 initState 调用，首帧 build 期间
    // 通知 Provider 会触发 markNeedsBuild 断言；结束后的 notify 足够刷新 UI。
    try {
      _user = await _repository.currentUser();
      _rememberMe = await _repository.rememberMe();
    } catch (error) {
      _error = AppException.describe(error, fallback: '读取登录状态失败');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String username, String password) {
    return _runAuth(
      () => _repository.login(username, password),
      fallback: '登录失败，请稍后再试',
    );
  }

  Future<bool> register(String username, String password, String nickname) {
    return _runAuth(
      () => _repository.register(username, password, nickname),
      fallback: '注册失败，请稍后再试',
    );
  }

  /// 游客体验：只存在内存里，重启后回到登录页。
  ///
  /// 为什么不走 AuthRepository：游客没有账号/token，后端阶段也不能拿它换 token；
  /// 页面用 hasSession 放行，上传等需要账号的操作再用 isGuest 拦截。
  void continueAsGuest() {
    _user = AppUser.anonymous;
    _error = null;
    notifyListeners();
  }

  Future<void> setRememberMe(bool value) async {
    if (_rememberMe == value) {
      return;
    }
    _rememberMe = value;
    notifyListeners();
    try {
      await _repository.setRememberMe(value);
    } catch (error) {
      _error = AppException.describe(error, fallback: '保存登录偏好失败');
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      await _repository.logout();
      _user = null;
      _error = null;
    } catch (error) {
      _error = AppException.describe(error, fallback: '退出失败，请稍后再试');
    } finally {
      notifyListeners();
    }
  }

  /// 清除本地数据后重置内存登录态；不回写 prefs（prefs 已被清空）。
  void reset() {
    _user = null;
    _error = null;
    _rememberMe = true;
    _loaded = true;
    notifyListeners();
  }

  Future<bool> _runAuth(
    Future<AppUser> Function() action, {
    required String fallback,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _user = await action();
      return true;
    } catch (error) {
      _error = AppException.describe(error, fallback: fallback);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
