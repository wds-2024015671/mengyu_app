import 'package:flutter/material.dart';

import '../../../models/audio_item.dart';
import '../../../models/private_media.dart';
import '../../../providers/private_media_provider.dart';
import '../../../providers/sound_provider.dart';
import 'sound_list_entry.dart';

/// 声屿的纯数据拼装：6 条演示声音 + 私人库音频；视频独立于分类过滤。
List<SoundListEntry> buildSoundEntries({
  required SoundProvider sound,
  required PrivateMediaProvider private,
  required String query,
}) {
  final List<SoundListEntry> entries = <SoundListEntry>[];
  for (final SoundDemo demo in kSoundDemos) {
    entries.add(
      SoundListEntry(
        item: _audioFor(demo, sound.localAudios),
        title: demo.title,
        category: demo.category,
        durationLabel: demo.durationLabel,
        icon: demo.icon,
      ),
    );
  }
  for (final PrivateMedia media in private.audios) {
    entries.add(
      SoundListEntry(
        item: media.toAudioItem(),
        title: media.title,
        category: media.platform,
        durationLabel: formatMediaDuration(media.durationMs),
        icon: Icons.library_music_outlined,
        privateMedia: media,
      ),
    );
  }
  return entries.where((SoundListEntry entry) {
    if (query.isNotEmpty &&
        !'${entry.title} ${entry.category}'.toLowerCase().contains(query)) {
      return false;
    }
    return true;
  }).toList(growable: false);
}
List<VideoEntry> buildVideoEntries({
  required PrivateMediaProvider private,
  required String query,
}) {
  final List<VideoEntry> videos = <VideoEntry>[
    ...kVideoDemos,
    for (final PrivateMedia media in private.videos)
      VideoEntry(
        title: media.title,
        platform: media.platform,
        durationLabel: formatMediaDuration(media.durationMs),
        privateMedia: media,
      ),
  ];
  if (query.isEmpty) {
    return videos;
  }
  return videos
      .where(
        (VideoEntry video) =>
            '${video.title} ${video.platform}'.toLowerCase().contains(query),
      )
      .toList(growable: false);
}

AudioItem _audioFor(SoundDemo demo, List<AudioItem> loaded) {
  for (final AudioItem item in loaded) {
    if (item.id == demo.id) {
      return item.copyWith(title: demo.title, category: demo.category);
    }
  }
  return AudioItem.builtIn(
    id: demo.id,
    title: demo.title,
    category: demo.category,
    assetPath: demo.assetPath,
  );
}
