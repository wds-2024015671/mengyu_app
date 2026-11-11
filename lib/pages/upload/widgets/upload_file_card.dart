import 'package:mengyu_app/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_limits.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/audio_file_picker.dart';
import '../../../utils/formatters.dart';
import '../../../widgets/glass_card.dart';

/// 选文件区域：未选时整卡可点，选中后展示文件名/大小并允许重选或移除。
class UploadFileCard extends StatelessWidget {
  const UploadFileCard({
    super.key,
    required this.file,
    required this.error,
    required this.enabled,
    required this.onPick,
    required this.onClear,
  });

  final PickedAudioFile? file;
  final String? error;
  final bool enabled;
  final VoidCallback onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final PickedAudioFile? current = file;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        GlassCard(
          onTap: enabled && current == null ? onPick : null,
          outlined: true,
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: current == null
              ? _EmptyFile(onPick: enabled ? onPick : null)
              : _PickedFile(
                  file: current,
                  enabled: enabled,
                  onPick: onPick,
                  onClear: onClear,
                ),
        ),
        if (error != null) ...<Widget>[
          const SizedBox(height: AppSpacing.sm),
          Text(
            error!,
            style: context.s.caption.copyWith(color: context.c.danger),
          ),
        ],
      ],
    );
  }
}

class _EmptyFile extends StatelessWidget {
  const _EmptyFile({required this.onPick});

  final VoidCallback? onPick;

  @override
  Widget build(BuildContext context) {
    const int maxMb = kMaxAudioUploadBytes ~/ (1024 * 1024);
    return Column(
      children: <Widget>[
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: context.c.stroke),
          ),
          child: Icon(
            Icons.add,
            size: 24,
            color: context.c.secondary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text('选择音频文件', style: context.s.subtitle),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'mp3 / wav / ogg / m4a · 不超过 ${maxMb}MB',
          textAlign: TextAlign.center,
          style: context.s.captionMuted,
        ),
      ],
    );
  }
}

class _PickedFile extends StatelessWidget {
  const _PickedFile({
    required this.file,
    required this.enabled,
    required this.onPick,
    required this.onClear,
  });

  final PickedAudioFile file;
  final bool enabled;
  final VoidCallback onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: context.c.cover,
            borderRadius: BorderRadius.circular(AppRadius.control),
          ),
          child: Icon(
            Icons.audiotrack,
            size: 20,
            color: context.c.textSecondary,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                file.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.s.body,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                formatFileSize(file.size),
                style: context.s.captionMuted,
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: enabled ? onPick : null,
          child: const Text('重新选择'),
        ),
        IconButton(
          onPressed: enabled ? onClear : null,
          tooltip: '移除文件',
          icon: Icon(
            Icons.close,
            size: 18,
            color: context.c.textTertiary,
          ),
        ),
      ],
    );
  }
}
