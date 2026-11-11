import 'package:mengyu_app/core/errors/app_exception.dart';
import 'package:mengyu_app/data/services/avatar_service.dart';

class FakeAvatarService implements AvatarService {
  FakeAvatarService({this.path});

  String? path;
  int picks = 0;
  int removes = 0;
  AvatarSource? lastSource;
  String? error;
  bool cancelPick = false;

  @override
  Future<String?> loadPath() async => path;

  @override
  Future<String?> pick(AvatarSource source) async {
    picks++;
    lastSource = source;
    if (error != null) {
      throw AppException(error!);
    }
    if (cancelPick) {
      return null;
    }
    path = '/tmp/mengyu_avatar_$picks.jpg';
    return path;
  }

  @override
  Future<void> remove(String? oldPath) async {
    removes++;
    path = null;
  }

  @override
  Future<String?> recoverLost() async => null;
}
