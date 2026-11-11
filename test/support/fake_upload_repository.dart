import 'package:mengyu_app/data/repositories/upload_repository.dart';
import 'package:mengyu_app/models/audio_item.dart';

/// 内存上传仓库：我的页只关心列表数量，测试也不需要 sqflite。
class FakeUploadRepository implements UploadRepository {
  FakeUploadRepository([List<AudioItem>? initial])
      : items = initial ?? <AudioItem>[];

  final List<AudioItem> items;

  @override
  Future<AudioItem> upload(
    String filePath,
    String title,
    String category,
    String description,
  ) async {
    final AudioItem item = AudioItem(
      id: 'upload_${items.length + 1}',
      title: title,
      category: category,
      description: description,
      sourceType: AudioSourceType.file,
      filePath: filePath,
      status: AudioItem.statusPending,
    );
    items.insert(0, item);
    return item;
  }

  @override
  Future<List<AudioItem>> myUploads(int page, int size) async =>
      List<AudioItem>.of(items);
}
