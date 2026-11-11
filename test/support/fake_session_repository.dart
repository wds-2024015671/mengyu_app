import 'package:mengyu_app/data/repositories/session_repository.dart';
import 'package:mengyu_app/models/audio_item.dart';
import 'package:mengyu_app/models/sleep_session.dart';

/// 内存版睡眠记录仓库：只实现播放器测试需要的方法，同 id 覆盖写。
class FakeSessionRepository implements SessionRepository {
  FakeSessionRepository([List<SleepSession>? initial])
      : saved = initial ?? <SleepSession>[];

  final List<SleepSession> saved;
  int _nextId = 1;

  @override
  Future<SleepSession> save(SleepSession session) async {
    final SleepSession stored =
        session.id == null ? session.copyWith(id: _nextId++) : session;
    final int index =
        saved.indexWhere((SleepSession item) => item.id == stored.id);
    if (index >= 0) {
      saved[index] = stored;
    } else {
      saved.add(stored);
    }
    return stored;
  }

  @override
  Future<List<SleepSession>> all() async => List<SleepSession>.of(saved);

  @override
  Future<List<SleepSession>> byDate(DateTime date) async =>
      List<SleepSession>.of(saved);

  @override
  Future<List<SleepSession>> between(DateTime start, DateTime end) async =>
      List<SleepSession>.of(saved);

  @override
  Future<List<SleepSession>> recent(int limit) async =>
      saved.take(limit).toList(growable: false);

  @override
  Future<void> delete(int id) async {
    saved.removeWhere((SleepSession item) => item.id == id);
  }
}

AudioItem rainAsset() {
  return const AudioItem.builtIn(
    id: 'local_rain',
    title: '雨声',
    category: '雨声',
    assetPath: 'audio/rain_loop.wav',
  );
}
