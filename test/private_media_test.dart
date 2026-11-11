import 'package:flutter_test/flutter_test.dart';
import 'package:mengyu_app/data/repositories/private_media_repository.dart';
import 'package:mengyu_app/models/private_media.dart';
import 'package:mengyu_app/pages/tabs/widgets/sound_list_entry.dart';
import 'package:mengyu_app/providers/demo_visibility_provider.dart';
import 'package:mengyu_app/providers/private_media_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeRepo implements PrivateMediaRepository {
  final List<PrivateMedia> items = <PrivateMedia>[];
  int _id = 1;

  @override
  Future<List<PrivateMedia>> all() async => items;
  @override
  Future<List<PrivateMedia>> byType(PrivateMediaType type) async =>
      items.where((PrivateMedia item) => item.type == type).toList();
  @override
  Future<PrivateMedia> save(PrivateMedia media) async {
    final PrivateMedia saved = PrivateMedia(
      id: _id++,
      type: media.type,
      title: media.title,
      sourceUrl: media.sourceUrl,
      localPath: media.localPath,
      durationMs: media.durationMs,
      platform: media.platform,
      fileSize: media.fileSize,
      status: media.status,
      createdAt: media.createdAt,
    );
    items.insert(0, saved);
    return saved;
  }

  @override
  Future<void> updateStatus(int id, PrivateMediaStatus status) async {}
  @override
  Future<void> delete(int id) async =>
      items.removeWhere((PrivateMedia item) => item.id == id);
  @override
  Future<int> deleteMany(Iterable<int> ids) async {
    final Set<int> targets = ids.toSet();
    final int before = items.length;
    items.removeWhere((PrivateMedia item) => targets.contains(item.id));
    return before - items.length;
  }
  @override
  Future<bool> existsByUrl(String url) async =>
      items.any((PrivateMedia item) => item.sourceUrl == url);
}

void main() {
  test('私人媒体：序列化、时长、音频映射', () {
    final PrivateMedia media = PrivateMedia(
      id: 1,
      type: PrivateMediaType.audio,
      title: '雨夜',
      sourceUrl: 'https://example.com/a.m4a',
      localPath: '/tmp/a.m4a',
      durationMs: 3723000,
      platform: 'Bilibili',
      fileSize: 1024,
      status: PrivateMediaStatus.ready,
      createdAt: DateTime(2026, 11, 11, 23),
    );
    final PrivateMedia restored = PrivateMedia.fromMap(<String, Object?>{
      ...media.toMap(),
      'id': 1,
    });
    expect(restored.title, '雨夜');
    expect(restored.type, PrivateMediaType.audio);
    expect(restored.status, PrivateMediaStatus.ready);
    expect(restored.createdAt, media.createdAt);
    expect(restored.toAudioItem().filePath, '/tmp/a.m4a');
    expect(formatMediaDuration(3723000), '01:02:03');
    expect(formatMediaDuration(65000), '01:05');
    expect(formatMediaDuration(0), '—');
  });

  test('演示内容删除标记跨实例保存', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final DemoVisibilityProvider first = DemoVisibilityProvider();
    await first.ensureLoaded();
    await first.hide(<String>['demo_sound_local_rain']);
    expect(first.isHidden('demo_sound_local_rain'), isTrue);

    final DemoVisibilityProvider second = DemoVisibilityProvider();
    await second.ensureLoaded();
    expect(second.isHidden('demo_sound_local_rain'), isTrue);
    await second.reset();
    expect(second.isHidden('demo_sound_local_rain'), isFalse);
  });

  test('私人库 Provider：导入后立即可用，按类型分组', () async {
    final PrivateMediaProvider provider =
        PrivateMediaProvider(_FakeRepo());
    addTearDown(provider.dispose);
    await provider.load();
    final bool saved = await provider.importMedia(
      PrivateMedia(
        id: 0,
        type: PrivateMediaType.audio,
        title: '雨夜',
        sourceUrl: 'https://example.com/a.m4a',
        localPath: '/tmp/a.m4a',
        durationMs: 60000,
        platform: 'Bilibili',
        fileSize: 10,
        status: PrivateMediaStatus.ready,
        createdAt: DateTime(2026, 11, 11),
      ),
    );
    expect(saved, isTrue);
    expect(provider.audios.length, 1);
    expect(provider.audios.first.title, '雨夜');
    expect(provider.videos, isEmpty);
    expect(await provider.existsByUrl('https://example.com/a.m4a'), isTrue);
    expect(await provider.deleteMedia(1), isTrue);
    expect(provider.audios.length, 0);
  });
}
