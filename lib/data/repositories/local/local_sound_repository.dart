import '../../../models/audio_item.dart';
import '../sound_repository.dart';

/// 本地音景实现：6 段内置声音，全部 sourceType=asset，不联网。
///
/// 为什么不从数据库读：内置资源随包发布，版本固定；
/// 直接常量列表少一次建表/迁移，也不会因为用户清库而消失。
/// 收藏状态由 F06 的 prefs 层叠加，这里只提供“原始 6 条”。
///
/// 注意：
/// 1) assetPath 对应 assets/audio/ 下的 6 个循环音文件，当前是随包发布的
///    20s 循环占位音，可替换为 CC0 实录而不用改代码。
/// 2) 循环素材不写死 durationSec（保持 0），播放器读取真实时长，
///    避免列表显示 10 分钟、实际文件只有 25 秒的不一致。
class LocalSoundRepository implements SoundRepository {
  const LocalSoundRepository();

  static const List<AudioItem> _builtIns = <AudioItem>[
    AudioItem.builtIn(
      id: 'local_rain',
      title: '雨声',
      category: '雨声',
      description: '细密的雨落在窗外，适合盖住杂念',
      assetPath: 'audio/rain_loop.wav',
    ),
    AudioItem.builtIn(
      id: 'local_ocean',
      title: '海浪',
      category: '海浪',
      description: '一波一波的潮汐，把呼吸放慢',
      assetPath: 'audio/ocean_loop.wav',
    ),
    AudioItem.builtIn(
      id: 'local_stream',
      title: '溪流',
      category: '森林',
      description: '山间溪水，适合睡前放空',
      assetPath: 'audio/stream_loop.wav',
    ),
    AudioItem.builtIn(
      id: 'local_wind',
      title: '夜风',
      category: '森林',
      description: '风穿过树梢，像很远的地方在呼吸',
      assetPath: 'audio/wind_loop.wav',
    ),
    AudioItem.builtIn(
      id: 'local_fire',
      title: '篝火',
      category: '森林',
      description: '木柴轻响，适合读书或发呆',
      assetPath: 'audio/fire_loop.wav',
    ),
    AudioItem.builtIn(
      id: 'local_noise',
      title: '白噪',
      category: '白噪',
      description: '稳定的底噪，屏蔽环境里的突发声响',
      assetPath: 'audio/noise_loop.wav',
    ),
  ];

  @override
  Future<List<AudioItem>> localAudios() async => _builtIns;

  @override
  Future<List<AudioItem>> publicAudios(
    int page,
    int size, [
    String keyword = '',
    String category = '',
  ]) async {
    // 公共库要等后端阶段；本阶段严格返回空列表，绝不塞死数据。
    return const <AudioItem>[];
  }
}
