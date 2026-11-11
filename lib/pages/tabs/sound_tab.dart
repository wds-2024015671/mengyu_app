import 'package:mengyu_app/core/theme/app_tokens.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../models/audio_item.dart';
import '../../providers/favorite_provider.dart';
import '../../providers/sound_provider.dart';
import '../../widgets/app_background.dart';
import '../../widgets/section_header.dart';
import 'widgets/sound_empty.dart';
import 'widgets/sound_grid.dart';
import 'widgets/sound_header.dart';
import 'widgets/sound_search_field.dart';
import 'widgets/sound_segment_switch.dart';

/// v7 声屿：搜索 + ASMR/Nature/Other 分段 + 2×3 本地声音网格。
class SoundTab extends StatefulWidget {
  const SoundTab({super.key, this.active = true});

  /// MainShell 只在切换到声屿时才让这里发请求。
  final bool active;

  @override
  State<SoundTab> createState() => _SoundTabState();
}

class _SoundTabState extends State<SoundTab> {
  static const Set<String> _natureIds = <String>{
    'local_ocean',
    'local_stream',
    'local_wind',
  };

  final TextEditingController _search = TextEditingController();

  Timer? _debounce;
  int _segment = 0;
  bool _onlyFavorites = false;
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
    context.read<FavoriteProvider>().ensureLoaded();
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) {
        return;
      }
      setState(() => _query = value.trim().toLowerCase());
    });
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
    await context.read<FavoriteProvider>().reload();
  }

  bool _inSegment(AudioItem item) {
    if (_segment == 0) {
      return true;
    }
    if (_segment == 1) {
      return _natureIds.contains(item.id);
    }
    return item.id == 'local_noise';
  }

  List<AudioItem> _filtered(
    List<AudioItem> all,
    FavoriteProvider favorites,
  ) {
    return all.where((AudioItem item) {
      if (!_inSegment(item)) {
        return false;
      }
      if (_onlyFavorites && !favorites.isFavorite(item.id)) {
        return false;
      }
      if (_query.isNotEmpty) {
        final String haystack =
            '${item.title} ${item.category}'.toLowerCase();
        if (!haystack.contains(_query)) {
          return false;
        }
      }
      return true;
    }).toList(growable: false);
  }

  String _title(int count) {
    final String base = switch (_segment) {
      0 => '全部声音',
      1 => 'Nature',
      _ => 'Other',
    };
    return '$base · $count';
  }

  @override
  Widget build(BuildContext context) {
    final SoundProvider sound = context.watch<SoundProvider>();
    final FavoriteProvider favorites = context.watch<FavoriteProvider>();
    final List<AudioItem> items = _filtered(sound.localAudios, favorites);

    return AppBackground(
      tint: context.c.tintSound,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SoundHeader(
              onlyFavorites: _onlyFavorites,
              onToggleFavorites: () {
                setState(() => _onlyFavorites = !_onlyFavorites);
              },
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                AppSpacing.lg,
                AppSpacing.page,
                0,
              ),
              child: SoundSearchField(
                controller: _search,
                onChanged: _onQueryChanged,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                AppSpacing.md,
                AppSpacing.page,
                0,
              ),
              child: SoundSegmentSwitch(
                index: _segment,
                onChanged: (int value) => setState(() => _segment = value),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
              child: SectionHeader(
                title: _title(items.length),
                padding: const EdgeInsets.only(
                  top: AppSpacing.xxl,
                  bottom: 0,
                ),
              ),
            ),
            Expanded(child: _buildBody(sound, items, favorites)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
    SoundProvider sound,
    List<AudioItem> items,
    FavoriteProvider favorites,
  ) {
    if (sound.localAudios.isEmpty) {
      if (sound.isLoadingLocal) {
        return Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: context.c.secondary,
          ),
        );
      }
      if (sound.errorLocal != null) {
        return SoundEmpty(
          icon: Icons.cloud_off_outlined,
          message: '声屿加载失败，稍后再试',
          actionLabel: '重试',
          onAction: () => sound.loadLocal(),
        );
      }
      return const SoundEmpty(
        icon: Icons.graphic_eq,
        message: '音景还没到岛上',
      );
    }

    if (items.isEmpty) {
      return SoundEmpty(
        icon: _onlyFavorites ? Icons.favorite_border : Icons.search_off,
        message: _onlyFavorites ? '还没有收藏' : '没有找到声音',
      );
    }

    return SoundGrid(
      items: items,
      favorites: favorites,
      onOpen: _openPlayer,
      onToggleFavorite: (AudioItem item) {
        context.read<FavoriteProvider>().toggle(item.id);
      },
    );
  }
}
