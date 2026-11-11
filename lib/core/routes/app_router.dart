import 'package:flutter/material.dart';

import '../../models/audio_item.dart';
import '../../models/breathing_mode.dart';
import '../../models/diary_entry.dart';
import '../../models/sleep_session.dart';
import '../../pages/breathing/breathing_page.dart';
import '../../pages/breathing/breathing_session_page.dart';
import '../../pages/diary/diary_edit_page.dart';
import '../../pages/diary/diary_list_page.dart';
import '../../pages/login/login_page.dart';
import '../../pages/main/main_shell.dart';
import '../../pages/not_found_page.dart';
import '../../pages/player/player_page.dart';
import '../../pages/sleep/sleep_log_form_page.dart';
import '../../pages/timer/timer_page.dart';
import '../../pages/upload/upload_page.dart';
import '../../pages/welcome/welcome_page.dart';
import '../theme/app_theme.dart';
import 'app_routes.dart';

/// 统一路由分发：页面里只能 Navigator.pushNamed，禁止裸 MaterialPageRoute。
///
/// 参数一律做 is 判断：类型不对就落到 NotFoundPage，而不是在页面里
/// 断言崩溃；这样深链传错参数时用户仍有路可走。
abstract final class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.welcome:
        return _page<void>(const WelcomePage(), settings);

      case AppRoutes.login:
        return _page<void>(const LoginPage(), settings);

      // 4 个 tab 路由共用一个 MainShell，靠 initialTab 决定首屏。
      case AppRoutes.home:
        return _page<void>(const MainShell(initialTab: 0), settings);
      case AppRoutes.sound:
        return _page<void>(const MainShell(initialTab: 1), settings);
      case AppRoutes.report:
        return _page<void>(const MainShell(initialTab: 2), settings);
      case AppRoutes.profile:
        return _page<void>(const MainShell(initialTab: 3), settings);

      case AppRoutes.upload:
        // 上传页返回 true 表示成功；F07 会在 pop 时带这个值。
        return _page<bool?>(const UploadPage(), settings);

      case AppRoutes.player:
        final Object? args = settings.arguments;
        if (args is AudioItem) {
          return _page<bool?>(PlayerPage(audio: args), settings);
        }
        return _notFound(settings, '播放页需要 AudioItem 参数');

      case AppRoutes.timer:
        final Object? args = settings.arguments;
        if (args == null || args is int) {
          return _page<int?>(TimerPage(initialMinutes: args as int?), settings);
        }
        return _notFound(settings, '定时页参数应为 int?');

      case AppRoutes.breathing:
        return _page<void>(const BreathingPage(), settings);

      case AppRoutes.breathingSession:
        final Object? args = settings.arguments;
        if (args is BreathingMode) {
          return _page<int?>(BreathingSessionPage(mode: args), settings);
        }
        return _notFound(settings, '呼吸进行页需要 BreathingMode 参数');

      case AppRoutes.diary:
        return _page<void>(const DiaryListPage(), settings);

      case AppRoutes.diaryEdit:
        final Object? args = settings.arguments;
        if (args == null || args is DiaryEntry) {
          return _page<DiaryEntry?>(DiaryEditPage(entry: args as DiaryEntry?), settings);
        }
        return _notFound(settings, '日记编辑页参数应为 DiaryEntry?');

      case AppRoutes.sleepLogForm:
        final Object? args = settings.arguments;
        if (args == null || args is SleepSession) {
          return _page<bool>(SleepLogFormPage(session: args as SleepSession?), settings);
        }
        return _notFound(settings, '补记页参数应为 SleepSession?');

      default:
        return _notFound(settings, '没有找到名为 ${settings.name ?? 'null'} 的路由');
    }
  }

  /// 280ms 淡入 + 轻微上滑；返回用更短的 200ms，避免拖沓。
  static Route<T> _page<T>(Widget page, RouteSettings settings) {
    return PageRouteBuilder<T>(
      settings: settings,
      transitionDuration: AppMotion.base,
      reverseTransitionDuration: AppMotion.reverse,
      pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
        return page;
      },
      transitionsBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
        final Animation<double> fade = animation.drive(CurveTween(curve: AppMotion.curve));
        final Animation<Offset> slide = animation
            .drive(CurveTween(curve: AppMotion.curve))
            .drive(Tween<Offset>(begin: const Offset(0, 0.045), end: Offset.zero));
        return FadeTransition(
          opacity: fade,
          child: SlideTransition(position: slide, child: child),
        );
      },
    );
  }

  static Route<dynamic> _notFound(RouteSettings settings, String reason) {
    return _page<dynamic>(
      NotFoundPage(routeName: settings.name, reason: reason),
      settings,
    );
  }
}
