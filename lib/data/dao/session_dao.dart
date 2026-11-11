import 'package:sqflite/sqflite.dart';

import '../../core/errors/app_exception.dart';
import '../../models/sleep_session.dart';
import '../../utils/formatters.dart';
import '../db/app_database.dart';

/// 睡眠记录表访问层：归属日按 sleep_date 查询，跨零点也不会算错天。
class SessionDao {
  const SessionDao(this._database);

  final AppDatabase _database;

  static const String table = 'sleep_sessions';

  Future<Database> get _db => _database.database;

  Future<int> insert(SleepSession session) async {
    final Database db = await _db;
    final Map<String, Object?> values = session.toMap()
      ..['created_at'] = formatTimestamp(DateTime.now());
    return db.insert(table, values);
  }

  Future<int> update(SleepSession session) async {
    final int? id = session.id;
    if (id == null) {
      throw const AppException('缺少睡眠记录 id，无法更新');
    }
    final Database db = await _db;
    // created_at 只在插入时写，更新不覆盖。
    return db.update(
      table,
      session.toMap(),
      where: 'id = ?',
      whereArgs: <Object?>[id],
    );
  }

  Future<int> delete(int id) async {
    final Database db = await _db;
    return db.delete(table, where: 'id = ?', whereArgs: <Object?>[id]);
  }

  Future<List<SleepSession>> queryAll() async {
    final Database db = await _db;
    final List<Map<String, Object?>> rows = await db.query(
      table,
      orderBy: 'bed_time DESC',
    );
    return rows.map(SleepSession.fromMap).toList(growable: false);
  }

  Future<List<SleepSession>> queryByDate(DateTime date) async {
    final Database db = await _db;
    final List<Map<String, Object?>> rows = await db.query(
      table,
      where: 'sleep_date = ?',
      whereArgs: <Object?>[formatDateKey(date)],
      orderBy: 'bed_time DESC',
    );
    return rows.map(SleepSession.fromMap).toList(growable: false);
  }

  /// 闭区间查询：start / end 当天都包含。
  Future<List<SleepSession>> queryBetween(DateTime start, DateTime end) async {
    final Database db = await _db;
    final List<Map<String, Object?>> rows = await db.query(
      table,
      where: 'sleep_date BETWEEN ? AND ?',
      whereArgs: <Object?>[formatDateKey(start), formatDateKey(end)],
      orderBy: 'bed_time DESC',
    );
    return rows.map(SleepSession.fromMap).toList(growable: false);
  }

  /// 最近 N 条，月迹页“最近记录”用。
  Future<List<SleepSession>> queryRecent(int limit) async {
    final Database db = await _db;
    final List<Map<String, Object?>> rows = await db.query(
      table,
      orderBy: 'bed_time DESC',
      limit: limit < 1 ? 1 : limit,
    );
    return rows.map(SleepSession.fromMap).toList(growable: false);
  }
}
