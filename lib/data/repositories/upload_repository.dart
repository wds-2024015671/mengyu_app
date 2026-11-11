import '../../models/audio_item.dart';

/// 用户上传能力抽象。
///
/// 本阶段 LocalUploadRepository 只写本地表（status=0 审核中），
/// 后端阶段换成 ApiUploadRepository（multipart + 审核状态），页面不改。
abstract class UploadRepository {
  /// 提交一个音频文件，返回写库后的记录（status 必须为 0 审核中）。
  Future<AudioItem> upload(
    String filePath,
    String title,
    String category,
    String description,
  );

  /// 我的上传分页列表，按创建时间倒序。
  Future<List<AudioItem>> myUploads(int page, int size);
}
