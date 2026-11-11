import 'package:flutter_test/flutter_test.dart';
import 'package:mengyu_app/models/audio_item.dart';
import 'package:mengyu_app/models/diary_entry.dart';
import 'package:mengyu_app/models/sleep_session.dart';
import 'package:mengyu_app/utils/formatters.dart';

void main() {
  test('AudioItem 13 个字段往返序列化不变', () {
    const AudioItem item = AudioItem(
      id: 'u_1',
      title: '雨声',
      category: '雨声',
      description: '窗外细雨',
      sourceType: AudioSourceType.file,
      assetPath: 'audio/rain.wav',
      filePath: '/data/uploads/rain.wav',
      fileUrl: 'https://example.com/rain.wav',
      durationSec: 321,
      fileSize: 1024,
      status: AudioItem.statusRejected,
      rejectReason: '音质不达标',
      isFavorite: true,
    );

    final Map<String, Object?> map = item.toMap();
    expect(map['source_type'], 'file');
    expect(map['is_favorite'], 1);
    expect(map['status'], AudioItem.statusRejected);

    final AudioItem restored = AudioItem.fromMap(map);
    expect(restored.id, item.id);
    expect(restored.title, item.title);
    expect(restored.category, item.category);
    expect(restored.description, item.description);
    expect(restored.sourceType, AudioSourceType.file);
    expect(restored.assetPath, item.assetPath);
    expect(restored.filePath, item.filePath);
    expect(restored.fileUrl, item.fileUrl);
    expect(restored.durationSec, item.durationSec);
    expect(restored.fileSize, item.fileSize);
    expect(restored.status, item.status);
    expect(restored.rejectReason, item.rejectReason);
    expect(restored.isFavorite, isTrue);
  });

  test('AudioItem 缺字段时回退到安全默认值', () {
    final AudioItem restored = AudioItem.fromMap(const <String, Object?>{});
    expect(restored.id, '');
    expect(restored.sourceType, AudioSourceType.remote);
    expect(restored.status, AudioItem.statusPending);
    expect(restored.isFavorite, isFalse);

    final AudioItem dirty = AudioItem.fromMap(const <String, Object?>{
      'status': 99,
      'is_favorite': '1',
    });
    expect(dirty.status, AudioItem.statusPending);
    expect(dirty.isFavorite, isTrue);
  });

  test('DiaryEntry tags 存 JSON、id 从库行还原', () {
    final DiaryEntry entry = DiaryEntry(
      entryDate: DateTime(2026, 11, 9),
      mood: 4,
      content: '今晚的风很轻，适合早睡。',
      tags: const <String>['安静', '雨'],
      createdAt: DateTime(2026, 11, 9, 23, 10),
      updatedAt: DateTime(2026, 11, 9, 23, 20),
    );

    final Map<String, Object?> map = entry.toMap()..['id'] = 7;
    expect(map['entry_date'], '2026-11-09');
    expect(map['tags'], '["安静","雨"]');

    final DiaryEntry restored = DiaryEntry.fromMap(map);
    expect(restored.id, 7);
    expect(formatDateKey(restored.entryDate), '2026-11-09');
    expect(restored.mood, 4);
    expect(restored.content, entry.content);
    expect(restored.tags, entry.tags);
    expect(restored.createdAt, entry.createdAt);
  });

  test('DiaryEntry 坏 tags / 越界心情不会抛异常', () {
    final DiaryEntry restored = DiaryEntry.fromMap(const <String, Object?>{
      'entry_date': '2026-11-09',
      'mood': 9,
      'content': '坏数据',
      'tags': 'not-json',
      'created_at': '2026-11-09T23:00:00.000',
    });
    expect(restored.tags, isEmpty);
    expect(restored.mood, 5);
  });

  test('SleepSession 往返：时长与归属日一致', () {
    final SleepSession session = SleepSession(
      id: 3,
      bedTime: DateTime(2026, 11, 8, 23, 30),
      wakeTime: DateTime(2026, 11, 9, 7, 15),
      quality: 4,
      note: '夜里醒了一次',
    );

    final Map<String, Object?> map = session.toMap();
    expect(map['duration_min'], 465);
    expect(map['sleep_date'], '2026-11-08');
    expect(map['source'], 'manual');
    expect(map['night_key'], '2026-11-08');

    final SleepSession restored = SleepSession.fromMap(map..['id'] = 3);
    expect(restored.id, 3);
    expect(restored.durationMin, 465);
    expect(formatDateKey(restored.date), '2026-11-08');
    expect(restored.quality, 4);
    expect(restored.note, session.note);
  });

  test('SleepSession 缺时间字段抛出格式错误', () {
    expect(
      () => SleepSession.fromMap(const <String, Object?>{'quality': 3}),
      throwsFormatException,
    );
  });
}
