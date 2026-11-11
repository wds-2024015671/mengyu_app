import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mengyu_app/core/errors/app_exception.dart';
import 'package:mengyu_app/core/routes/app_routes.dart';
import 'package:mengyu_app/core/theme/app_theme.dart';
import 'package:mengyu_app/data/repositories/auth_repository.dart';
import 'package:mengyu_app/data/repositories/upload_repository.dart';
import 'package:mengyu_app/data/services/audio_file_picker.dart';
import 'package:mengyu_app/models/app_user.dart';
import 'package:mengyu_app/models/audio_item.dart';
import 'package:mengyu_app/pages/upload/upload_page.dart';
import 'package:mengyu_app/providers/auth_provider.dart';
import 'package:mengyu_app/providers/upload_provider.dart';
import 'package:provider/provider.dart';

/// 登录必成功的假认证：只实现当前用户，其他方法不会被上传页调用。
class FakeAuthRepository extends AuthRepository {
  FakeAuthRepository({this.user});

  final AppUser? user;

  @override
  Future<AppUser?> currentUser() async => user;

  @override
  Future<AppUser> login(String username, String password) async {
    throw UnimplementedError();
  }

  @override
  Future<AppUser> register(
    String username,
    String password,
    String nickname,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<void> logout() async {}
}

/// 假上传仓库：记录页面传下来的参数，可切换成失败分支。
class FakeUploadRepository implements UploadRepository {
  FakeUploadRepository({this.fail = false});

  bool fail;
  String? lastPath;
  String? lastTitle;
  String? lastCategory;
  String? lastDescription;

  @override
  Future<AudioItem> upload(
    String filePath,
    String title,
    String category,
    String description,
  ) async {
    if (fail) {
      throw const AppException('文件复制失败，请检查存储空间后重试');
    }
    lastPath = filePath;
    lastTitle = title;
    lastCategory = category;
    lastDescription = description;
    return AudioItem(
      id: 'upload_1',
      title: title,
      category: category,
      description: description,
      sourceType: AudioSourceType.file,
      filePath: filePath,
      fileSize: 2048,
      status: AudioItem.statusPending,
    );
  }

  @override
  Future<List<AudioItem>> myUploads(int page, int size) async =>
      const <AudioItem>[];
}

PickedAudioFile pickedAudioFile({
  int size = 2048,
  String name = 'rain.wav',
}) {
  return PickedAudioFile(path: '/tmp/$name', name: name, size: size);
}

typedef UploadHarness = ({
  UploadProvider provider,
  FakeUploadRepository repository,
  Future<bool?> result,
});

/// 起一个只有 host + /upload + /login 的最小导航栈，便于观察 pop(true)。
Future<UploadHarness> openUploadPage(
  WidgetTester tester, {
  required AudioFilePicker picker,
  FakeAuthRepository? authRepository,
  FakeUploadRepository? uploadRepository,
}) async {
  tester.view.physicalSize = const Size(360, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final FakeAuthRepository authRepo = authRepository ??
      FakeAuthRepository(
        user: const AppUser(username: 'xiaoyu', nickname: '小鱼'),
      );
  final FakeUploadRepository uploadRepo =
      uploadRepository ?? FakeUploadRepository();
  final AuthProvider authProvider = AuthProvider(authRepo);
  final UploadProvider uploadProvider = UploadProvider(uploadRepo);
  addTearDown(authProvider.dispose);
  addTearDown(uploadProvider.dispose);

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider<UploadProvider>.value(value: uploadProvider),
      ],
      child: MaterialApp(
        theme: AppTheme.dark,
        home: const Scaffold(body: Center(child: Text('host'))),
        onGenerateRoute: (RouteSettings settings) {
          if (settings.name == '/upload') {
            return MaterialPageRoute<bool?>(
              builder: (BuildContext context) =>
                  UploadPage(pickFile: picker),
            );
          }
          if (settings.name == AppRoutes.login) {
            return MaterialPageRoute<void>(
              builder: (BuildContext context) => const Scaffold(
                body: Center(child: Text('login-page')),
              ),
            );
          }
          return null;
        },
      ),
    ),
  );

  final NavigatorState navigator = tester.state<NavigatorState>(
    find.byType(Navigator).first,
  );
  final Future<bool?> result = navigator.pushNamed<bool?>('/upload');
  await tester.pumpAndSettle();

  return (provider: uploadProvider, repository: uploadRepo, result: result);
}
