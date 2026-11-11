import 'package:mengyu_app/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../models/audio_item.dart';

/// 播放器 / 声屿共用的 Hero tag。
String audioCoverTag(String id) => 'audio_cover_$id';

/// v7 音频封面：cover 底色 + 14 圆角 + 20 t2 图标，不使用渐变。
class AudioCover extends StatelessWidget {
  const AudioCover({
    super.key,
    required this.item,
    this.width,
    this.height,
    this.radius = AppRadius.control,
    this.iconSize = 20,
  });

  final AudioItem item;
  final double? width;
  final double? height;
  final double radius;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final bool isRemote = item.sourceType == AudioSourceType.remote;
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: context.c.cover,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Icon(
        isRemote ? Icons.cloud_outlined : Icons.graphic_eq,
        size: iconSize,
        color: context.c.textSecondary,
      ),
    );
  }
}
