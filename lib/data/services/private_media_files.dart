import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// 只删除 App 私有目录下的导入文件；assets、外部路径一律跳过。
Future<void> deletePrivateMediaFile(String? path) async {
  if (path == null || path.isEmpty) {
    return;
  }
  final Directory docs = await getApplicationDocumentsDirectory();
  final String root = p.join(docs.path, 'private_media');
  final String normalized = p.normalize(p.absolute(path));
  if (!p.isWithin(root, normalized)) {
    return;
  }
  final File file = File(normalized);
  if (file.existsSync()) {
    await file.delete();
  }
}
