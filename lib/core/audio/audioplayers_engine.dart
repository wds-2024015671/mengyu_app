import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

import 'audio_engine.dart';

/// audioplayers 的真实实现：全 App 只由 PlayerProvider 创建一个实例。
class AudioplayersEngine implements AudioEngine {
  AudioplayersEngine() {
    _positionSub = _player.onPositionChanged.listen(_position.add);
    _durationSub = _player.onDurationChanged.listen(_duration.add);
    _stateSub = _player.onPlayerStateChanged.listen(_onState);
    _completeSub = _player.onPlayerComplete.listen((_) {
      if (!_disposed) {
        _events.add(AudioEngineEvent.completed);
      }
    });
  }

  final AudioPlayer _player = AudioPlayer();

  final StreamController<Duration> _position =
      StreamController<Duration>.broadcast();
  final StreamController<Duration> _duration =
      StreamController<Duration>.broadcast();
  final StreamController<AudioEngineEvent> _events =
      StreamController<AudioEngineEvent>.broadcast();

  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration>? _durationSub;
  StreamSubscription<PlayerState>? _stateSub;
  StreamSubscription<void>? _completeSub;
  bool _disposed = false;

  @override
  Stream<Duration> get positionStream => _position.stream;

  @override
  Stream<Duration> get durationStream => _duration.stream;

  @override
  Stream<AudioEngineEvent> get eventStream => _events.stream;

  @override
  Future<void> playAsset(String assetPath) async {
    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.play(AssetSource(assetPath));
  }

  @override
  Future<void> playFile(String filePath) async {
    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.play(DeviceFileSource(filePath));
  }

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> resume() => _player.resume();

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> setVolume(double volume) => _player.setVolume(volume);

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  void _onState(PlayerState state) {
    if (_disposed) {
      return;
    }
    switch (state) {
      case PlayerState.playing:
        _events.add(AudioEngineEvent.playing);
        break;
      case PlayerState.paused:
        _events.add(AudioEngineEvent.paused);
        break;
      case PlayerState.stopped:
        _events.add(AudioEngineEvent.stopped);
        break;
      case PlayerState.completed:
        // 循环模式下每次循环都会 complete；交给 onPlayerComplete 统一处理。
        break;
      case PlayerState.disposed:
        break;
    }
  }

  @override
  Future<void> dispose() async {
    _disposed = true;
    await _positionSub?.cancel();
    await _durationSub?.cancel();
    await _stateSub?.cancel();
    await _completeSub?.cancel();
    await _position.close();
    await _duration.close();
    await _events.close();
    await _player.dispose();
  }
}
