import 'dart:async';

/// 每秒递减的睡眠定时器：只负责计时，暂停播放/写库由 PlayerProvider 处理。
///
/// 为什么单独抽出来：倒计时逻辑可以脱离音频与数据库单测，
/// 也让 PlayerProvider 不必同时管理 Timer、音频和记录三件事。
class SleepTimer {
  SleepTimer({
    required this.tick,
    required this.onTick,
    required this.onFinished,
  });

  final Duration tick;
  final void Function(Duration remaining) onTick;
  final void Function() onFinished;

  Timer? _timer;
  Duration? _remaining;

  Duration? get remaining => _remaining;
  bool get isActive => _remaining != null;

  void start(Duration duration) {
    cancel();
    if (duration <= Duration.zero) {
      return;
    }
    _remaining = duration;
    _timer = Timer.periodic(tick, (Timer _) {
      final Duration? current = _remaining;
      if (current == null) {
        return;
      }
      final Duration next = current - tick;
      if (next <= Duration.zero) {
        _timer?.cancel();
        _timer = null;
        _remaining = null;
        onFinished();
        return;
      }
      _remaining = next;
      onTick(next);
    });
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
    _remaining = null;
  }

  void dispose() {
    cancel();
  }
}
