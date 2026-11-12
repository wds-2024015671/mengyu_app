import 'package:flutter_test/flutter_test.dart';
import 'package:mengyu_app/models/audio_item.dart';
import 'package:mengyu_app/providers/player_provider.dart';

import 'support/fake_audio_engine.dart';
import 'support/fake_session_repository.dart';

void main() {
  late FakeAudioEngine engine;
  late FakeSessionRepository sessions;
  late PlayerProvider provider;
  late DateTime now;

  setUp(() {
    engine = FakeAudioEngine();
    sessions = FakeSessionRepository();
    now = DateTime(2026, 11, 9, 23);
    provider = PlayerProvider(
      engineFactory: () => engine,
      sessionRepository: sessions,
      clock: () => now,
      timerTick: const Duration(milliseconds: 10),
    );
  });

  tearDown(() {
    provider.dispose();
  });

  test('play 按 sourceType 选 AssetSource / DeviceFileSource', () async {
    await provider.play(rainAsset());
    expect(engine.playedAssets, <String>['audio/rain_loop.wav']);
    expect(provider.status, PlayerStatus.playing);
    expect(provider.isPlaying, isTrue);
    expect(engine.lastVolume, 0.6);

    await provider.play(
      const AudioItem(
        id: 'upload_1',
        title: '我的雨声',
        category: '雨声',
        sourceType: AudioSourceType.file,
        filePath: '/tmp/upload_1.wav',
      ),
    );
    expect(engine.playedFiles, <String>['/tmp/upload_1.wav']);
    expect(provider.status, PlayerStatus.playing);
  });

  test('clear 停止当前播放并取消定时', () async {
    await provider.play(rainAsset());
    provider.startTimer(duration: const Duration(minutes: 10));
    expect(provider.current, isNotNull);
    expect(provider.hasTimer, isTrue);

    await provider.clear();
    expect(provider.current, isNull);
    expect(provider.status, PlayerStatus.idle);
    expect(provider.hasTimer, isFalse);
    expect(engine.paused, isTrue);
  });

  test('remote 音源不发请求，直接进入错误态', () async {    await provider.play(
      const AudioItem(
        id: 'public_1',
        title: '公共雨声',
        category: '雨声',
        sourceType: AudioSourceType.remote,
        fileUrl: 'https://example.com/rain.wav',
      ),
    );
    expect(provider.status, PlayerStatus.error);
    expect(provider.error, contains('暂时无法播放'));
    expect(engine.playedAssets, isEmpty);
  });

  test('暂停满 1 分钟落库，多次暂停用同一条记录 upsert', () async {
    await provider.play(rainAsset());
    now = now.add(const Duration(minutes: 2));
    await provider.pause();

    expect(provider.status, PlayerStatus.paused);
    expect(engine.paused, isTrue);
    expect(sessions.saved.length, 1);
    expect(sessions.saved.single.id, 1);
    expect(sessions.saved.single.durationMin, 2);
    expect(sessions.saved.single.note, contains('雨声'));

    await provider.resume();
    expect(provider.status, PlayerStatus.playing);
    expect(engine.resumed, isTrue);

    now = now.add(const Duration(minutes: 3));
    await provider.pause();
    expect(sessions.saved.length, 1);
    expect(sessions.saved.single.id, 1);
    expect(sessions.saved.single.durationMin, 5);
  });

  test('定时结束：暂停、清空倒计时、提示并记录', () async {
    await provider.play(rainAsset());
    now = now.add(const Duration(minutes: 30));
    provider.startTimer(duration: const Duration(milliseconds: 40));
    expect(provider.hasTimer, isTrue);

    await Future<void>.delayed(const Duration(milliseconds: 200));

    expect(provider.hasTimer, isFalse);
    expect(provider.status, PlayerStatus.paused);
    expect(engine.paused, isTrue);
    expect(provider.takeNotice(), '定时结束，已停止播放');
    expect(sessions.saved.single.durationMin, 30);
  });

  test('加载失败进入 error，重试后恢复播放', () async {
    engine.failPlay = true;
    await provider.play(rainAsset());
    expect(provider.status, PlayerStatus.error);
    expect(provider.error, contains('模拟音频加载失败'));

    engine.failPlay = false;
    await provider.retry();
    expect(provider.status, PlayerStatus.playing);
    expect(engine.playedAssets, <String>['audio/rain_loop.wav']);
  });

  test('音量、进度与 seek', () async {
    await provider.play(rainAsset());
    await provider.setVolume(0.3);
    expect(provider.volume, 0.3);
    expect(engine.lastVolume, 0.3);

    engine.emitDuration(const Duration(seconds: 120));
    await Future<void>.delayed(Duration.zero);
    expect(provider.duration, const Duration(seconds: 120));

    await provider.seek(const Duration(seconds: 30));
    expect(provider.position, const Duration(seconds: 30));
    expect(engine.lastSeek, const Duration(seconds: 30));
  });

  test('同一首重复 play 不重新加载', () async {
    await provider.play(rainAsset());
    await provider.play(rainAsset());
    expect(engine.playedAssets.length, 1);
  });

  test('退出播放页后重新进入同一首，恢复播放会新起一条记录', () async {
    await provider.play(rainAsset());
    now = now.add(const Duration(minutes: 2));
    await provider.onPageLeave();
    expect(sessions.saved.length, 1);

    // 重新进入：Playback 仍是同一首且已暂停 → play 走 resume
    await provider.play(rainAsset());
    expect(provider.status, PlayerStatus.playing);

    now = now.add(const Duration(minutes: 2));
    await provider.pause();
    expect(sessions.saved.length, 2);
    expect(sessions.saved.last.durationMin, 2);
  });

  test('退出播放页：取消定时、暂停并落记录', () async {
    await provider.play(rainAsset());
    now = now.add(const Duration(minutes: 2));
    provider.startTimer(duration: const Duration(minutes: 5));

    await provider.onPageLeave();

    expect(provider.hasTimer, isFalse);
    expect(provider.status, PlayerStatus.paused);
    expect(engine.paused, isTrue);
    expect(sessions.saved.length, 1);
    expect(sessions.saved.single.durationMin, 2);
  });
}
