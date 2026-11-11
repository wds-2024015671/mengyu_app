import 'package:sqflite/sqflite.dart';

import '../../core/errors/app_exception.dart';
import '../../models/private_media.dart';
import '../db/app_database.dart';

class PrivateMediaDao {
  const PrivateMediaDao(this._database);

  final AppDatabase _database;
  static const String table = 'private_media';

  Future<Database> get _db => _database.database;

  Future<int> insert(PrivateMedia media) async {
    final Database db = await _db;
    return db.insert(table, media.toMap());
  }

  Future<void> updateStatus(int id, PrivateMediaStatus status) async {
    final Database db = await _db;
    final int changed = await db.update(
      table,
      <String, Object?>{'status': status.name},
      where: 'id = ?',
      whereArgs: <Object?>[id],
    );
    if (changed == 0) {
      throw const AppException('私人库记录不存在');
    }
  }

  Future<void> delete(int id) async {
    final Database db = await _db;
    await db.delete(table, where: 'id = ?', whereArgs: <Object?>[id]);
  }

  Future<int> deleteMany(Iterable<int> ids) async {
    final List<int> targets = ids.toSet().toList(growable: false);
    if (targets.isEmpty) {
      return 0;
    }
    final Database db = await _db;
    final String placeholders =
        List<String>.filled(targets.length, '?').join(',');
    return db.delete(
      table,
      where: 'id IN ($placeholders)',
      whereArgs: targets,
    );
  }

  Future<List<PrivateMedia>> queryAll() async {
    final Database db = await _db;
    final List<Map<String, Object?>> rows = await db.query(
      table,
      orderBy: 'created_at DESC',
    );
    return rows.map(PrivateMedia.fromMap).toList(growable: false);
  }

  Future<List<PrivateMedia>> queryByType(PrivateMediaType type) async {
    final Database db = await _db;
    final List<Map<String, Object?>> rows = await db.query(
      table,
      where: 'type = ?',
      whereArgs: <Object?>[type.name],
      orderBy: 'created_at DESC',
    );
    return rows.map(PrivateMedia.fromMap).toList(growable: false);
  }

  Future<bool> existsByUrl(String url) async {
    final Database db = await _db;
    final List<Map<String, Object?>> rows = await db.query(
      table,
      columns: <String>['id'],
      where: 'source_url = ? AND status = ?',
      whereArgs: <Object?>[url, PrivateMediaStatus.ready.name],
      limit: 1,
    );
    return rows.isNotEmpty;
  }
}
