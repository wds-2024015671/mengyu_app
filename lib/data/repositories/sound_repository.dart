import '../../models/audio_item.dart';

/// 声屿数据来源抽象。
///
/// localAudios：App 内置音景（sourceType=asset），永远不联网。
/// publicAudios：服务端公共库（sourceType=remote），本阶段返回空列表。
/// 分页是否还有下一页，用「本次返回条数 == size」判断，不绑定后端响应结构。
abstract class SoundRepository {
  Future<List<AudioItem>> localAudios();

  Future<List<AudioItem>> publicAudios(
    int page,
    int size, [
    String keyword = '',
    String category = '',
  ]);
}
