import 'package:flutter/foundation.dart';

import '../core/errors/app_exception.dart';
import '../data/repositories/favorite_repository.dart';

/// 收藏状态：本地音景 / 公共库 / 播放器共用一份 id 集合。
///
/// 为什么单独一个 Provider：收藏跨三个页面（声屿、播放器、我的），
/// 塞进 SoundProvider 会让“公共库分页失败”也影响收藏按钮。
class FavoriteProvider extends ChangeNotifier {
  FavoriteProvider(this._repository);

  final FavoriteRepository _repository;

  Set<String> _ids = <String>{};
  bool _isLoading = false;
  bool _loaded = false;
  String? _error;
  Future<void>? _inFlight;

  Set<String> get ids => Set<String>.unmodifiable(_ids);
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get count => _ids.length;

  bool isFavorite(String id) => _ids.contains(id);

  Future<void> ensureLoaded() {
    final Future<void>? current = _inFlight;
    if (current != null) {
      return current;
    }
    if (_loaded) {
      return Future<void>.value();
    }
    _loaded = true;
    final Future<void> future = _load();
    _inFlight = future;
    return future.whenComplete(() {
      _inFlight = null;
    });
  }

  /// 从播放器返回后强制回读，保证外部改动也能同步。
  Future<void> reload() {
    _loaded = true;
    return _load();
  }

  Future<void> _load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _ids = await _repository.load();
    } catch (error) {
      _error = AppException.describe(error, fallback: '收藏读取失败');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 清除本地数据后重置内存收藏；下次进入声屿会重新读取（空）。
  void reset() {
    _ids = <String>{};
    _isLoading = false;
    _loaded = false;
    _error = null;
    _inFlight = null;
    notifyListeners();
  }

  /// 先改内存再落盘：爱心要立刻响应，写失败只记录错误，不回滚用户操作。
  Future<void> toggle(String id) async {    final Set<String> next = <String>{..._ids};
    if (!next.remove(id)) {
      next.add(id);
    }
    _ids = next;
    _error = null;
    notifyListeners();
    try {
      await _repository.save(next);
    } catch (error) {
      _error = AppException.describe(error, fallback: '收藏保存失败');
      notifyListeners();
    }
  }
}
