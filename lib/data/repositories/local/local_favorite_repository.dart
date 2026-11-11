import 'package:shared_preferences/shared_preferences.dart';

import '../favorite_repository.dart';

/// 本地收藏实现：一个 StringList 存所有收藏过（目前只有音景）的 id。
class LocalFavoriteRepository implements FavoriteRepository {
  const LocalFavoriteRepository();

  /// 测试里也用这个 key 断言落盘结果。
  static const String prefsKey = 'favorites.sound_ids';

  @override
  Future<Set<String>> load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(prefsKey) ?? const <String>[]).toSet();
  }

  @override
  Future<void> save(Set<String> ids) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> sorted = ids.toList()..sort();
    await prefs.setStringList(prefsKey, sorted);
  }
}
