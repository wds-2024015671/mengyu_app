import 'package:mengyu_app/data/repositories/favorite_repository.dart';

class FakeFavoriteRepository implements FavoriteRepository {
  FakeFavoriteRepository([Set<String>? initial])
      : ids = initial ?? <String>{};

  Set<String> ids;

  @override
  Future<Set<String>> load() async => Set<String>.of(ids);

  @override
  Future<void> save(Set<String> value) async {
    ids = Set<String>.of(value);
  }
}
