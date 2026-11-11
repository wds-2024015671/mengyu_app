import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../core/audio/audio_engine.dart';
import '../core/audio/audioplayers_engine.dart';
import '../core/constants/app_settings.dart';
import '../data/dao/diary_dao.dart';
import '../data/dao/private_media_dao.dart';
import '../data/dao/session_dao.dart';
import '../data/dao/sleep_tracking_dao.dart';
import '../data/db/app_database.dart';
import '../data/repositories/local/local_auth_repository.dart';
import '../data/repositories/local/local_diary_repository.dart';
import '../data/repositories/local/local_favorite_repository.dart';
import '../data/repositories/local/local_private_media_repository.dart';
import '../data/repositories/local/local_session_repository.dart';
import '../data/repositories/local/local_settings_repository.dart';
import '../data/repositories/local/local_sleep_tracking_repository.dart';
import '../data/repositories/local/local_sound_repository.dart';
import '../data/repositories/local/local_upload_repository.dart';
import '../data/services/app_data_cleaner.dart';
import '../data/services/avatar_service.dart';
import '../data/services/sleep_notification_service.dart';
import '../data/services/sleep_tracking_service.dart';
import 'auth_provider.dart';
import 'avatar_provider.dart';
import 'diary_provider.dart';
import 'favorite_provider.dart';
import 'player_provider.dart';
import 'private_media_provider.dart';
import 'settings_provider.dart';
import 'sleep_provider.dart';
import 'sleep_tracking_provider.dart';
import 'sound_provider.dart';
import 'upload_provider.dart';

/// 组合根：全项目唯一 new Repository 的地方。
///
/// 页面只通过 Provider 拿数据，不接触 sqflite / prefs / path_provider；
/// 后端阶段只需要把这里的 Local 实现替换成 Api 实现。
/// audioEngineFactory 只在测试里注入假引擎，生产默认走 audioplayers。
List<SingleChildWidget> buildAppProviders({
  AudioEngine Function()? audioEngineFactory,
  AppThemeMode? initialThemeMode,
}) {
  final AppDatabase database = AppDatabase.instance;
  final LocalSessionRepository sessions =
      LocalSessionRepository(SessionDao(database));
  final SleepTrackingService tracking = SleepTrackingService(
    tracking: LocalSleepTrackingRepository(SleepTrackingDao(database)),
    sessions: sessions,
    notifications: LocalSleepNotificationService(),
  );
  return <SingleChildWidget>[
    ChangeNotifierProvider<SettingsProvider>(
      create: (_) => SettingsProvider(
        const LocalSettingsRepository(),
        const LocalAppDataCleaner(),
        initialThemeMode: initialThemeMode,
      ),
    ),
    ChangeNotifierProvider<AuthProvider>(
      create: (_) => AuthProvider(const LocalAuthRepository()),
    ),
    ChangeNotifierProvider<AvatarProvider>(
      create: (_) => AvatarProvider(LocalAvatarService()),
    ),
    ChangeNotifierProvider<DiaryProvider>(
      create: (_) => DiaryProvider(LocalDiaryRepository(DiaryDao(database))),
    ),
    ChangeNotifierProvider<SleepProvider>(
      create: (_) => SleepProvider(sessions),
    ),
    ChangeNotifierProvider<SleepTrackingProvider>(
      create: (_) => SleepTrackingProvider(tracking),
    ),
    ChangeNotifierProvider<SoundProvider>(
      create: (_) => SoundProvider(const LocalSoundRepository()),
    ),
    ChangeNotifierProvider<PrivateMediaProvider>(
      create: (_) => PrivateMediaProvider(
        LocalPrivateMediaRepository(PrivateMediaDao(database)),
      ),
    ),
    ChangeNotifierProvider<FavoriteProvider>(
      create: (_) => FavoriteProvider(const LocalFavoriteRepository()),
    ),
    ChangeNotifierProvider<PlayerProvider>(
      create: (_) => PlayerProvider(
        engineFactory: audioEngineFactory ?? AudioplayersEngine.new,
        sessionRepository: sessions,
        trackingService: tracking,
      ),
    ),
    ChangeNotifierProvider<UploadProvider>(
      create: (_) => UploadProvider(LocalUploadRepository(database)),
    ),
  ];
}
