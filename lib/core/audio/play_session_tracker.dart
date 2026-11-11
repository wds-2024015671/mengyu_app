import '../../data/repositories/session_repository.dart';
import '../../models/audio_item.dart';
import '../../models/sleep_session.dart';

enum PlaySessionPersistResult { skipped, saved, failed }

/// 一次连续播放的“声音仪式”记录：
/// 首次播放在 start() 记 startedAt，暂停/离开时满 1 分钟才落库；
/// 同一次播放多次暂停用同一个 id 更新，避免写出一堆碎片记录。
class PlaySessionTracker {
  PlaySessionTracker({required this.repository, required this.clock});

  final SessionRepository repository;
  final DateTime Function() clock;

  DateTime? _startedAt;
  int? _recordId;
  bool _saving = false;

  bool get hasStarted => _startedAt != null;

  void start(DateTime at) {
    _startedAt = at;
    _recordId = null;
  }

  void reset() {
    _startedAt = null;
    _recordId = null;
  }

  Future<PlaySessionPersistResult> persist(AudioItem item) async {
    final DateTime? started = _startedAt;
    if (started == null || _saving) {
      return PlaySessionPersistResult.skipped;
    }
    final DateTime now = clock();
    if (now.difference(started).inMinutes < 1) {
      return PlaySessionPersistResult.skipped;
    }

    _saving = true;
    try {
      final SleepSession saved = await repository.save(
        SleepSession(
          id: _recordId,
          bedTime: started,
          wakeTime: now,
          quality: 3,
          note: '声音仪式：${item.title}',
        ),
      );
      _recordId = saved.id;
      return PlaySessionPersistResult.saved;
    } catch (_) {
      return PlaySessionPersistResult.failed;
    } finally {
      _saving = false;
    }
  }
}
