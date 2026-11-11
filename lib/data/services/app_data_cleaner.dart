import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../db/app_database.dart';

/// 清除本地数据：删除 SQLite 文件 + 清空所有 prefs。
///
/// 页面不直接碰 sqflite / shared_preferences；测试可注入假实现，
/// 避免 VM 单测被平台通道卡住。
abstract class AppDataCleaner {
  Future<void> clear();
}

class LocalAppDataCleaner implements AppDataCleaner {
  const LocalAppDataCleaner();

  @override
  Future<void> clear() async {
    await AppDatabase.instance.deleteDatabaseFile();
    try {
      final Directory docs = await getApplicationDocumentsDirectory();
      final Directory avatars = Directory('${docs.path}/avatars');
      if (avatars.existsSync()) {
        await avatars.delete(recursive: true);
      }
    } catch (_) {
      // 文件系统不可用时仍要继续清 prefs，避免整个清除流程失败。
    }
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
