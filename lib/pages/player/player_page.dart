import 'package:mengyu_app/core/theme/app_tokens.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../models/audio_item.dart';
import '../../providers/favorite_provider.dart';
import '../../providers/player_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/sound_provider.dart';
import '../../utils/formatters.dart';
import 'widgets/player_controls.dart';
import 'widgets/player_cover.dart';
import 'widgets/player_error_panel.dart';
import 'widgets/player_progress.dart';
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
  Future<void> _handleBack() async {
    if (_player.isPlaying) {
      final bool? start = await showDialog<bool>(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text('要开始记录睡眠吗？'),
            content: Text(
              '声音已停止。梦屿可以从现在开始计时，明早提醒你确认。',
              style: context.s.bodySecondary,
            ),
            actions: <Widget>[
              TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('不用了')),
              TextButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('开始记录')),
            ],
          );
        },
      );
      if (!mounted) return;
      if (start == true) {
        final bool started = await _player.startSleepRecording();
        if (!started && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('自动记录已关闭，可在设置中开启')),
          );
        }
      }
    }
    if (mounted) { Navigator.maybePop(context); }
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
  String _timerLabel(PlayerProvider player) {
    final Duration? remaining = player.remaining;
    if (remaining == null) {
      return '未设定时';
    }
    return '定时 ${formatSeconds(remaining.inSeconds)} · 到点自动停';
  }
  @override
  Widget build(BuildContext context) {
    final PlayerProvider player = context.watch<PlayerProvider>();
    final FavoriteProvider favorites = context.watch<FavoriteProvider>();
    final List<AudioItem> local = context.watch<SoundProvider>().localAudios;
    final int index = local.indexWhere((AudioItem item) => item.id == _audio.id);
    final bool canPrevious = index > 0;
    final bool canNext = index >= 0 && index < local.length - 1;
    final bool favorite = favorites.isFavorite(_audio.id);
    final Duration duration = player.duration > Duration.zero
        ? player.duration
        : Duration(seconds: _audio.durationSec);
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
                    onBack: _handleBack,
                    onMore: _openTimer,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    height: 250,
                    child: Center(child: PlayerCover(item: _audio)),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    _audio.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: context.s.title,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${_audio.category} · 深度助眠',
                    textAlign: TextAlign.center,
                    style: context.s.caption,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  if (player.status == PlayerStatus.error)
                    PlayerErrorPanel(player: player)
                  else
                    PlayerProgress(
                      position: player.position,
                      duration: duration,
                      enabled: !player.isLoading,
                      onSeek: player.seek,
                    ),
                  const Spacer(),
                  PlayerControls(
                    player: player,
                    isFavorite: favorite,
                    onToggleFavorite: () => favorites.toggle(_audio.id),
                    onOpenTimer: _openTimer,
                    canPrevious: canPrevious,
                    canNext: canNext,
                    onPrevious: () => _step(-1),
                    onNext: () => _step(1),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    _timerLabel(player),
                    textAlign: TextAlign.center,
                    style: context.s.captionMuted,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
