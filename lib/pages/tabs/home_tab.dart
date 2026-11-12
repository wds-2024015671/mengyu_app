import 'package:mengyu_app/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../models/audio_item.dart';
import '../../models/sleep_session.dart';
import '../../providers/auth_provider.dart';
import '../../providers/sleep_provider.dart';
import '../../providers/sound_provider.dart';
import '../../utils/formatters.dart';
import '../../widgets/app_background.dart';
import '../../widgets/section_header.dart';
import 'widgets/home_header.dart';
import 'widgets/home_recent_list.dart';
import 'widgets/home_shortcuts.dart';
import 'widgets/home_tonight_card.dart';
import 'widgets/home_tonight_cta.dart';
/// v7 今晚：头部、唯一金色 CTA、今夜推荐、最近播放、三入口。
class HomeTab extends StatefulWidget {
  const HomeTab({
    super.key,
    required this.onOpenReport,
    required this.onOpenSound,
  });
  final VoidCallback onOpenReport;
  final VoidCallback onOpenSound;
  @override
  State<HomeTab> createState() => _HomeTabState();
}
class _HomeTabState extends State<HomeTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      context.read<SoundProvider>().loadLocal();
      context.read<SleepProvider>().ensureLoaded();
    });
  }
  Future<void> _refresh() async {
    final SoundProvider sound = context.read<SoundProvider>();
    final SleepProvider sleep = context.read<SleepProvider>();
    await Future.wait<void>(<Future<void>>[
      sound.loadLocal(),
      sleep.load(),
    ]);
  }
  Future<void> _openPlayer(AudioItem item) async {
    await Navigator.pushNamed<bool?>(
      context,
      AppRoutes.player,
      arguments: item,
    );
    if (!mounted) {
      return;
    }
    await context.read<SoundProvider>().loadLocal();
  }
  Future<void> _openSession(SleepSession session) async {
    final bool? saved = await Navigator.pushNamed<bool>(
      context,
      AppRoutes.sleepLogForm,
      arguments: session,
    );
    if (!mounted || saved != true) {
      return;
    }
    await context.read<SleepProvider>().load();
  }
  String _meta(SleepProvider sleep) {
    if (sleep.recent.isEmpty) {
      return '今晚，从第一晚开始';
    }
    final SleepSession session = sleep.recent.first;
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime day = DateTime(
      session.bedTime.year,
      session.bedTime.month,
      session.bedTime.day,
    );
    final int diff = today.difference(day).inDays;
    final String label = diff == 0
        ? '今天'
        : diff == 1
            ? '昨晚'
            : formatMonthDay(day).replaceAll(' ', '');
    return '$label ${formatClock(session.bedTime)} · '
        '${_compactDuration(session.durationMin)} · '
        '连续 ${sleep.weekStats.streakDays} 天';
  }
  String _compactDuration(int minutes) {
    final int hours = minutes ~/ 60;
    final int rest = minutes % 60;
    if (hours == 0) {
      return '${rest}m';
    }
    return rest == 0 ? '${hours}h' : '${hours}h${rest}m';
  }
  @override
  Widget build(BuildContext context) {
    final AuthProvider auth = context.watch<AuthProvider>();
    final SoundProvider sound = context.watch<SoundProvider>();
    final SleepProvider sleep = context.watch<SleepProvider>();
    final AudioItem? tonight =
        sound.localAudios.isEmpty ? null : sound.localAudios.first;
    final List<SleepSession> recent =
        sleep.recent.take(2).toList(growable: false);
    return AppBackground(
      tint: context.c.tintTonight,
      child: SafeArea(
        child: RefreshIndicator(
          color: context.c.secondary,
          backgroundColor: context.c.cover,
          onRefresh: _refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.page,
              AppSpacing.page,
              AppSpacing.page,
              AppSpacing.xxxl,
            ),
            children: <Widget>[
              HomeHeader(nickname: auth.nickname, meta: _meta(sleep)),
              const SizedBox(height: AppSpacing.xxl),
              HomeTonightCta(
                onTap: () => Navigator.pushNamed(context, AppRoutes.breathing),
              ),
              SectionHeader(
                title: '今夜推荐',
                actionLabel: '查看全部',
                onAction: widget.onOpenSound,
              ),
              TonightCard(
                item: tonight,
                isLoading: sound.isLoadingLocal,
                error: sound.errorLocal,
                onRetry: () => sound.loadLocal(),
                onPlay: _openPlayer,
              ),
              if (recent.isNotEmpty) ...<Widget>[
                SectionHeader(
                  title: '最近播放',
                  actionLabel: '全部',
                  onAction: widget.onOpenReport,
                ),
                HomeRecentList(
                  sessions: recent,
                  audios: sound.localAudios,
                  onOpenAudio: _openPlayer,
                  onOpenSession: _openSession,
                ),
              ],
              const SizedBox(height: AppSpacing.xxl),
              HomeShortcuts(onOpenReport: widget.onOpenReport),
            ],
          ),
        ),
      ),
    );
  }
}
