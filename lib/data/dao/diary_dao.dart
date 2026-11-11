import 'package:sqflite/sqflite.dart';

import '../../core/errors/app_exception.dart';
import '../../models/diary_entry.dart';
import '../../utils/formatters.dart';
import '../db/app_database.dart';

/// 日记表访问层：所有 SQL 只出现在 DAO，Provider 与页面拿到的是模型。
class DiaryDao {
  const DiaryDao(this._database);

  final AppDatabase _database;

  static const String table = 'diary_entries';

  Future<Database> get _db => _database.database;

  Future<int> insert(DiaryEntry entry) async {
    final Database db = await _db;
    return db.insert(table, entry.toMap());
  }

  Future<int> update(DiaryEntry entry) async {
    final int? id = entry.id;
    if (id == null) {
      throw const AppException('缺少日记 id，无法更新');
    }
    final Database db = await _db;
    // updated_at 由数据层盖章，避免调用方忘记更新。
    final Map<String, Object?> values = entry.toMap()
      ..['updated_at'] = formatTimestamp(DateTime.now());
    return db.update(table, values, where: 'id = ?', whereArgs: <Object?>[id]);
  }

  Future<int> delete(int id) async {
    final Database db = await _db;
    return db.delete(table, where: 'id = ?', whereArgs: <Object?>[id]);
  }

  Future<List<DiaryEntry>> queryAll() async {
    final Database db = await _db;
    final List<Map<String, Object?>> rows = await db.query(
      table,
      orderBy: 'entry_date DESC, created_at DESC',
    );
    return rows.map(DiaryEntry.fromMap).toList(growable: false);
  }

  Future<List<DiaryEntry>> queryByDate(DateTime date) async {
    final Database db = await _db;
    final List<Map<String, Object?>> rows = await db.query(
      table,
      where: 'entry_date = ?',
      whereArgs: <Object?>[formatDateKey(date)],
      orderBy: 'created_at DESC',
    );
    return rows.map(DiaryEntry.fromMap).toList(growable: false);
  }

  /// 闭区间查询：start / end 当天都包含。
  Future<List<DiaryEntry>> queryBetween(DateTime start, DateTime end) async {
    final Database db = await _db;
    final List<Map<String, Object?>> rows = await db.query(
      table,
      where: 'entry_date BETWEEN ? AND ?',
      whereArgs: <Object?>[formatDateKey(start), formatDateKey(end)],
      orderBy: 'entry_date DESC, created_at DESC',
    );
    return rows.map(DiaryEntry.fromMap).toList(growable: false);
  }
}
