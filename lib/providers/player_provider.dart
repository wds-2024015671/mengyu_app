import 'dart:async';
import 'package:flutter/foundation.dart';
import '../core/audio/audio_engine.dart';
import '../core/audio/play_session_tracker.dart';
import '../core/audio/player_playback.dart';
import '../core/audio/sleep_timer.dart';
import '../data/repositories/session_repository.dart';
import '../data/services/sleep_tracking_service.dart';
import '../models/audio_item.dart';
export '../core/audio/player_playback.dart' show PlayerStatus;
/// 播放器门面：音频状态 + 睡眠定时 + 声音仪式记录。
///
/// 为什么拆成 PlayerPlayback + PlayerProvider：
/// 前者只关心声音状态，后者负责“定时结束要暂停+写记录”这类跨系统协调；
/// 两者都能独立测试，文件也不会超长。
class PlayerProvider extends ChangeNotifier {
  PlayerProvider({
    required AudioEngine Function() engineFactory,
    required SessionRepository sessionRepository,
    SleepTrackingService? trackingService,
    DateTime Function()? clock,
    Duration timerTick = const Duration(seconds: 1),
  })  : _clock = clock ?? DateTime.now,
        _tracking = trackingService {
    _playback = PlayerPlayback(engineFactory: engineFactory)
      ..onPlayStarted = _handlePlayStarted
      ..addListener(_onPlaybackChanged);
    _session = PlaySessionTracker(repository: sessionRepository, clock: _clock);
    _sleepTimer = SleepTimer(
      tick: timerTick,
      onTick: _handleTimerTick,
      onFinished: _handleTimerFinished,
    );
  }
  final DateTime Function() _clock;
  final SleepTrackingService? _tracking;
  late final PlayerPlayback _playback;
  late final PlaySessionTracker _session;
  late final SleepTimer _sleepTimer;
  String? _notice;
  bool _disposed = false;
  AudioItem? get current => _playback.current;
  PlayerStatus get status => _playback.status;
  Duration get position => _playback.position;
  Duration get duration => _playback.duration;
  double get volume => _playback.volume;
  String? get error => _playback.error;
  bool get isPlaying => _playback.isPlaying;
  bool get isLoading => _playback.isLoading;
  Duration? get remaining => _sleepTimer.remaining;
  bool get hasTimer => _sleepTimer.isActive;
  /// 页面监听 Provider 后取一次，避免同一条提示重复弹 SnackBar。
  String? takeNotice() {
    final String? notice = _notice;
    _notice = null;
    return notice;
  }
  Future<void> play(AudioItem item) async {
    if (_playback.current?.id == item.id &&
        _playback.status != PlayerStatus.error) {
      if (_playback.status == PlayerStatus.paused) {
        await resume();
      }
      return;
    }
    await _persistSession();
    _session.reset();
    await _playback.play(item);
  }
  Future<void> pause() async {
    await _playback.pause();
    await _persistSession();
  }
  Future<void> resume() async {
    await _playback.resume();
    // 从“退出播放页”恢复时 tracker 已 reset，需要重新记一次 started_at。
    if (_playback.status == PlayerStatus.playing && !_session.hasStarted) {
      _session.start(_clock());
    }
  }
  Future<void> togglePlay() async {
    if (_playback.status == PlayerStatus.playing) {
      await pause();
      return;
    }
    if (_playback.status == PlayerStatus.paused) {
      await resume();
      return;
    }
    if (_playback.status == PlayerStatus.loading) {
      return;
    }
    final AudioItem? item = _playback.current;
    if (item != null) {
      await play(item);
    }
  }
  Future<void> retry() async {
    final AudioItem? item = _playback.current;
    if (item != null) {
      await play(item);
    }
  }
  Future<void> setVolume(double value) => _playback.setVolume(value);
  Future<void> seek(Duration value) => _playback.seek(value);
  /// 播放页退出：取消定时、暂停、落一次记录，并让下一次播放重新计时。
  Future<void> onPageLeave() async {
    if (_disposed) {
      return;
    }
    _sleepTimer.cancel();
    await _playback.leave();
    await _persistSession();
    await _tracking?.clearExpected();
    _session.reset();
  }
  /// 当前媒体被删除：停止播放、清空当前项并取消定时。
  Future<void> clear() async {
    _sleepTimer.cancel();
    await _playback.clear();
    _session.reset();
    await _tracking?.clearExpected();
    if (!_disposed) {
      notifyListeners();
    }
  }
  void startTimer({required Duration duration}) {
    _sleepTimer.start(duration);
    final AudioItem? item = _playback.current;
    unawaited(
      _tracking?.notePlaybackExpectedEnd(
        expectedEndAt: _clock().add(duration),
        mediaId: item?.id,
      ),
    );
    notifyListeners();
  }
  void cancelTimer() {
    _sleepTimer.cancel();
    notifyListeners();
  }
  void _handlePlayStarted() {
    _session.start(_clock());
    final AudioItem? item = _playback.current;
    if (item != null) {
      final Duration duration = _playback.duration > Duration.zero
          ? _playback.duration
          : Duration(seconds: item.durationSec);
      if (duration > Duration.zero) {
        unawaited(
          _tracking?.notePlaybackExpectedEnd(
            expectedEndAt: _clock().add(duration),
            mediaId: item.id,
          ),
        );
      }
    }
  }
  void _onPlaybackChanged() {
    if (!_disposed) {
      notifyListeners();
    }
  }
  void _handleTimerTick(Duration remaining) {
    if (!_disposed) {
      notifyListeners();
    }
  }
  void _handleTimerFinished() {
    unawaited(_finishTimer());
  }
  Future<void> _finishTimer() async {
    await pause();
    if (_disposed) {
      return;
    }
    final AudioItem? item = _playback.current;
    final SleepTrackingService? tracking = _tracking;
    if (tracking != null) {
      await tracking.startRecording(
        at: _clock(),
        mediaId: item?.id,
      );
    }
    _notice = tracking == null
        ? '定时结束，已停止播放'
        : '定时结束，已停止播放 · 已开始记录睡眠';
    notifyListeners();
  }
  /// 用户手动停止时的确认入口：开始自动睡眠记录。
  Future<bool> startSleepRecording() async {
    final SleepTrackingService? tracking = _tracking;
    if (tracking == null) {
      return false;
    }
    final AudioItem? item = _playback.current;
    final record = await tracking.startRecording(
      at: _clock(),
      mediaId: item?.id,
    );
    if (record == null) {
      return false;
    }
    if (!_disposed) {
      _notice = '已开始记录睡眠，明早提醒你确认';
      notifyListeners();
    }
    return true;
  }
  Future<void> _persistSession() async {
    final AudioItem? item = _playback.current;
    if (item == null) {
      return;
    }
    final PlaySessionPersistResult result = await _session.persist(item);
    if (result == PlaySessionPersistResult.failed && !_disposed) {
      _notice = '睡眠记录保存失败';
      notifyListeners();
    }
  }
  @override
  void dispose() {
    _disposed = true;
    _sleepTimer.dispose();
    _playback.removeListener(_onPlaybackChanged);
    _playback.dispose();
    super.dispose();
  }
}
