import 'dart:async';

import 'package:flutter/foundation.dart';

import '../errors/app_exception.dart';
import '../../models/audio_item.dart';
import 'audio_engine.dart';

enum PlayerStatus { idle, loading, playing, paused, error }

/// 音频状态机：唯一引擎、源选择、进度、音量、错误。
///
/// 只管“声音”，不碰定时器与数据库；PlayerProvider 在它之上叠加
/// 睡眠仪式记录与倒计时，两边都能单独测试。
class PlayerPlayback extends ChangeNotifier {
  PlayerPlayback({required AudioEngine Function() engineFactory})
      : _engineFactory = engineFactory;

  final AudioEngine Function() _engineFactory;

  AudioEngine? _engine;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration>? _durationSub;
  StreamSubscription<AudioEngineEvent>? _eventSub;

  AudioItem? _current;
  PlayerStatus _status = PlayerStatus.idle;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  double _volume = 0.6;
  String? _error;
  int _playToken = 0;
  bool _disposed = false;

  /// 播放真正开始后回调；PlayerProvider 用它记录 started_at。
  VoidCallback? onPlayStarted;

  AudioItem? get current => _current;
  PlayerStatus get status => _status;
  Duration get position => _position;
  Duration get duration => _duration;
  double get volume => _volume;
  String? get error => _error;
  bool get isPlaying => _status == PlayerStatus.playing;
  bool get isLoading => _status == PlayerStatus.loading;

  AudioEngine _ensureEngine() {
    final AudioEngine? existing = _engine;
    if (existing != null) {
      return existing;
    }
    final AudioEngine created = _engineFactory();
    _engine = created;
    _positionSub = created.positionStream.listen(_handlePosition);
    _durationSub = created.durationStream.listen(_handleDuration);
    _eventSub = created.eventStream.listen(_handleEvent);
    return created;
  }

  Future<void> play(AudioItem item) async {
    final int token = ++_playToken;
    _current = item;
    _position = Duration.zero;
    _duration = item.durationSec > 0
        ? Duration(seconds: item.durationSec)
        : Duration.zero;
    _status = PlayerStatus.loading;
    _error = null;
    notifyListeners();

    try {
      final AudioEngine engine = _ensureEngine();
      await engine.setVolume(_volume);
      if (item.sourceType == AudioSourceType.asset) {
        final String? path = item.assetPath;
        if (path == null || path.isEmpty) {
          throw const AppException('缺少音频资源路径');
        }
        await engine.playAsset(path);
      } else if (item.sourceType == AudioSourceType.file) {
        final String? path = item.filePath;
        if (path == null || path.isEmpty) {
          throw const AppException('缺少音频文件路径');
        }
        await engine.playFile(path);
      } else {
        throw const AppException('这段声音暂时无法播放');
      }
      if (token != _playToken || _disposed) {
        return;
      }
      _status = PlayerStatus.playing;
      onPlayStarted?.call();
      notifyListeners();
    } catch (error) {
      if (token != _playToken || _disposed) {
        return;
      }
      _status = PlayerStatus.error;
      _error = AppException.describe(
        error,
        fallback: '音频加载失败，请检查文件是否存在',
      );
      notifyListeners();
    }
  }

  Future<void> pause() async {
    if (_status != PlayerStatus.playing) {
      return;
    }
    try {
      await _ensureEngine().pause();
    } catch (error) {
      _error = AppException.describe(error, fallback: '暂停失败，请重试');
    }
    _status = PlayerStatus.paused;
    notifyListeners();
  }

  Future<void> resume() async {
    if (_current == null ||
        _status == PlayerStatus.playing ||
        _status == PlayerStatus.loading) {
      return;
    }
    try {
      await _ensureEngine().resume();
      if (_disposed) {
        return;
      }
      _status = PlayerStatus.playing;
      _error = null;
      notifyListeners();
    } catch (error) {
      _status = PlayerStatus.error;
      _error = AppException.describe(error, fallback: '继续播放失败，请重试');
      notifyListeners();
    }
  }

  /// 页面退出：作废尚未完成的 play，并暂停正在播放/加载的音频。
  Future<void> leave() async {
    _playToken++;
    if (_status != PlayerStatus.playing && _status != PlayerStatus.loading) {
      return;
    }
    try {
      await _ensureEngine().pause();
    } catch (_) {
      // 页面正在销毁，暂停失败不阻塞退出。
    }
    if (_disposed) {
      return;
    }
    _status = PlayerStatus.paused;
    notifyListeners();
  }

  Future<void> setVolume(double value) async {
    final double next = value.clamp(0.0, 1.0).toDouble();
    if ((next - _volume).abs() < 0.001) {
      return;
    }
    _volume = next;
    notifyListeners();
    final AudioEngine? engine = _engine;
    if (engine != null) {
      try {
        await engine.setVolume(next);
      } catch (_) {
        // 音量失败不影响播放。
      }
    }
  }

  Future<void> seek(Duration value) async {
    if (_duration <= Duration.zero) {
      return;
    }
    final Duration target = value < Duration.zero
        ? Duration.zero
        : (value > _duration ? _duration : value);
    _position = target;
    notifyListeners();
    final AudioEngine? engine = _engine;
    if (engine != null) {
      try {
        await engine.seek(target);
      } catch (_) {
        // 拖动失败时下一次 position 事件会纠正。
      }
    }
  }

  void _handlePosition(Duration value) {
    if (_disposed || value == _position) {
      return;
    }
    _position = value;
    notifyListeners();
  }

  void _handleDuration(Duration value) {
    if (_disposed || value <= Duration.zero || value == _duration) {
      return;
    }
    _duration = value;
    notifyListeners();
  }

  void _handleEvent(AudioEngineEvent event) {
    if (_disposed) {
      return;
    }
    switch (event) {
      case AudioEngineEvent.playing:
        break;
      case AudioEngineEvent.paused:
      case AudioEngineEvent.stopped:
        if (_status == PlayerStatus.playing) {
          _status = PlayerStatus.paused;
          notifyListeners();
        }
        break;
      case AudioEngineEvent.completed:
        // ReleaseMode.loop 下每轮都会 complete，不能当作播放结束。
        break;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _positionSub?.cancel();
    _durationSub?.cancel();
    _eventSub?.cancel();
    final AudioEngine? engine = _engine;
    if (engine != null) {
      unawaited(engine.dispose());
    }
    super.dispose();
  }
}
