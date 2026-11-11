import 'package:flutter_test/flutter_test.dart';
import 'package:mengyu_app/data/repositories/private_media_repository.dart';
import 'package:mengyu_app/data/services/yt_dlp_service.dart';
import 'package:mengyu_app/models/private_media.dart';
import 'package:mengyu_app/pages/tabs/widgets/sound_list_entry.dart';
import 'package:mengyu_app/providers/private_media_provider.dart';

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

  test('URL 校验与平台直链识别', () async {
    final DirectYtDlpService service = DirectYtDlpService();
    expect(DirectYtDlpService.validateMediaUrl('not-a-url'), isNull);
    expect(DirectYtDlpService.validateMediaUrl('ftp://a/b.mp3'), isNull);
    expect(
      DirectYtDlpService.validateMediaUrl('https://example.com/a.m4a'),
      isNotNull,
    );

    final ParsedMediaInfo info = await service.parse(
      'https://example.com/a.m4a',
      type: PrivateMediaType.audio,
    );
    expect(info.title, 'a');
    expect(info.extension, 'm4a');
    expect(info.platform, '本地');

    await expectLater(
      service.parse(
        'https://www.bilibili.com/video/BV123',
        type: PrivateMediaType.audio,
      ),
      throwsA(isA<Exception>()),
    );
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
