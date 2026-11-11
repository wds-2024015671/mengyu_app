import 'package:flutter/foundation.dart';

import '../core/errors/app_exception.dart';
import '../data/repositories/private_media_repository.dart';
import '../data/services/private_media_files.dart';
import '../models/private_media.dart';

/// 私人库状态：导入成功后立即 notify，列表与声屿/视频区同步。
class PrivateMediaProvider extends ChangeNotifier {
  PrivateMediaProvider(this._repository);

  final PrivateMediaRepository _repository;

  List<PrivateMedia> _media = const <PrivateMedia>[];
  bool _loading = false;
  bool _loaded = false;
  String? _error;

  List<PrivateMedia> get media => List<PrivateMedia>.unmodifiable(_media);
  List<PrivateMedia> get ready =>
      _media.where((PrivateMedia item) => item.isReady).toList(growable: false);
  List<PrivateMedia> get audios => ready
      .where((PrivateMedia item) => item.type == PrivateMediaType.audio)
      .toList(growable: false);
  List<PrivateMedia> get videos => ready
      .where((PrivateMedia item) => item.type == PrivateMediaType.video)
      .toList(growable: false);
  bool get isLoading => _loading;
  String? get error => _error;

  Future<void> ensureLoaded() async {
    if (_loaded || _loading) {
      return;
    }
    await load();
  }

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _media = List<PrivateMedia>.of(await _repository.all());
      _loaded = true;
    } catch (error) {
      _error = AppException.describe(error, fallback: '私人库加载失败');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> existsByUrl(String url) async {
    try {
      return await _repository.existsByUrl(url);
    } catch (_) {
      return false;
    }
  }

  Future<bool> importMedia(PrivateMedia media) async {
    _error = null;
    notifyListeners();
    try {
      final PrivateMedia saved = await _repository.save(media);
      _media = <PrivateMedia>[saved, ..._media];
      _loaded = true;
      notifyListeners();
      return true;
    } catch (error) {
      _error = AppException.describe(error, fallback: '私人库写入失败');
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteMedia(int id) async {
    return await deleteByIds(<int>{id}) > 0;
  }

  Future<int> deleteByIds(Iterable<int> ids) async {
    final Set<int> targets = ids.toSet();
    if (targets.isEmpty) {
      return 0;
    }
    final List<PrivateMedia> removing = _media
        .where((PrivateMedia item) => targets.contains(item.id))
        .toList(growable: false);
    try {
      final int deleted = await _repository.deleteMany(targets);
      _media = _media
          .where((PrivateMedia item) => !targets.contains(item.id))
          .toList(growable: false);
      notifyListeners();
      for (final PrivateMedia item in removing) {
        try {
          await deletePrivateMediaFile(item.localPath);
        } catch (_) {
          // DB 已删除；单个文件清理失败不把记录恢复回来。
        }
      }
      return deleted;
    } catch (error) {
      _error = AppException.describe(error, fallback: '私人库删除失败');
      notifyListeners();
      return -1;
    }
  }

  void reset() {
    _media = const <PrivateMedia>[];
    _loaded = false;
    _error = null;
    notifyListeners();
  }
}
