import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_tokens.dart';
import '../../models/audio_item.dart';
import '../../models/private_media.dart';
import '../../providers/demo_visibility_provider.dart';
import '../../providers/private_media_provider.dart';
import '../../providers/sound_provider.dart';
import '../../widgets/app_background.dart';
import '../../widgets/section_header.dart';
import '../player/video_player_page.dart';
import '../sound/all_media_page.dart';
import 'widgets/private_import_launcher.dart';
import 'widgets/sound_header.dart';
import 'widgets/sound_catalog.dart';
import 'widgets/sound_list_entry.dart';
import 'widgets/sound_list_frame.dart';
import 'widgets/sound_search_field.dart';
import 'widgets/video_group.dart';
/// v9 声屿：私人库入口 + 单滚动声音列表 + 视频大框。
class SoundTab extends StatefulWidget {
  const SoundTab({super.key, this.active = true});
  final bool active;
  @override
  State<SoundTab> createState() => _SoundTabState();
}
class _SoundTabState extends State<SoundTab> {
  final TextEditingController _search = TextEditingController();
  final ScrollController _scroll = ScrollController();
  Timer? _debounce;
  String _query = '';
  @override
  void initState() {
    super.initState();
    if (widget.active) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
    }
  }
  @override
  void didUpdateWidget(covariant SoundTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.active && widget.active) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
    }
  }
  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    _scroll.dispose();
    super.dispose();
  }
  void _bootstrap() {
    if (!mounted) {
      return;
    }
    final SoundProvider sound = context.read<SoundProvider>();
    if (sound.localAudios.isEmpty) {
      sound.loadLocal();
    }
    context.read<PrivateMediaProvider>().ensureLoaded();
    context.read<DemoVisibilityProvider>().ensureLoaded();
  }
  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() => _query = value.trim().toLowerCase());
      }
    });
  }
  Future<void> _openPlayer(AudioItem item) async {
    await Navigator.pushNamed<bool?>(
      context,
      AppRoutes.player,
      arguments: item,
    );
  }
  Future<void> _openImport() async {
    final bool imported = await showPrivateImportSheet(context);
    if (!mounted || !imported) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已加入私人库')),
    );
  }
  Future<void> _openAll(PrivateMediaType type) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext pageContext) => AllMediaPage(type: type),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final SoundProvider sound = context.watch<SoundProvider>();
    final PrivateMediaProvider private =
        context.watch<PrivateMediaProvider>();
    final DemoVisibilityProvider visibility =
        context.watch<DemoVisibilityProvider>();
    final List<SoundListEntry> sounds = buildSoundEntries(
      sound: sound,
      private: private,
      query: _query,
      hiddenDemoKeys: visibility.hidden,
    ).take(6).toList(growable: false);
    final List<VideoEntry> videos = buildVideoEntries(
      private: private,
      query: _query,
      hiddenDemoKeys: visibility.hidden,
    ).take(6).toList(growable: false);
    return AppBackground(
      tint: context.c.tintSound,
      child: SafeArea(
        bottom: false,
        child: ListView(
          controller: _scroll,
          padding: const EdgeInsets.only(bottom: 100),
          children: <Widget>[
            SoundHeader(onAdd: _openImport),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                AppSpacing.md,
                AppSpacing.page,
                0,
              ),
              child: SoundSearchField(
                controller: _search,
                onChanged: _onQueryChanged,
              ),
            ),
            KeyedSubtree(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    SectionHeader(
                      title: '全部声音',
                      actionLabel: '更多',
                      onAction: () => _openAll(PrivateMediaType.audio),
                      padding: const EdgeInsets.only(
                        top: AppSpacing.section,
                        bottom: AppSpacing.sm,
                      ),
                    ),
                    if (sounds.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                        child: Text('没有找到相关声音', style: context.s.micro),
                      )
                    else
                      SoundListFrame(entries: sounds, onOpen: (entry) => _openPlayer(entry.item)),
                  ],
                ),
              ),
            ),
            KeyedSubtree(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    SectionHeader(
                      title: '全部视频',
                      actionLabel: '更多',
                      onAction: () => _openAll(PrivateMediaType.video),
                      padding: const EdgeInsets.only(
                        top: AppSpacing.section,
                        bottom: AppSpacing.sm,
                      ),
                    ),
                    if (videos.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                        child: Text('没有找到相关视频', style: context.s.micro),
                      )
                    else
                      VideoGroup(
                        videos: videos,
                        onOpen: (video) => openVideoPlayer(context, video),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
