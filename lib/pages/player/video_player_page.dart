import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_tokens.dart';
import '../../providers/demo_visibility_provider.dart';
import '../../providers/private_media_provider.dart';
import '../../providers/settings_provider.dart';
import '../tabs/widgets/sound_catalog.dart';
import '../tabs/widgets/sound_list_entry.dart';
import 'widgets/player_progress_ring.dart';
import 'widgets/player_top_bar.dart';
import 'widgets/video_artwork.dart';
import 'widgets/video_controls.dart';
import 'widgets/video_time_footer.dart';
/// 视频分支复用音频播放器的竖屏结构，不提供 16:9 默认控制条。
class VideoPlayerPage extends StatefulWidget {
  const VideoPlayerPage({super.key, required this.video});
  final VideoEntry video;
  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}
class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late VideoEntry _video;
  VideoPlayerController? _controller;
  bool _ready = false;
  bool _failed = false;
  Timer? _sleepTimer;
  Duration? _remaining;
  @override
  void initState() {
    super.initState();
    _video = widget.video;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<PrivateMediaProvider>().ensureLoaded();
        context.read<DemoVisibilityProvider>().ensureLoaded();
      }
    });
    _load(_video);
  }
  Future<void> _load(VideoEntry video) async {
    final VideoPlayerController? old = _controller;
    _controller = null;
    if (mounted) {
      setState(() {
        _ready = false;
        _failed = false;
      });
    }
    await old?.dispose();
    final String? path = video.localPath;
    final String? asset = video.assetPath;
    final VideoPlayerController controller = path != null
        ? VideoPlayerController.file(File(path))
        : VideoPlayerController.asset(asset ?? '');
    _controller = controller;
    controller.addListener(_onVideoChanged);
    try {
      await controller.initialize();
      await controller.setLooping(false);
      await controller.play();
      if (mounted) {
        setState(() => _ready = true);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _failed = true);
      }
    }
  }
  void _onVideoChanged() {
    if (mounted) {
      setState(() {});
    }
  }
  Future<void> _toggle() async {
    final VideoPlayerController? controller = _controller;
    if (!_ready || controller == null) {
      return;
    }
    if (controller.value.position >= controller.value.duration) {
      await controller.seekTo(Duration.zero);
    }
    if (controller.value.isPlaying) {
      await controller.pause();
    } else {
      await controller.play();
    }
    if (mounted) {
      setState(() {});
    }
  }
  List<VideoEntry> _playlist() {
    return buildVideoEntries(
      private: context.read<PrivateMediaProvider>(),
      query: '',
      hiddenDemoKeys: context.read<DemoVisibilityProvider>().hidden,
    );
  }
  Future<void> _step(int delta) async {
    final List<VideoEntry> list = _playlist();
    final int index = list.indexWhere((VideoEntry item) => item.key == _video.key);
    final int target = index + delta;
    if (index < 0 || target < 0 || target >= list.length) {
      return;
    }
    setState(() => _video = list[target]);
    await _load(_video);
  }
  Future<void> _openTimer() async {
    final int initial = _remaining?.inMinutes ??
        context.read<SettingsProvider>().defaultTimerMinutes;
    final int? minutes = await Navigator.pushNamed<int?>(
      context,
      AppRoutes.timer,
      arguments: initial,
    );
    if (!mounted || minutes == null) {
      return;
    }
    _sleepTimer?.cancel();
    setState(() => _remaining = Duration(minutes: minutes));
    _sleepTimer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      final Duration? value = _remaining;
      if (value == null) {
        return;
      }
      final Duration next = value - const Duration(seconds: 1);
      if (next <= Duration.zero) {
        timer.cancel();
        _controller?.pause();
        setState(() => _remaining = null);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('定时结束，已停止播放')),
        );
        return;
      }
      setState(() => _remaining = next);
    });
  }
  @override
  void dispose() {
    _sleepTimer?.cancel();
    _controller?.removeListener(_onVideoChanged);
    _controller?.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final VideoPlayerController? controller = _controller;
    final VideoPlayerValue value =
        controller?.value ?? const VideoPlayerValue(duration: Duration.zero);
    final double progress = mediaProgress(value.position, value.duration);
    final List<VideoEntry> playlist = _playlist();
    final int index =
        playlist.indexWhere((VideoEntry item) => item.key == _video.key);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness:
            isDark ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: context.c.bgDeep,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: context.c.playerGradient,
              stops: const <double>[0, 0.52, 1],
            ),
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.page,
                  ),
                  child: PlayerTopBar(
                    onBack: () => Navigator.maybePop(context),
                  ),
                ),
                Expanded(
                  child: VideoNowPlaying(
                    video: _video,
                    controller: controller,
                    ready: _ready,
                    failed: _failed,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.page,
                    0,
                    AppSpacing.page,
                    AppSpacing.lg,
                  ),
                  child: Column(
                    children: <Widget>[
                      VideoControls(
                        progress: progress,
                        isPlaying: value.isPlaying,
                        canPrevious: index > 0,
                        canNext: index >= 0 && index < playlist.length - 1,
                        onPrevious: () => _step(-1),
                        onNext: () => _step(1),
                        onTogglePlay: _toggle,
                        onTimer: _openTimer,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      VideoTimeFooter(
                        position: value.position,
                        duration: value.duration,
                        timer: _remaining,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
/// 打开视频播放页；入口统一走这里，避免再弹 16:9 预览层。
Future<void> openVideoPlayer(BuildContext context, VideoEntry video) async {
  await Navigator.push<void>(
    context,
    MaterialPageRoute<void>(
      builder: (BuildContext pageContext) => VideoPlayerPage(video: video),
    ),
  );
}
