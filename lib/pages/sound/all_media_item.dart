import 'package:flutter/material.dart';

import '../../models/audio_item.dart';
import '../../models/private_media.dart';
import '../../pages/tabs/widgets/sound_list_entry.dart';

/// 二级列表统一条目：demo 走内置 asset / 私人库走本地文件。
class AllMediaItem {
  const AllMediaItem({
    required this.key,
    required this.title,
    required this.durationLabel,
    required this.icon,
    this.audio,
    this.video,
    this.privateMedia,
  });

  final String key;
  final String title;
  final String durationLabel;
  final IconData icon;
  final AudioItem? audio;
  final VideoEntry? video;
  final PrivateMedia? privateMedia;

  bool get isDemo => privateMedia == null;
  bool get isAudio => audio != null;
}
