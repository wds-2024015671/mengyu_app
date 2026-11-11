import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/errors/app_exception.dart';

enum AvatarSource { camera, gallery }

const int _avatarSize = 512;

/// 头像数据的可替换边界：页面只依赖它，测试可注入假实现。
abstract interface class AvatarService {
  Future<String?> loadPath();
  Future<String?> pick(AvatarSource source);
  Future<void> remove(String? path);
  Future<String?> recoverLost();
}

/// 本地头像：相机/相册 → 1:1 512 JPEG85 → 应用文档目录。
class LocalAvatarService implements AvatarService {
  LocalAvatarService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  static const String prefsKey = 'avatar_path';
  static const int _maxBytes = 2 * 1024 * 1024;

  final ImagePicker _picker;

  @override
  Future<String?> loadPath() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? path = prefs.getString(prefsKey);
    if (path == null || path.isEmpty) {
      return null;
    }
    if (!File(path).existsSync()) {
      await prefs.remove(prefsKey);
      return null;
    }
    return path;
  }

  @override
  Future<String?> pick(AvatarSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source == AvatarSource.camera
            ? ImageSource.camera
            : ImageSource.gallery,
        maxWidth: 4096,
        maxHeight: 4096,
        imageQuality: 100,
        requestFullMetadata: false,
      );
      if (picked == null) {
        return null;
      }
      return _save(await picked.readAsBytes());
    } on PlatformException catch (error) {
      throw AppException(_permissionMessage(error), error);
    } catch (error) {
      throw AppException(
        AppException.describe(error, fallback: '头像处理失败，请换一张照片'),
        error,
      );
    }
  }

  @override
  Future<String?> recoverLost() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return null;
    }
    try {
      final LostDataResponse response = await _picker.retrieveLostData();
      if (response.isEmpty) {
        return null;
      }
      final XFile? file = response.file;
      if (file == null) {
        return null;
      }
      return _save(await file.readAsBytes());
    } on MissingPluginException {
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> remove(String? path) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(prefsKey);
    if (path != null && path.isNotEmpty) {
      final File file = File(path);
      if (file.existsSync()) {
        await file.delete();
      }
    }
  }

  Future<String> _save(Uint8List bytes) async {
    final Uint8List jpg = prepareAvatarBytes(bytes);
    if (jpg.length > _maxBytes) {
      throw const AppException('头像处理后仍超过 2MB，请换一张照片');
    }

    final Directory docs = await getApplicationDocumentsDirectory();
    final Directory avatars = Directory('${docs.path}/avatars');
    if (!avatars.existsSync()) {
      await avatars.create(recursive: true);
    }
    final File target = File(
      '${avatars.path}/avatar_${DateTime.now().microsecondsSinceEpoch}.jpg',
    );
    await target.writeAsBytes(jpg, flush: true);

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? previous = prefs.getString(prefsKey);
    await prefs.setString(prefsKey, target.path);
    if (previous != null && previous.isNotEmpty && previous != target.path) {
      final File old = File(previous);
      await FileImage(old).evict();
      if (old.existsSync()) {
        try {
          await old.delete();
        } catch (_) {
          // 旧图删不掉不影响新头像生效，下次写入会继续尝试覆盖路径。
        }
      }
    }
    return target.path;
  }

  String _permissionMessage(PlatformException error) {
    final String code = error.code.toLowerCase();
    if (code.contains('camera')) {
      return '相机权限被拒绝，请到系统设置中开启相机权限';
    }
    if (code.contains('photo') || code.contains('gallery')) {
      return '相册权限被拒绝，请到系统设置中开启照片权限';
    }
    return AppException.describe(error, fallback: '无法打开相机或相册');
  }
}

/// 中心裁 1:1 → 512×512 → JPEG 85；单独暴露便于边界测试。
@visibleForTesting
Uint8List prepareAvatarBytes(Uint8List bytes) {
  final img.Image? decoded = img.decodeImage(bytes);
  if (decoded == null) {
    throw const AppException('无法读取这张照片');
  }
  final img.Image oriented = img.bakeOrientation(decoded);
  final int side = math.min(oriented.width, oriented.height);
  img.Image square = img.copyCrop(
    oriented,
    x: (oriented.width - side) ~/ 2,
    y: (oriented.height - side) ~/ 2,
    width: side,
    height: side,
  );
  if (side != _avatarSize) {
    square = img.copyResize(square, width: _avatarSize, height: _avatarSize);
  }
  return Uint8List.fromList(img.encodeJpg(square, quality: 85));
}
