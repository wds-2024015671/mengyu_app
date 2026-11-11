import 'package:flutter/foundation.dart';

import '../core/errors/app_exception.dart';
import '../data/services/sleep_tracking_service.dart';
import '../models/sleep_tracking_record.dart';

/// 全局自动记录状态：待确认记录、通知点击、权限状态。
class SleepTrackingProvider extends ChangeNotifier {
  SleepTrackingProvider(this._service);

  final SleepTrackingService _service;

  SleepTrackingRecord? _pending;
  bool _loading = false;
  bool _ready = false;
  bool _permission = false;
  bool _tapPending = false;
  String? _error;

  SleepTrackingRecord? get pending => _pending;
  bool get isLoading => _loading;
  bool get isReady => _ready;
  bool get hasPermission => _permission;
  bool get tapPending => _tapPending;
  String? get error => _error;

  bool get needsPrompt =>
      _pending != null && _service.needsPrompt(_pending!);

  Future<void> initialize() async {
    if (_ready) {
      return;
    }
    _ready = true;
    try {
      await _service.initialize();
      _service.setOnNotificationTap(() {
        _tapPending = true;
        notifyListeners();
      });
      _tapPending = _service.takeNotificationTap();
      _permission = await _service.hasNotificationPermission();
    } catch (_) {
      // 通知不可用时仍保留 3A 生命周期确认。
    }
    await checkOnResume();
  }

  Future<void> checkOnResume() async {
    _loading = true;
    notifyListeners();
    try {
      _pending = await _service.checkOnResume();
      _error = null;
    } catch (error) {
      _error = AppException.describe(error, fallback: '自动记录恢复失败');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    try {
      _pending = await _service.open();
    } catch (error) {
      _error = AppException.describe(error, fallback: '自动记录读取失败');
    }
    notifyListeners();
  }

  Future<void> markPrompted() async {
    final SleepTrackingRecord? record = _pending;
    if (record == null) {
      return;
    }
    await _service.markPrompted(record);
    await refresh();
  }

  Future<void> rescheduleReminder() async {
    try {
      await _service.rescheduleReminder();
    } catch (_) {
      // 通知不可用不阻塞设置保存。
    }
  }

  Future<bool> confirm({DateTime? endAt}) async {
    final SleepTrackingRecord? record = _pending;
    if (record == null) {
      return false;
    }
    _loading = true;
    notifyListeners();
    try {
      await _service.confirm(record, endAt: endAt);
      _pending = null;
      _error = null;
      return true;
    } catch (error) {
      _error = AppException.describe(error, fallback: '确认睡眠记录失败');
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> discard() async {
    final SleepTrackingRecord? record = _pending;
    if (record == null) {
      return;
    }
    await _service.discard(record);
    _pending = null;
    notifyListeners();
  }

  Future<void> startRecording({DateTime? at}) async {
    try {
      _pending = await _service.startRecording(at: at);
      notifyListeners();
    } catch (error) {
      _error = AppException.describe(error, fallback: '开始记录睡眠失败');
      notifyListeners();
    }
  }

  Future<bool> requestNotificationPermission() async {
    try {
      _permission = await _service.requestNotificationPermission();
    } catch (_) {
      _permission = false;
    }
    notifyListeners();
    return _permission;
  }

  void clearTap() {
    _tapPending = false;
    notifyListeners();
  }

  /// 清除本地数据后重置内存状态；下次进入首页重新查库。
  void reset() {
    _pending = null;
    _error = null;
    _tapPending = false;
    _permission = false;
    _ready = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _service.setOnNotificationTap(null);
    super.dispose();
  }
}
