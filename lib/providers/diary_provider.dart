import 'package:flutter/foundation.dart';

import '../core/errors/app_exception.dart';
import '../data/repositories/diary_repository.dart';
import '../models/diary_entry.dart';

/// 日记列表状态：loading / error / list；增删改后统一回读并 notify。
class DiaryProvider extends ChangeNotifier {
  DiaryProvider(this._repository);

  final DiaryRepository _repository;

  List<DiaryEntry> _entries = const <DiaryEntry>[];
  bool _isLoading = false;
  String? _error;

  List<DiaryEntry> get entries => List<DiaryEntry>.unmodifiable(_entries);
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasData => _entries.isNotEmpty;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _entries = await _repository.all();
    } catch (error) {
      _error = AppException.describe(error, fallback: '日记加载失败，请稍后再试');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> save(DiaryEntry entry) async {
    return await saveEntry(entry) != null;
  }

  /// 保存并返回带 id 的完整记录：编辑页要把它 pop 回列表，
  /// 所以不能只返回成功布尔值。
  Future<DiaryEntry?> saveEntry(DiaryEntry entry) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final DiaryEntry saved = await _repository.save(entry);
      _entries = await _repository.all();
      return saved;
    } catch (error) {
      _error = AppException.describe(error, fallback: '日记保存失败，请稍后再试');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> delete(int id) {
    return _mutate(
      () => _repository.delete(id),
      fallback: '日记删除失败，请稍后再试',
    );
  }

  /// 清除本地数据后重置内存列表。
  void reset() {
    _entries = const <DiaryEntry>[];
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  /// 写操作成功后重新拉列表：本地库很小，回读比手工维护内存列表更不容易不一致。
  Future<bool> _mutate(
    Future<void> Function() action, {
    required String fallback,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await action();
      _entries = await _repository.all();
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
