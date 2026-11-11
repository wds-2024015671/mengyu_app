import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/errors/app_exception.dart';
import '../data/services/avatar_service.dart';

/// 头像状态：路径、加载中、错误；不持有 File，页面按路径校验文件。
class AvatarProvider extends ChangeNotifier {
  AvatarProvider(this._service);

  final AvatarService _service;

  String? _path;
  bool _loading = false;
  bool _loaded = false;
  String? _error;
  bool _disposed = false;

  String? get path => _path;
  bool get isLoading => _loading;
  bool get hasAvatar => _path != null;
  String? get error => _error;

  Future<void> ensureLoaded() async {
    if (_loaded || _loading) {
      return;
    }
    _loaded = true;
    _loading = true;
    notifyListeners();
    try {
      _path = await _service.loadPath();
      _error = null;
    } catch (error) {
      _error = AppException.describe(error, fallback: '读取头像失败');
    } finally {
      _loading = false;
      notifyListeners();
    }
    // Android 相机/相册被系统回收后，恢复结果可能比首帧慢；不阻塞页面。
    unawaited(_recoverLost());
  }

  Future<void> _recoverLost() async {
    try {
      final String? lost = await _service.recoverLost();
      if (!_disposed && lost != null && lost != _path) {
        _path = lost;
        notifyListeners();
      }
    } catch (_) {
      // 恢复失败不影响已保存头像。
    }
  }

  Future<bool> pick(AvatarSource source) async {
    if (_loading) {
      return false;
    }
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final String? picked = await _service.pick(source);
      if (picked == null) {
        return false;
      }
      _path = picked;
      return true;
    } catch (error) {
      _error = AppException.describe(error, fallback: '头像处理失败，请换一张照片');
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> remove() async {
    final String? previous = _path;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _service.remove(previous);
      _path = null;
    } catch (error) {
      _error = AppException.describe(error, fallback: '移除头像失败');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
