import 'package:flutter/foundation.dart';

import '../core/errors/app_exception.dart';
import '../data/repositories/upload_repository.dart';
import '../models/audio_item.dart';

/// 我的上传：列表 + 提交状态。
///
/// 为什么把 isSubmitting 和 isLoading 分开：上传时表单要禁用，
/// 但列表不应该整块变成 loading，否则用户看不到已有记录。
class UploadProvider extends ChangeNotifier {
  UploadProvider(this._repository);

  final UploadRepository _repository;

  static const int pageSize = 50;

  List<AudioItem> _uploads = const <AudioItem>[];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _error;

  List<AudioItem> get uploads => List<AudioItem>.unmodifiable(_uploads);
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get error => _error;
  bool get hasData => _uploads.isNotEmpty;

  Future<void> loadMyUploads() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _uploads = await _repository.myUploads(1, pageSize);
    } catch (error) {
      _error = AppException.describe(error, fallback: '上传记录加载失败，请稍后再试');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 清除本地数据后重置内存列表。
  void reset() {
    _uploads = const <AudioItem>[];
    _isLoading = false;
    _isSubmitting = false;
    _error = null;
    notifyListeners();
  }

  /// 提交成功后立刻回读列表，让“我的上传”马上出现审核中记录。
  Future<bool> upload({
    required String filePath,
    required String title,
    required String category,
    String description = '',
  }) async {
    if (_isSubmitting) {
      return false;
    }
    _isSubmitting = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.upload(filePath, title, category, description);
      _uploads = await _repository.myUploads(1, pageSize);
      return true;
    } catch (error) {
      _error = AppException.describe(error, fallback: '上传失败，请稍后再试');
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
