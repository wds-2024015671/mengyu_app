import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/private_media.dart';
import '../all_media_item.dart';
import 'all_audio_list.dart';
import 'all_media_empty.dart';
import 'all_video_grid.dart';

class AllMediaContent extends StatelessWidget {
  const AllMediaContent({
    super.key,
    required this.type,
    required this.items,
    required this.selectionMode,
    required this.selectedKeys,
    required this.onTap,
    required this.error,
    required this.onAdd,
    required this.onRetry,
  });

  final PrivateMediaType type;
  final List<AllMediaItem> items;
  final bool selectionMode;
  final Set<String> selectedKeys;
  final ValueChanged<AllMediaItem> onTap;
  final String error;
  final VoidCallback onAdd;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return AllMediaEmpty(
        type: type,
        error: error,
        onAdd: onAdd,
        onRetry: onRetry,
      );
    }
    return ListView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.section,
        AppSpacing.page,
        selectionMode ? AppSpacing.md : AppSpacing.section,
      ),
      children: <Widget>[
        if (type == PrivateMediaType.audio)
          AllAudioList(
            items: items,
            selectionMode: selectionMode,
            selectedKeys: selectedKeys,
            onTap: onTap,
          )
        else
          AllVideoGrid(
            items: items,
            selectionMode: selectionMode,
            selectedKeys: selectedKeys,
            onTap: onTap,
          ),
      ],
    );
  }
}
