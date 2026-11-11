import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// 本地 SQLite 单例。
///
/// 为什么把建表逻辑收在一个文件：DAO 只写查询，升级脚本只在这里改，
/// 页面和 Provider 永远看不到 sqflite。
class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  /// v1：日记 + 睡眠记录；v2：下载/上传与索引；v3：自动记录状态机；
  /// v4：私人库媒体表。
  static const int version = 4;
  static const String fileName = 'mengyu.db';

  Database? _database;
  Future<Database>? _opening;

  Future<Database> get database async {
    final Database? opened = _database;
    if (opened != null) {
      return opened;
    }
    _opening ??= _open();
    final Database db = await _opening!;
    _database = db;
    return db;
  }

  Future<Database> _open() async {
    final String path = p.join(await getDatabasesPath(), fileName);
    return openDatabase(
      path,
      version: version,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> close() async {
    _opening = null;
    final Database? db = _database;
    _database = null;
    await db?.close();
  }

  /// F12「清除数据」用：关闭连接并删除整库文件，下次访问会重新 onCreate。
  Future<void> deleteDatabaseFile() async {
    await close();
    final String path = p.join(await getDatabasesPath(), fileName);
    await deleteDatabase(path);
  }

  static Future<void> _onConfigure(Database db) async {
    // 当前没有外键；先打开开关，之后加关联表不用再改配置。
    await db.execute('PRAGMA foreign_keys = ON');
  }

  static Future<void> _onCreate(Database db, int version) async {
    // 全新安装直接按当前版本建：逐版本建表，升级路径与 onCreate 共用。
    await _createV1(db);
    await _createV2(db);
    await _createV3(db);
    await _createV4(db);
  }

  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await _createV2(db);
    }
    if (oldVersion < 3) {
      await _createV3(db);
    }
    if (oldVersion < 4) {
      await _createV4(db);
    }
  }

  /// v1 表结构：日记、睡眠记录。
  static Future<void> _createV1(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS diary_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        entry_date TEXT NOT NULL,
        mood INTEGER NOT NULL,
        content TEXT NOT NULL,
        tags TEXT NOT NULL DEFAULT '[]',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS sleep_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        bed_time TEXT NOT NULL,
        wake_time TEXT NOT NULL,
        duration_min INTEGER NOT NULL,
        quality INTEGER NOT NULL,
        note TEXT NOT NULL DEFAULT '',
        sleep_date TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
  }

  /// v2 新增：下载记录、我的上传，以及四表索引。
  ///
  /// my_uploads 比宪法多出 description / file_size 两列：
  /// 上传表单需要简介，列表需要显示文件大小，属于功能必需字段。
  static Future<void> _createV2(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS downloads (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        server_id TEXT NOT NULL,
        title TEXT NOT NULL,
        category TEXT NOT NULL,
        file_path TEXT NOT NULL,
        file_size INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS my_uploads (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        category TEXT NOT NULL,
        description TEXT NOT NULL DEFAULT '',
        file_path TEXT NOT NULL,
        file_size INTEGER NOT NULL DEFAULT 0,
        status INTEGER NOT NULL DEFAULT 0,
        reject_reason TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_diary_entry_date '
      'ON diary_entries(entry_date DESC)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_diary_updated_at '
      'ON diary_entries(updated_at DESC)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_sleep_date '
      'ON sleep_sessions(sleep_date DESC)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_sleep_bed_time '
      'ON sleep_sessions(bed_time DESC)',
    );
    await db.execute(
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_downloads_server_id '
      'ON downloads(server_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_uploads_created_at '
      'ON my_uploads(created_at DESC)',
    );
  }

  /// v3：睡眠记录补 source/night_key；新增自动记录状态机表。
  static Future<void> _createV3(Database db) async {
    await db.execute(
      "ALTER TABLE sleep_sessions ADD COLUMN source TEXT NOT NULL "
      "DEFAULT 'manual'",
    );
    await db.execute(
      "ALTER TABLE sleep_sessions ADD COLUMN night_key TEXT NOT NULL "
      "DEFAULT ''",
    );
    await db.execute('''
      UPDATE sleep_sessions
      SET night_key = CASE
        WHEN CAST(substr(bed_time, 12, 2) AS INTEGER) >= 18
          THEN substr(bed_time, 1, 10)
        ELSE date(substr(bed_time, 1, 10), '-1 day')
      END
      WHERE night_key = ''
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_sleep_night '
      'ON sleep_sessions(night_key)',
    );

    await db.execute('''
      CREATE TABLE IF NOT EXISTS sleep_tracking (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        night_key TEXT NOT NULL,
        start_at TEXT NOT NULL,
        expected_end_at TEXT,
        end_at TEXT,
        status TEXT NOT NULL DEFAULT 'recording',
        media_id TEXT,
        prompt_date TEXT,
        created_at TEXT NOT NULL,
        confirmed_at TEXT,
        session_id INTEGER
      )
    ''');
    await db.execute(
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_tracking_night '
      'ON sleep_tracking(night_key)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_tracking_status '
      'ON sleep_tracking(status, start_at DESC)',
    );
  }

  /// v4：声屿私人库；只存本地已下载媒体。
  static Future<void> _createV4(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS private_media (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        title TEXT NOT NULL,
        source_url TEXT NOT NULL,
        local_path TEXT NOT NULL,
        duration_ms INTEGER NOT NULL DEFAULT 0,
        platform TEXT NOT NULL DEFAULT '本地',
        file_size INTEGER NOT NULL DEFAULT 0,
        status TEXT NOT NULL DEFAULT 'downloading',
        created_at TEXT NOT NULL,
        thumb_url TEXT,
        thumb_path TEXT
      )
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_private_media_type '
      'ON private_media(type)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_private_media_created '
      'ON private_media(created_at DESC)',
    );
  }
}
