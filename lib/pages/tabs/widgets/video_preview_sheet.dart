import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/app_theme.dart';
import 'sound_list_entry.dart';

/// 本地视频预览：asset 演示素材与私人库下载文件共用同一个播放器。
Future<void> showVideoPreviewSheet(
  BuildContext context,
  VideoEntry video,
) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext sheetContext) {
      return VideoPreviewSheet(video: video);
    },
  );
}

class VideoPreviewSheet extends StatefulWidget {
  const VideoPreviewSheet({super.key, required this.video});

  final VideoEntry video;

  @override
  State<VideoPreviewSheet> createState() => _VideoPreviewSheetState();
}

class _VideoPreviewSheetState extends State<VideoPreviewSheet> {
  VideoPlayerController? _controller;
  String? _error;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _open();
  }

  Future<void> _open() async {
    final String? path = widget.video.localPath;
    final String? asset = widget.video.assetPath;
    final VideoPlayerController? controller = path != null
        ? VideoPlayerController.file(File(path))
        : asset != null
            ? VideoPlayerController.asset(asset)
            : null;
    if (controller == null) {
      setState(() => _error = '这个视频没有可播放的本地文件');
      return;
    }
    _controller = controller;
    try {
      await controller.initialize();
      await controller.setLooping(true);
      await controller.play();
      if (mounted) {
        setState(() => _ready = true);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = '当前设备暂不支持播放这个视频');
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.9,
      ),
      decoration: BoxDecoration(
        color: context.c.sheet,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.card),
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.page),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(widget.video.title, style: context.s.title),
                ),
                IconButton(
                  tooltip: '关闭',
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: context.c.textSecondary),
                ),
              ],
            ),
            Text(
              '${widget.video.platform} · ${widget.video.durationLabel}',
              style: context.s.caption,
            ),
            const SizedBox(height: AppSpacing.lg),
            _player(context),
          ],
        ),
      ),
    );
  }

  Widget _player(BuildContext context) {
    if (_error != null) {
      return Container(
        height: 180,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: context.c.cover,
          borderRadius: BorderRadius.circular(AppRadius.control),
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Text(
          _error!,
          textAlign: TextAlign.center,
          style: context.s.caption,
        ),
      );
    }
    final VideoPlayerController? controller = _controller;
    if (!_ready || controller == null) {
      return Container(
        height: 180,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: context.c.cover,
          borderRadius: BorderRadius.circular(AppRadius.control),
        ),
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: context.c.secondary,
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.control),
      child: AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            VideoPlayer(controller),
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  setState(() {
                    controller.value.isPlaying
                        ? controller.pause()
                        : controller.play();
                  });
                },
              ),
            ),
            Positioned(
              left: AppSpacing.sm,
              bottom: AppSpacing.sm,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.c.sheet.withOpacity(0.55),
                ),
                child: Icon(
                  controller.value.isPlaying
                      ? Icons.pause
                      : Icons.play_arrow,
                  size: 18,
                  color: context.c.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
