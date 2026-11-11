import 'package:flutter/material.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../models/private_media.dart';
import '../../../providers/demo_visibility_provider.dart';
import '../../../providers/player_provider.dart';
import '../../../providers/private_media_provider.dart';
import '../all_media_item.dart';

class MediaDeleteOutcome {
  const MediaDeleteOutcome.cancelled()
      : cancelled = true,
        error = null;
  const MediaDeleteOutcome.success()
      : cancelled = false,
        error = null;
  const MediaDeleteOutcome.failed(this.error)
      : cancelled = false;

  final bool cancelled;
  final String? error;
}

Future<MediaDeleteOutcome> confirmAndDeleteMedia({
  required BuildContext context,
  required List<AllMediaItem> targets,
  required PrivateMediaType type,
  required PrivateMediaProvider private,
  required DemoVisibilityProvider visibility,
  required PlayerProvider player,
}) async {
  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: Text('删除 ${targets.length} 项？'),
        content: Text(
          type == PrivateMediaType.audio
              ? '音频文件与记录将从私人库移除。'
              : '视频文件与记录将从私人库移除。',
          style: context.s.bodySecondary,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: context.c.primary),
            child: const Text('删除'),
          ),
        ],
      );
    },
  );
  if (confirmed != true) {
    return const MediaDeleteOutcome.cancelled();
  }
  final List<int> privateIds = targets
      .where((AllMediaItem item) => !item.isDemo)
      .map((AllMediaItem item) => item.privateMedia!.id)
      .toList(growable: false);
  final List<String> demoKeys = targets
      .where((AllMediaItem item) => item.isDemo)
      .map((AllMediaItem item) => item.key)
      .toList(growable: false);
  final String? currentId = player.current?.id;
  final bool playingDeleted = currentId != null &&
      targets.any((AllMediaItem item) => item.audio?.id == currentId);
  try {
    if (privateIds.isNotEmpty) {
      final int removed = await private.deleteByIds(privateIds);
      if (removed < 0) {
        return MediaDeleteOutcome.failed(private.error ?? '删除失败');
      }
    }
    if (demoKeys.isNotEmpty) {
      await visibility.hide(demoKeys);
    }
    if (playingDeleted) {
      await player.clear();
    }
    return const MediaDeleteOutcome.success();
  } catch (error) {
    return MediaDeleteOutcome.failed(error.toString());
  }
}
