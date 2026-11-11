import '../../../models/sleep_session.dart';
import '../../dao/session_dao.dart';
import '../session_repository.dart';

/// 本地睡眠记录实现。
class LocalSessionRepository implements SessionRepository {
  const LocalSessionRepository(this._dao);

  final SessionDao _dao;

  @override
  Future<List<SleepSession>> all() => _dao.queryAll();

  @override
  Future<List<SleepSession>> byDate(DateTime date) => _dao.queryByDate(date);

  @override
  Future<List<SleepSession>> between(DateTime start, DateTime end) =>
      _dao.queryBetween(start, end);

  @override
  Future<List<SleepSession>> recent(int limit) => _dao.queryRecent(limit);

  @override
  Future<SleepSession> save(SleepSession session) async {
    if (session.id == null) {
      final int id = await _dao.insert(session);
      return session.copyWith(id: id);
    }
    await _dao.update(session);
    return session;
  }

  @override
  Future<void> delete(int id) async {
    await _dao.delete(id);
  }
}
