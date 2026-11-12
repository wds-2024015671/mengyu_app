import 'package:mengyu_app/core/theme/app_tokens.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../models/audio_item.dart';
import '../../providers/player_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/sound_provider.dart';
import 'widgets/player_controls.dart';
import 'widgets/player_now_playing.dart';
import 'widgets/player_time_footer.dart';
import 'widgets/player_top_bar.dart';
/// v7 沉浸播放页：唯一允许三段渐变与金色主播放键的页面。
class PlayerPage extends StatefulWidget {
  const PlayerPage({super.key, required this.audio});
  final AudioItem audio;
  @override
  State<PlayerPage> createState() => _PlayerPageState();
}
class _PlayerPageState extends State<PlayerPage> {
  late final PlayerProvider _player;
  late AudioItem _audio;
  String? _lastError;
  @override
  void initState() {
    super.initState();
    _audio = widget.audio;
    _player = context.read<PlayerProvider>();
    _lastError = _player.error;
    _player.addListener(_onPlayerChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _player.play(_audio);
    });
  }
  @override
  void didUpdateWidget(covariant PlayerPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.audio.id != widget.audio.id) {
      _audio = widget.audio;
      unawaited(_player.play(_audio));
    }
  }
  @override
  void dispose() {
    _player.removeListener(_onPlayerChanged);
    unawaited(_player.onPageLeave());
    super.dispose();
  }
  void _onPlayerChanged() {
    if (!mounted) {
      return;
    }
    final String? notice = _player.takeNotice();
    if (notice != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(notice)),
      );
    }
    final String? error = _player.error;
    if (error != null && error != _lastError) {
      _lastError = error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          action: SnackBarAction(
            label: '重试',
            onPressed: _player.retry,
          ),
        ),
      );
    } else if (error == null) {
      _lastError = null;
    }
  }
  Future<void> _openTimer() async {
    final int initial = _player.remaining?.inMinutes ??
        context.read<SettingsProvider>().defaultTimerMinutes;
    final int? minutes = await Navigator.pushNamed<int?>(
      context,
      AppRoutes.timer,
      arguments: initial,
    );
    if (!mounted || minutes == null) {
      return;
    }
    _player.startTimer(duration: Duration(minutes: minutes));
  }
  void _step(int delta) {
    final List<AudioItem> list = context.read<SoundProvider>().localAudios;
    final int index = list.indexWhere((AudioItem item) => item.id == _audio.id);
    if (index < 0) {
      return;
    }
    final int target = index + delta;
    if (target < 0 || target >= list.length) {
      return;
    }
    final AudioItem next = list[target];
    setState(() => _audio = next);
    unawaited(_player.play(next));
  }
  @override
  Widget build(BuildContext context) {
    final List<AudioItem> local = context.watch<SoundProvider>().localAudios;
    final int index = local.indexWhere((AudioItem item) => item.id == _audio.id);
    final bool canPrevious = index > 0;
    final bool canNext = index >= 0 && index < local.length - 1;
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
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                0,
                AppSpacing.page,
                AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  PlayerTopBar(
                    onBack: () => Navigator.maybePop(context),
                    onTrailing: _openTimer,
                  ),
                  Expanded(
                    child: Selector<PlayerProvider, bool>(
                      selector: (_, PlayerProvider provider) =>
                          provider.status == PlayerStatus.error,
                      builder: (BuildContext context, bool _, Widget? __) {
                        return PlayerNowPlaying(
                          audio: _audio,
                          player: _player,
                        );
                      },
                    ),
                  ),
                  Selector<PlayerProvider, PlayerStatus>(
                    selector: (_, PlayerProvider provider) => provider.status,
                    builder: (
                      BuildContext context,
                      PlayerStatus status,
                      Widget? _,
                    ) {
                      return PlayerControls(
                        player: _player,
                        canPrevious: canPrevious,
                        canNext: canNext,
                        onPrevious: () => _step(-1),
                        onNext: () => _step(1),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  PlayerTimeFooter(player: _player, audio: _audio),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
