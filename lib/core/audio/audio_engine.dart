/// 播放器最小能力接口：PlayerProvider 只依赖它，测试可注入假实现。
///
/// 为什么不让 Provider 直接持有 AudioPlayer：audioplayers 在构造时会走平台通道，
/// VM 单测跑不起来；抽一层接口后，播放/暂停/定时的状态机可以完整单测。
enum AudioEngineEvent { playing, paused, stopped, completed }

abstract class AudioEngine {
  Stream<Duration> get positionStream;

  Stream<Duration> get durationStream;

  Stream<AudioEngineEvent> get eventStream;

  Future<void> playAsset(String assetPath);

  Future<void> playFile(String filePath);

  Future<void> pause();

  Future<void> resume();

  Future<void> stop();

  Future<void> setVolume(double volume);

  Future<void> seek(Duration position);

  Future<void> dispose();
}
