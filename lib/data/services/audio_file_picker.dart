import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;

import '../../core/constants/app_limits.dart';
import '../../core/errors/app_exception.dart';

/// 用户选中的音频文件；只保留页面需要的三个字段。
class PickedAudioFile {
  const PickedAudioFile({
    required this.path,
    required this.name,
    required this.size,
  });

  final String path;
  final String name;
  final int size;
}

/// 页面依赖的函数类型：测试可以注入假实现，不用真的打开系统选择器。
typedef AudioFilePicker = Future<PickedAudioFile?> Function();

/// 真实实现：只允许 mp3/wav/ogg/m4a，取消返回 null。
///
/// file_picker 的 path 在移动端是真实路径；拿不到路径时抛 AppException，
/// 由页面转成字段错误，而不是把 null 传进上传仓库。
Future<PickedAudioFile?> pickAudioFile() async {
  try {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: kAudioExtensions,
      allowMultiple: false,
      withData: false,
    );
    if (result == null || result.files.isEmpty) {
      return null;
    }
    final PlatformFile file = result.files.single;
    final String? path = file.path;
    if (path == null || path.isEmpty) {
      throw const AppException('无法读取所选文件路径，请重新选择');
    }
    final String name = file.name.isNotEmpty ? file.name : p.basename(path);
    return PickedAudioFile(path: path, name: name, size: file.size);
  } on AppException {
    rethrow;
  } catch (error) {
    throw AppException('选择文件失败，请再试一次', error);
  }
}
