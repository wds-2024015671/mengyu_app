import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mengyu_app/data/repositories/local/local_sound_repository.dart';
import 'package:mengyu_app/models/audio_item.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('6 段内置音景的 assetPath 与实际文件一一对齐', () async {
    final List<AudioItem> items = await const LocalSoundRepository()
        .localAudios();
    expect(items.length, 6);

    for (final AudioItem item in items) {
      expect(item.assetPath, isNotNull, reason: item.id);
      final ByteData data = await rootBundle.load('assets/${item.assetPath}');
      expect(data.lengthInBytes, greaterThan(1000), reason: item.id);
    }
  });
}
