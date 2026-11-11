import 'package:sqflite/sqflite.dart';

import '../../core/errors/app_exception.dart';
import '../../models/sleep_tracking_record.dart';
import '../db/app_database.dart';

/// sleep_tracking 表访问层：一晚一条，状态机持久化。
class SleepTrackingDao {
  const SleepTrackingDao(this._database);

  final AppDatabase _database;

  static const String table = 'sleep_tracking';

  Future<Database> get _db => _database.database;

  Future<SleepTrackingRecord?> queryOpen() async {
    final Database db = await _db;
    final List<Map<String, Object?>> rows = await db.query(
      table,
      where: "status IN ('recording', 'pending')",
      orderBy: 'start_at DESC',
      limit: 1,
    );
    return rows.isEmpty ? null : SleepTrackingRecord.fromMap(rows.first);
  }

  Future<SleepTrackingRecord?> queryPending() async {
    final Database db = await _db;
    final List<Map<String, Object?>> rows = await db.query(
      table,
      where: "status = 'pending'",
      orderBy: 'start_at DESC',
      limit: 1,
    );
    return rows.isEmpty ? null : SleepTrackingRecord.fromMap(rows.first);
  }

  Future<SleepTrackingRecord?> queryByNight(String nightKey) async {
    final Database db = await _db;
    final List<Map<String, Object?>> rows = await db.query(
      table,
      where: 'night_key = ?',
      whereArgs: <Object?>[nightKey],
      limit: 1,
    );
    return rows.isEmpty ? null : SleepTrackingRecord.fromMap(rows.first);
  }

  Future<SleepTrackingRecord> save(SleepTrackingRecord record) async {
    final Database db = await _db;
    if (record.id != null) {
      await db.update(
        table,
        record.toMap(),
        where: 'id = ?',
        whereArgs: <Object?>[record.id],
      );
      return record;
    }
    final SleepTrackingRecord? existing = await queryByNight(record.nightKey);
    if (existing != null) {
      final SleepTrackingRecord merged =
          record.copyWith(id: existing.id, createdAt: existing.createdAt);
      await db.update(
        table,
        merged.toMap(),
        where: 'id = ?',
        whereArgs: <Object?>[existing.id],
      );
      return merged;
    }
    final int id = await db.insert(table, record.toMap());
    return record.copyWith(id: id);
  }

  Future<void> delete(int id) async {
    final Database db = await _db;
    final int changed =
        await db.delete(table, where: 'id = ?', whereArgs: <Object?>[id]);
    if (changed == 0) {
      throw const AppException('自动记录不存在');
    }
  }
}
