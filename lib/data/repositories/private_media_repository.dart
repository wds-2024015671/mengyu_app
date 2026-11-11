import '../../models/private_media.dart';

abstract class PrivateMediaRepository {
  Future<List<PrivateMedia>> all();
  Future<List<PrivateMedia>> byType(PrivateMediaType type);
  Future<PrivateMedia> save(PrivateMedia media);
  Future<void> updateStatus(int id, PrivateMediaStatus status);
  Future<void> delete(int id);
  Future<int> deleteMany(Iterable<int> ids);
  Future<bool> existsByUrl(String url);
}
