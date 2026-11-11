/// 收藏数据源抽象：本阶段只存在本机 prefs，后端阶段可换成账号云同步。
abstract class FavoriteRepository {
  Future<Set<String>> load();

  Future<void> save(Set<String> ids);
}
