import 'package:flutter/foundation.dart';

import '../core/errors/app_exception.dart';
import '../data/repositories/session_repository.dart';
import '../models/sleep_session.dart';
import '../utils/sleep_stats.dart';

/// 睡眠记录状态：列表 + 本周统计。
///
/// 统计是纯函数（utils/sleep_stats.dart）算出来的，Provider 只负责取数和通知，
/// 这样“连续天数/平均时长”可以脱离 Flutter 单测。
class SleepProvider extends ChangeNotifier {
  SleepProvider(this._repository, {DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;

  final SessionRepository _repository;
  final DateTime Function() _clock;

  List<SleepSession> _sessions = const <SleepSession>[];
  bool _isLoading = false;
  bool _hasLoaded = false;
  String? _error;

  List<SleepSession> get sessions => List<SleepSession>.unmodifiable(_sessions);
  bool get isLoading => _isLoading;
  bool get hasLoaded => _hasLoaded;
  String? get error => _error;
  bool get hasData => _sessions.isNotEmpty;

  /// 当前时钟的今天；月迹的 30 格月相与本周范围都从这里取，
  /// 测试可以注入固定日期，不依赖系统时间。
  DateTime get today => _clock();

  /// 首次进入时加载；已有数据/正在加载则不重复请求。
  Future<void> ensureLoaded() async {
    if (_hasLoaded || _isLoading) {
      return;
    }
    await load();
  }

  /// 本周（周一到周日）7 天、平均时长、连续天数、记录条数。
  SleepWeekStats get weekStats => buildSleepWeek(_sessions, today: _clock());

  /// 最近 3 条，月迹页用；按入睡时间倒序，不依赖仓库返回顺序。
  List<SleepSession> get recent {
    final List<SleepSession> sorted = List<SleepSession>.of(_sessions)
      ..sort((SleepSession a, SleepSession b) =>
          b.bedTime.compareTo(a.bedTime));
    return sorted.take(3).toList(growable: false);
  }

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _sessions = await _repository.all();
    } catch (error) {
      _error = AppException.describe(error, fallback: '睡眠记录加载失败，请稍后再试');
    } finally {
      _isLoading = false;
      _hasLoaded = true;
      notifyListeners();
    }
  }

  Future<bool> save(SleepSession session) {
    return _mutate(
      () async {
        await _repository.save(session);
      },
      fallback: '睡眠记录保存失败，请稍后再试',
    );
  }

  Future<bool> delete(int id) {
    return _mutate(
      () => _repository.delete(id),
      fallback: '睡眠记录删除失败，请稍后再试',
    );
  }

  /// 清除本地数据后重置内存列表；下次进入月迹会重新加载。
  void reset() {
    _sessions = const <SleepSession>[];
    _isLoading = false;
    _hasLoaded = false;
    _error = null;
    notifyListeners();
  }

  Future<bool> _mutate(
    Future<void> Function() action, {
    required String fallback,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await action();
      _sessions = await _repository.all();
      return true;
    } catch (error) {
      _error = AppException.describe(error, fallback: fallback);
      return false;
    } finally {
      _isLoading = false;
      _hasLoaded = true;
      notifyListeners();
    }
  }
}
