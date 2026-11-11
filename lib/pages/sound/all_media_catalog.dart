import 'package:flutter/material.dart';

import '../../providers/private_media_provider.dart';
import '../../providers/sound_provider.dart';
import '../tabs/widgets/sound_catalog.dart';
import '../tabs/widgets/sound_list_entry.dart';
import 'all_media_item.dart';

List<AllMediaItem> buildAllAudioItems({
  required SoundProvider sound,
  required PrivateMediaProvider private,
  required Set<String> hiddenDemoKeys,
}) {
  final List<SoundListEntry> entries = buildSoundEntries(
    sound: sound,
    private: private,
    query: '',
    hiddenDemoKeys: hiddenDemoKeys,
  );
  return entries
      .map(
        (SoundListEntry entry) => AllMediaItem(
          key: entry.key,
          title: entry.title,
          durationLabel: entry.durationLabel,
          icon: entry.icon,
          audio: entry.item,
          privateMedia: entry.privateMedia,
        ),
      )
      .toList(growable: false);
}

List<AllMediaItem> buildAllVideoItems({
  required PrivateMediaProvider private,
  required Set<String> hiddenDemoKeys,
}) {
  final List<VideoEntry> entries = buildVideoEntries(
    private: private,
    query: '',
    hiddenDemoKeys: hiddenDemoKeys,
  );
  return entries
      .map(
        (VideoEntry video) => AllMediaItem(
          key: video.key,
          title: video.title,
          durationLabel: video.durationLabel,
          icon: video.isPrivate
              ? Icons.video_file_outlined
              : Icons.play_circle_outline,
          video: video,
          privateMedia: video.privateMedia,
        ),
      )
      .toList(growable: false);
}
