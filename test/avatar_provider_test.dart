import 'package:flutter_test/flutter_test.dart';
import 'package:mengyu_app/data/services/avatar_service.dart';
import 'package:mengyu_app/providers/avatar_provider.dart';

import 'support/fake_avatar_service.dart';

void main() {
  test('头像状态：读取、选择、失败、移除', () async {
    final FakeAvatarService service = FakeAvatarService(
      path: '/tmp/existing.jpg',
    );
    final AvatarProvider provider = AvatarProvider(service);
    addTearDown(provider.dispose);

    await provider.ensureLoaded();
    expect(provider.path, '/tmp/existing.jpg');
    expect(provider.hasAvatar, isTrue);

    expect(await provider.pick(AvatarSource.gallery), isTrue);
    expect(service.lastSource, AvatarSource.gallery);
    expect(provider.path, '/tmp/mengyu_avatar_1.jpg');

    service.error = '相机权限被拒绝，请到系统设置中开启相机权限';
    expect(await provider.pick(AvatarSource.camera), isFalse);
    expect(provider.error, contains('相机权限被拒绝'));

    provider.clearError();
    expect(provider.error, isNull);

    service.error = null;
    service.cancelPick = true;
    expect(await provider.pick(AvatarSource.gallery), isFalse);
    expect(provider.error, isNull);
    expect(provider.path, '/tmp/mengyu_avatar_1.jpg');

    await provider.remove();
    expect(provider.path, isNull);
    expect(service.removes, 1);
  });
}
