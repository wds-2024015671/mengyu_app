import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'core/audio/audio_engine.dart';
import 'core/constants/app_settings.dart';
import 'core/routes/app_router.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'providers/app_providers.dart';
import 'providers/settings_provider.dart';

/// 应用根：Provider 组合根 + 中文本地化 + 统一路由。
///
/// 为什么改成 StatefulWidget：buildAppProviders 只能执行一次，
/// 否则热重载/父级重建时会重复创建 Repository 与 Provider 配置。
class MengYuApp extends StatefulWidget {
  const MengYuApp({
    super.key,
    this.audioEngineFactory,
    this.initialThemeMode,
  });

  /// 测试专用：注入假音频引擎，生产默认为 audioplayers。
  final AudioEngine Function()? audioEngineFactory;

  /// main 预读的主题，避免启动第一帧闪回默认深色。
  final AppThemeMode? initialThemeMode;

  @override
  State<MengYuApp> createState() => _MengYuAppState();
}

class _MengYuAppState extends State<MengYuApp> {
  late final List<SingleChildWidget> _providers;

  @override
  void initState() {
    super.initState();
    _providers = buildAppProviders(
      audioEngineFactory: widget.audioEngineFactory,
      initialThemeMode: widget.initialThemeMode,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: _providers,
      child: const _AppView(),
    );
  }
}

/// 单独的 MaterialApp 层：这样才能 watch SettingsProvider，
/// 切换主题时立刻重建 themeMode，而不是等下一次路由跳转。
class _AppView extends StatefulWidget {
  const _AppView();

  @override
  State<_AppView> createState() => _AppViewState();
}

class _AppViewState extends State<_AppView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<SettingsProvider>().ensureLoaded();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final SettingsProvider settings = context.watch<SettingsProvider>();
    return MaterialApp(
      title: '梦屿',
      debugShowCheckedModeBanner: false,

      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: settings.themeMode,

      // 中文优先：日期/时间选择器、系统弹窗都跟着走。
      locale: const Locale('zh', 'CN'),
      supportedLocales: const <Locale>[Locale('zh', 'CN'), Locale('en', 'US')],
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      initialRoute: AppRoutes.welcome,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
