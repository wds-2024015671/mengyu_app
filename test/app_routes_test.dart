import 'package:flutter_test/flutter_test.dart';
import 'package:mengyu_app/core/routes/app_routes.dart';
import 'package:mengyu_app/models/audio_item.dart';

void main() {
  test('14 条命名路由齐全且不重复', () {
    expect(AppRoutes.all.length, 14);
    expect(AppRoutes.all.toSet().length, 14);
    expect(AppRoutes.all, contains('/'));
    expect(AppRoutes.all, contains('/diary/edit'));
    expect(AppRoutes.all, contains('/breathing_session'));
  });

  test('AudioItem 内置音景：已上架且本地可播', () {
    const AudioItem item = AudioItem.builtIn(
      id: 'local_rain',
      title: '雨声',
      category: '雨',
      assetPath: 'audio/rain.wav',
    );
    expect(item.sourceType, AudioSourceType.asset);
    expect(item.status, AudioItem.statusPublished);
    expect(item.isFavorite, isFalse);
    expect(item.playableOffline, isTrue);
    expect(item.isAvailable, isTrue);
    expect(item.sourceType.isLocal, isTrue);
  });

  test('AudioItem 默认审核中：上传不会伪造上架状态', () {
    const AudioItem upload = AudioItem(
      id: 'u_1',
      title: '我的雨声',
      category: '雨',
      sourceType: AudioSourceType.remote,
      fileUrl: 'http://example.com/a.wav',
    );
    expect(upload.status, AudioItem.statusPending);
    expect(upload.playableOffline, isFalse);
    expect(upload.isAvailable, isFalse);
  });
}
