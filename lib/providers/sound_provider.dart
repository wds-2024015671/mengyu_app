import 'package:flutter/foundation.dart';

import '../core/errors/app_exception.dart';
import '../data/repositories/sound_repository.dart';
import '../models/audio_item.dart';

/// 声屿状态：本地 6 段 + 公共库分页。
///
/// 两套 loading/error 分开：公共库失败不应该把本地音景一起变成错误态。
class SoundProvider extends ChangeNotifier {
  SoundProvider(this._repository);

  final SoundRepository _repository;

  static const int pageSize = 20;

  List<AudioItem> _localAudios = const <AudioItem>[];
  List<AudioItem> _publicAudios = const <AudioItem>[];
  bool _isLoadingLocal = false;
  bool _isLoadingPublic = false;
  String? _errorLocal;
  String? _errorPublic;
  String _keyword = '';
  String _category = '';
  int _loadedPage = 0;
  bool _hasMorePublic = true;

  List<AudioItem> get localAudios => List<AudioItem>.unmodifiable(_localAudios);
  List<AudioItem> get publicAudios =>
      List<AudioItem>.unmodifiable(_publicAudios);
  bool get isLoadingLocal => _isLoadingLocal;
  bool get isLoadingPublic => _isLoadingPublic;
  String? get errorLocal => _errorLocal;
  String? get errorPublic => _errorPublic;
  bool get hasMorePublic => _hasMorePublic;
  String get keyword => _keyword;
  String get category => _category;

  Future<void> loadLocal() async {
    _isLoadingLocal = true;
    _errorLocal = null;
    notifyListeners();
    try {
      _localAudios = await _repository.localAudios();
    } catch (error) {
      _errorLocal = AppException.describe(error, fallback: '本地音景加载失败');
    } finally {
      _isLoadingLocal = false;
      notifyListeners();
    }
  }

  /// 重新拉第一页；分页是否还有下一页由「本页条数 == pageSize」判断。
  Future<void> loadPublic({bool refresh = true}) async {
    if (_isLoadingPublic) {
      return;
    }
    if (!refresh && !_hasMorePublic) {
      return;
    }
    _isLoadingPublic = true;
    _errorPublic = null;
    notifyListeners();
    try {
      final int nextPage = refresh ? 1 : _loadedPage + 1;
      final List<AudioItem> items = await _repository.publicAudios(
        nextPage,
        pageSize,
        _keyword,
        _category,
      );
      _publicAudios = refresh
          ? items
          : <AudioItem>[..._publicAudios, ...items];
      _loadedPage = nextPage;
      _hasMorePublic = items.length == pageSize;
    } catch (error) {
      _errorPublic = AppException.describe(error, fallback: '公共库加载失败，请稍后再试');
    } finally {
      _isLoadingPublic = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() => loadPublic(refresh: false);

  /// 修改筛选条件并刷新；条件没变时不重复请求。
  Future<void> search({String? keyword, String? category}) async {
    bool changed = false;
    if (keyword != null && keyword != _keyword) {
      _keyword = keyword;
      changed = true;
    }
    if (category != null && category != _category) {
      _category = category;
      changed = true;
    }
    if (!changed) {
      return;
    }
    await loadPublic();
  }
}
