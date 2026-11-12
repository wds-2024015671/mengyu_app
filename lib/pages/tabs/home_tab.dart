import 'package:mengyu_app/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../models/audio_item.dart';
import '../../providers/auth_provider.dart';
import '../../providers/demo_visibility_provider.dart';
import '../../providers/private_media_provider.dart';
import '../../providers/sound_provider.dart';
import '../../widgets/app_background.dart';
import '../../widgets/section_header.dart';
import 'widgets/home_header.dart';
import 'widgets/home_shortcuts.dart';
import 'widgets/home_tonight_card.dart';
import 'widgets/home_tonight_cta.dart';
import 'widgets/sleep_tips_card.dart';
import 'widgets/sound_catalog.dart';
import 'widgets/sound_list_entry.dart';
import '../player/video_player_page.dart';
/// v7 今晚：头部、唯一金色 CTA、双行今夜推荐、三入口。
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
      context.read<PrivateMediaProvider>().ensureLoaded();
      context.read<DemoVisibilityProvider>().ensureLoaded();
    });
  }
  Future<void> _refresh() async {
    final SoundProvider sound = context.read<SoundProvider>();
    final PrivateMediaProvider private =
        context.read<PrivateMediaProvider>();
    await sound.loadLocal();
    await private.ensureLoaded();
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
  Future<void> _openVideo(VideoEntry video) async {
    await openVideoPlayer(context, video);
  }
  @override
  Widget build(BuildContext context) {
    final AuthProvider auth = context.watch<AuthProvider>();
    final SoundProvider sound = context.watch<SoundProvider>();
    final PrivateMediaProvider private =
        context.watch<PrivateMediaProvider>();
    final DemoVisibilityProvider visibility =
        context.watch<DemoVisibilityProvider>();
    final List<SoundListEntry> sounds = buildSoundEntries(
      sound: sound,
      private: private,
      query: '',
      hiddenDemoKeys: visibility.hidden,
    );
    final List<VideoEntry> videos = buildVideoEntries(
      private: private,
      query: '',
      hiddenDemoKeys: visibility.hidden,
    );
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
              HomeHeader(nickname: auth.nickname),
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
                video: videos.isEmpty ? null : videos.first,
                audio: sounds.isEmpty ? null : sounds.first.item,
                onPlayVideo: _openVideo,
                onPlayAudio: _openPlayer,
              ),
              const SizedBox(height: AppSpacing.xxl),
              HomeShortcuts(onOpenReport: widget.onOpenReport),
              const SizedBox(height: AppSpacing.xxl),
              const SleepTipsCard(),
            ],
          ),
        ),
      ),
    );
  }
}
