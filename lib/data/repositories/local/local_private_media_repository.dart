import '../../../models/private_media.dart';
import '../../dao/private_media_dao.dart';
import '../private_media_repository.dart';

class LocalPrivateMediaRepository implements PrivateMediaRepository {
  const LocalPrivateMediaRepository(this._dao);

  final PrivateMediaDao _dao;

  @override
  Future<List<PrivateMedia>> all() => _dao.queryAll();

  @override
  Future<List<PrivateMedia>> byType(PrivateMediaType type) =>
      _dao.queryByType(type);

  @override
  Future<PrivateMedia> save(PrivateMedia media) async {
    if (media.id == 0) {
      final int id = await _dao.insert(media);
      return PrivateMedia.fromMap(<String, Object?>{
        ...media.toMap(),
        'id': id,
      });
    }
    await _dao.updateStatus(media.id, media.status);
    return media;
  }

  @override
  Future<void> updateStatus(int id, PrivateMediaStatus status) =>
      _dao.updateStatus(id, status);

  @override
  Future<void> delete(int id) => _dao.delete(id);

  @override
  Future<int> deleteMany(Iterable<int> ids) => _dao.deleteMany(ids);

  @override
  Future<bool> existsByUrl(String url) => _dao.existsByUrl(url);
}
