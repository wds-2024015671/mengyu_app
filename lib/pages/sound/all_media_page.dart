import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_tokens.dart';
import '../../models/private_media.dart';
import '../../providers/demo_visibility_provider.dart';
import '../../providers/player_provider.dart';
import '../../providers/private_media_provider.dart';
import '../../providers/sound_provider.dart';
import '../../widgets/app_background.dart';
import '../tabs/widgets/private_import_launcher.dart';
import '../tabs/widgets/video_preview_sheet.dart';
import 'all_media_catalog.dart';
import 'all_media_item.dart';
import 'widgets/all_media_content.dart';
import 'widgets/all_media_delete.dart';
import 'widgets/all_media_header.dart';
import 'widgets/media_batch_bar.dart';
class AllMediaPage extends StatefulWidget {
  const AllMediaPage({super.key, required this.type});
  final PrivateMediaType type;
  @override
  State<AllMediaPage> createState() => _AllMediaPageState();
}
class _AllMediaPageState extends State<AllMediaPage> {
  bool _selectionMode = false;
  bool _deleting = false;
  final Set<String> _selected = <String>{};
  bool get _isAudio => widget.type == PrivateMediaType.audio;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }
  Future<void> _bootstrap() async {
    if (!mounted) {
      return;
    }
    final SoundProvider sound = context.read<SoundProvider>();
    final PrivateMediaProvider private =
        context.read<PrivateMediaProvider>();
    final DemoVisibilityProvider visibility =
        context.read<DemoVisibilityProvider>();
    if (sound.localAudios.isEmpty) {
      await sound.loadLocal();
    }
    await private.ensureLoaded();
    await visibility.ensureLoaded();
  }
  List<AllMediaItem> _items(
    SoundProvider sound,
    PrivateMediaProvider private,
    DemoVisibilityProvider visibility,
  ) {
    if (_isAudio) {
      return buildAllAudioItems(
        sound: sound,
        private: private,
        hiddenDemoKeys: visibility.hidden,
      );
    }
    return buildAllVideoItems(
      private: private,
      hiddenDemoKeys: visibility.hidden,
    );
  }
  void _exitSelection() {
    if (!_selectionMode || _deleting) {
      return;
    }
    setState(() {
      _selectionMode = false;
      _selected.clear();
    });
  }
  void _handleBack() {
    if (_selectionMode) {
      _exitSelection();
    } else {
      Navigator.pop(context);
    }
  }
  void _toggleMode() {
    setState(() {
      _selectionMode = !_selectionMode;
      _selected.clear();
    });
  }
  void _toggleSelected(AllMediaItem item) {
    setState(() {
      if (!_selected.add(item.key)) {
        _selected.remove(item.key);
      }
    });
  }
  void _toggleAll(List<AllMediaItem> items) {
    setState(() {
      if (_selected.length == items.length) {
        _selected.clear();
      } else {
        _selected
          ..clear()
          ..addAll(items.map((AllMediaItem item) => item.key));
      }
    });
  }
  Future<void> _openItem(AllMediaItem item) async {
    if (_selectionMode) {
      _toggleSelected(item);
      return;
    }
    if (_isAudio) {
      await Navigator.pushNamed<bool?>(
        context,
        AppRoutes.player,
        arguments: item.audio,
      );
    } else {
      await showVideoPreviewSheet(context, item.video!);
    }
  }
  Future<void> _delete(
    List<AllMediaItem> items,
    PrivateMediaProvider private,
    DemoVisibilityProvider visibility,
  ) async {
    if (_selected.isEmpty || _deleting) {
      return;
    }
    final List<AllMediaItem> targets = items
        .where((AllMediaItem item) => _selected.contains(item.key))
        .toList(growable: false);
    setState(() => _deleting = true);
    final MediaDeleteOutcome outcome = await confirmAndDeleteMedia(
      context: context,
      targets: targets,
      type: widget.type,
      private: private,
      visibility: visibility,
      player: context.read<PlayerProvider>(),
    );
    if (!mounted) {
      return;
    }
    if (outcome.cancelled) {
      setState(() => _deleting = false);
      return;
    }
    if (outcome.error != null) {
      setState(() => _deleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('删除失败：${outcome.error}')),
      );
      return;
    }
    setState(() {
      _deleting = false;
      _selectionMode = false;
      _selected.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('已删除 ${targets.length} 项')),
    );
  }
  Future<void> _add() async {
    await showPrivateImportSheet(context);
  }
  @override
  Widget build(BuildContext context) {
    final SoundProvider sound = context.watch<SoundProvider>();
    final PrivateMediaProvider private =
        context.watch<PrivateMediaProvider>();
    final DemoVisibilityProvider visibility =
        context.watch<DemoVisibilityProvider>();
    final List<AllMediaItem> items = _items(sound, private, visibility);
    final bool empty = items.isEmpty;
    final String title = _isAudio ? '全部声音' : '全部视频';
    final String countLabel = _selectionMode
        ? '已选 ${_selected.length} / ${items.length}'
        : '共 ${items.length} ${_isAudio ? '段' : '个'}';
    return PopScope(
      canPop: !_selectionMode,
      onPopInvoked: (bool didPop) {
        if (!didPop) {
          _exitSelection();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: AppBackground(
          tint: context.c.tintSound,
          showStars: false,
          child: SafeArea(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.page,
                  ),
                  child: AllMediaHeader(
                    title: title,
                    countLabel: countLabel,
                    selectionMode: _selectionMode,
                    showManage: !empty,
                    onBack: _handleBack,
                    onModeToggle: _toggleMode,
                  ),
                ),
                Expanded(
                  child: AllMediaContent(
                    type: widget.type,
                    items: items,
                    selectionMode: _selectionMode,
                    selectedKeys: _selected,
                    onTap: _openItem,
                    error: private.error ?? '',
                    onAdd: _add,
                    onRetry: () {
                      private.load();
                    },
                  ),
                ),
                if (_selectionMode)
                  MediaBatchBar(
                    selectedCount: _selected.length,
                    total: items.length,
                    allSelected:
                        items.isNotEmpty && _selected.length == items.length,
                    onToggleAll: () => _toggleAll(items),
                    onDelete: _selected.isEmpty
                        ? null
                        : () => _delete(items, private, visibility),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
