import '../../../models/diary_entry.dart';
import '../../dao/diary_dao.dart';
import '../diary_repository.dart';

/// 本地日记实现：只做“DAO 调用 + 判断新增/更新”，不掺业务规则。
class LocalDiaryRepository implements DiaryRepository {
  const LocalDiaryRepository(this._dao);

  final DiaryDao _dao;

  @override
  Future<List<DiaryEntry>> all() => _dao.queryAll();

  @override
  Future<List<DiaryEntry>> byDate(DateTime date) => _dao.queryByDate(date);

  @override
  Future<List<DiaryEntry>> between(DateTime start, DateTime end) =>
      _dao.queryBetween(start, end);

  @override
  Future<DiaryEntry> save(DiaryEntry entry) async {
    if (entry.id == null) {
      final int id = await _dao.insert(entry);
      return entry.copyWith(id: id);
    }
    await _dao.update(entry);
    return entry;
  }

  @override
  Future<void> delete(int id) async {
    await _dao.delete(id);
  }
}
