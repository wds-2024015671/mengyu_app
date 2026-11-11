import 'dart:async';

import 'package:mengyu_app/core/audio/audio_engine.dart';
import 'package:mengyu_app/core/errors/app_exception.dart';

/// 测试用音频引擎：不碰平台通道，记录调用并允许手动推事件。
class FakeAudioEngine implements AudioEngine {
  final StreamController<Duration> _position =
      StreamController<Duration>.broadcast();
  final StreamController<Duration> _duration =
      StreamController<Duration>.broadcast();
  final StreamController<AudioEngineEvent> _events =
      StreamController<AudioEngineEvent>.broadcast();

  final List<String> playedAssets = <String>[];
  final List<String> playedFiles = <String>[];

  bool paused = false;
  bool resumed = false;
  bool stopped = false;
  bool disposed = false;
  bool failPlay = false;
  double? lastVolume;
  Duration? lastSeek;

  @override
  Stream<Duration> get positionStream => _position.stream;

  @override
  Stream<Duration> get durationStream => _duration.stream;

  @override
  Stream<AudioEngineEvent> get eventStream => _events.stream;

  @override
  Future<void> playAsset(String assetPath) async {
    if (failPlay) {
      throw const AppException('模拟音频加载失败');
    }
    playedAssets.add(assetPath);
    _events.add(AudioEngineEvent.playing);
  }

  @override
  Future<void> playFile(String filePath) async {
    if (failPlay) {
      throw const AppException('模拟音频加载失败');
    }
    playedFiles.add(filePath);
    _events.add(AudioEngineEvent.playing);
  }

  @override
  Future<void> pause() async {
    paused = true;
    _events.add(AudioEngineEvent.paused);
  }

  @override
  Future<void> resume() async {
    resumed = true;
    _events.add(AudioEngineEvent.playing);
  }

  @override
  Future<void> stop() async {
    stopped = true;
    _events.add(AudioEngineEvent.stopped);
  }

  @override
  Future<void> setVolume(double volume) async {
    lastVolume = volume;
  }

  @override
  Future<void> seek(Duration position) async {
    lastSeek = position;
  }

  void emitPosition(Duration value) => _position.add(value);

  void emitDuration(Duration value) => _duration.add(value);

  @override
  Future<void> dispose() async {
    disposed = true;
    await _position.close();
    await _duration.close();
    await _events.close();
  }
}
