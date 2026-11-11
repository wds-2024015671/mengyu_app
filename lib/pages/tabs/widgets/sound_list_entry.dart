import 'package:flutter/material.dart';

import '../../../models/audio_item.dart';
import '../../../models/private_media.dart';

/// 声屿声音列表的展示行：内置 6 条用演示标题/分类/时长，导入项用真实文件。
class SoundListEntry {
  const SoundListEntry({
    required this.item,
    required this.title,
    required this.category,
    required this.durationLabel,
    required this.icon,
    this.privateMedia,
  });

  final AudioItem item;
  final String title;
  final String category;
  final String durationLabel;
  final IconData icon;
  final PrivateMedia? privateMedia;

  bool get isPrivate => privateMedia != null;
  String get key =>
      isPrivate ? 'private_${privateMedia!.id}' : 'demo_sound_${item.id}';
}

class SoundDemo {
  const SoundDemo(
    this.id,
    this.title,
    this.category,
    this.durationLabel,
    this.icon,
    this.assetPath,
  );

  final String id;
  final String title;
  final String category;
  final String durationLabel;
  final IconData icon;
  final String assetPath;
}

const List<SoundDemo> kSoundDemos = <SoundDemo>[
  SoundDemo('local_rain', '雨落窗台', 'ASMR', '45:00', Icons.grain,
      'audio/rain_loop.wav'),
  SoundDemo('local_fire', '篝火噼啪', 'ASMR', '40:00',
      Icons.local_fire_department_outlined, 'audio/fire_loop.wav'),
  SoundDemo('local_stream', '翻书轻响', 'ASMR', '30:00',
      Icons.menu_book_outlined, 'audio/stream_loop.wav'),
  SoundDemo('local_wind', '夜航低语', 'ASMR', '55:00',
      Icons.nightlight_outlined, 'audio/wind_loop.wav'),
  SoundDemo('local_ocean', '海浪白噪', 'Nature', '50:00', Icons.waves,
      'audio/ocean_loop.wav'),
  SoundDemo('local_noise', '夏夜虫鸣', 'Nature', '35:00',
      Icons.bug_report_outlined, 'audio/noise_loop.wav'),
];

/// 视频区的展示项；demo 无本地文件，导入项有 localPath。
class VideoEntry {
  const VideoEntry({
    required this.id,
    required this.title,
    required this.platform,
    required this.durationLabel,
    this.assetPath,
    this.privateMedia,
  });

  final String id;
  final String title;
  final String platform;
  final String durationLabel;
  final String? assetPath;
  final PrivateMedia? privateMedia;

  bool get isPrivate => privateMedia != null;
  String get key => isPrivate ? 'private_${privateMedia!.id}' : 'demo_video_$id';

  String? get localPath => privateMedia?.localPath;
}

const List<VideoEntry> kVideoDemos = <VideoEntry>[
  VideoEntry(
    id: 'asmr1',
    title: '轻触发音',
    platform: '本地',
    durationLabel: '01:00',
    assetPath: 'assets/videos/asmr1.mp4',
  ),
  VideoEntry(
    id: 'asmr2',
    title: '柔软刷子',
    platform: '本地',
    durationLabel: '01:00',
    assetPath: 'assets/videos/asmr2.mp4',
  ),
  VideoEntry(
    id: 'asmr3',
    title: '近距离敲击',
    platform: '本地',
    durationLabel: '01:00',
    assetPath: 'assets/videos/asmr3.mp4',
  ),
  VideoEntry(
    id: 'asmr4',
    title: '海绵刷触发',
    platform: '本地',
    durationLabel: '01:00',
    assetPath: 'assets/videos/asmr4.mp4',
  ),
  VideoEntry(
    id: 'nature1',
    title: '炉火',
    platform: '本地',
    durationLabel: '01:00',
    assetPath: 'assets/videos/nature1.mp4',
  ),
  VideoEntry(
    id: 'nature2',
    title: '溪流',
    platform: '本地',
    durationLabel: '01:00',
    assetPath: 'assets/videos/nature2.mp4',
  ),
  VideoEntry(
    id: 'nature3',
    title: '风吹草叶',
    platform: '本地',
    durationLabel: '01:00',
    assetPath: 'assets/videos/nature3.mp4',
  ),
  VideoEntry(
    id: 'nature4',
    title: '海浪',
    platform: '本地',
    durationLabel: '01:00',
    assetPath: 'assets/videos/nature4.mp4',
  ),
];

String formatMediaDuration(int milliseconds) {
  if (milliseconds <= 0) {
    return '—';
  }
  final int totalSeconds = milliseconds ~/ 1000;
  final int hours = totalSeconds ~/ 3600;
  final int minutes = (totalSeconds % 3600) ~/ 60;
  final int seconds = totalSeconds % 60;
  if (hours > 0) {
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }
  return '${minutes.toString().padLeft(2, '0')}:'
      '${seconds.toString().padLeft(2, '0')}';
}
