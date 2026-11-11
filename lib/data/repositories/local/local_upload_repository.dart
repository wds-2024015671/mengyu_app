import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../../../core/constants/app_limits.dart';
import '../../../core/errors/app_exception.dart';
import '../../../models/audio_item.dart';
import '../../../utils/formatters.dart';
import '../../db/app_database.dart';
import '../upload_repository.dart';

/// 本地上传实现：复制文件到应用目录 + 写 my_uploads（status=0 审核中）。
///
/// 为什么必须复制而不是只存原路径：file_picker 给的临时路径可能被系统清理，
/// 复制到 Documents/uploads 后，记录与文件才长期对应。
class LocalUploadRepository implements UploadRepository {
  const LocalUploadRepository(this._database);

  final AppDatabase _database;

  /// 兼容旧引用；页面与仓库共用 core/constants 里的同一个上限。
  static const int maxFileSize = kMaxAudioUploadBytes;
  static const String _table = 'my_uploads';

  @override
  Future<AudioItem> upload(
    String filePath,
    String title,
    String category,
    String description,
  ) async {
    final String safeTitle = title.trim();
    final String safeCategory = category.trim();
    if (safeTitle.isEmpty) {
      throw const AppException('请填写标题');
    }
    if (safeCategory.isEmpty) {
      throw const AppException('请选择分类');
    }

    final File source = File(filePath);
    if (!await source.exists()) {
      throw const AppException('找不到要上传的文件');
    }
    final int size = await source.length();
    if (size > kMaxAudioUploadBytes) {
      const int maxMb = kMaxAudioUploadBytes ~/ (1024 * 1024);
      throw const AppException('音频文件不能超过 ${maxMb}MB');
    }

    final Directory docs = await getApplicationDocumentsDirectory();
    final Directory uploadDir = Directory(p.join(docs.path, 'uploads'));
    if (!await uploadDir.exists()) {
      await uploadDir.create(recursive: true);
    }
    // 微秒时间戳 + 原文件名，避免同名覆盖；basename 也挡住了路径穿越。
    final String targetPath = p.join(
      uploadDir.path,
      '${DateTime.now().microsecondsSinceEpoch}_${p.basename(filePath)}',
    );
    final File target = File(targetPath);

    try {
      await source.copy(targetPath);
      final Database db = await _database.database;
      final int id = await db.insert(_table, <String, Object?>{
        'title': safeTitle,
        'category': safeCategory,
        'description': description.trim(),
        'file_path': targetPath,
        'file_size': size,
        'status': AudioItem.statusPending,
        'reject_reason': null,
        'created_at': formatTimestamp(DateTime.now()),
      });
      return AudioItem(
        id: 'upload_$id',
        title: safeTitle,
        category: safeCategory,
        description: description.trim(),
        sourceType: AudioSourceType.file,
        filePath: targetPath,
        fileSize: size,
        status: AudioItem.statusPending,
      );
    } catch (error) {
      // 写库失败就把刚复制的文件删掉，避免留下无记录的孤儿文件。
      if (await target.exists()) {
        await target.delete();
      }
      if (error is AppException) {
        rethrow;
      }
      if (error is FileSystemException) {
        throw AppException('文件复制失败，请检查存储空间后重试', error);
      }
      throw AppException('上传失败，请稍后再试', error);
    }
  }

  @override
  Future<List<AudioItem>> myUploads(int page, int size) async {
    final int safePage = page < 1 ? 1 : page;
    final int safeSize = size < 1 ? 20 : size;
    final Database db = await _database.database;
    final List<Map<String, Object?>> rows = await db.query(
      _table,
      orderBy: 'created_at DESC, id DESC',
      limit: safeSize,
      offset: (safePage - 1) * safeSize,
    );
    return rows.map(_toItem).toList(growable: false);
  }

  AudioItem _toItem(Map<String, Object?> row) {
    final int rawStatus =
        (row['status'] as num?)?.toInt() ?? AudioItem.statusPending;
    return AudioItem(
      id: 'upload_${(row['id'] as num?)?.toInt() ?? 0}',
      title: row['title']?.toString() ?? '',
      category: row['category']?.toString() ?? '',
      description: row['description']?.toString() ?? '',
      sourceType: AudioSourceType.file,
      filePath: row['file_path']?.toString(),
      fileSize: (row['file_size'] as num?)?.toInt() ?? 0,
      status: rawStatus >= AudioItem.statusPending &&
              rawStatus <= AudioItem.statusRejected
          ? rawStatus
          : AudioItem.statusPending,
      rejectReason: row['reject_reason']?.toString(),
    );
  }
}
