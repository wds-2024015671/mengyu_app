import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:mengyu_app/core/errors/app_exception.dart';
import 'package:mengyu_app/data/services/avatar_service.dart';

void main() {
  test('头像：中心裁 1:1、512 JPEG、体积小于 2MB', () {
    final img.Image source = img.Image(width: 800, height: 600);
    img.fill(source, color: img.ColorRgb8(120, 90, 200));
    final Uint8List input =
        Uint8List.fromList(img.encodeJpg(source, quality: 95));

    final Uint8List output = prepareAvatarBytes(input);
    final img.Image? decoded = img.decodeImage(output);

    expect(decoded, isNotNull);
    expect(decoded!.width, 512);
    expect(decoded.height, 512);
    expect(output.length, lessThan(2 * 1024 * 1024));
    expect(output[0], 0xFF);
    expect(output[1], 0xD8);
  });

  test('头像：坏图片给出可展示错误', () {
    expect(
      () => prepareAvatarBytes(Uint8List.fromList(<int>[1, 2, 3])),
      throwsA(isA<AppException>()),
    );
  });
}
