import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/private_media.dart';

class ImportFileCard extends StatelessWidget {
  const ImportFileCard({
    super.key,
    required this.file,
    required this.type,
    required this.onPick,
    required this.enabled,
  });

  final File? file;
  final PrivateMediaType type;
  final VoidCallback onPick;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final String label = type == PrivateMediaType.audio ? '本地音频' : '本地视频';
    return InkWell(
      onTap: enabled ? onPick : null,
      borderRadius: BorderRadius.circular(AppRadius.control),
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.control),
          border: Border.all(color: context.c.stroke),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: context.c.cover,
                borderRadius: BorderRadius.circular(AppRadius.control),
              ),
              child: Icon(
                type == PrivateMediaType.audio
                    ? Icons.audiotrack_outlined
                    : Icons.video_file_outlined,
                size: 20,
                color: context.c.textSecondary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    file == null ? '选择$label' : file!.uri.pathSegments.last,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.s.body,
                  ),
                  Text(
                    file == null ? '从手机文件中选取' : '点击重新选择',
                    style: context.s.micro,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.folder_open_outlined,
              size: 18,
              color: context.c.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class ImportFormatSelector extends StatelessWidget {
  const ImportFormatSelector({
    super.key,
    required this.type,
    required this.onChanged,
    required this.enabled,
  });

  final PrivateMediaType type;
  final ValueChanged<PrivateMediaType> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _FormatOption(
            title: '仅音频',
            subtitle: 'M4A · 更小',
            selected: type == PrivateMediaType.audio,
            enabled: enabled,
            onTap: () => onChanged(PrivateMediaType.audio),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _FormatOption(
            title: '视频',
            subtitle: 'MP4 · 原画',
            selected: type == PrivateMediaType.video,
            enabled: enabled,
            onTap: () => onChanged(PrivateMediaType.video),
          ),
        ),
      ],
    );
  }
}

class _FormatOption extends StatelessWidget {
  const _FormatOption({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(AppRadius.control),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.control),
          border: Border.all(
            color:
                selected ? context.c.secondary.withOpacity(0.55) : context.c.stroke,
          ),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: context.s.body.copyWith(
                      color:
                          selected ? context.c.secondary : context.c.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(subtitle, style: context.s.micro),
                ],
              ),
            ),
            if (selected)
              Icon(Icons.check, size: 16, color: context.c.secondary),
          ],
        ),
      ),
    );
  }
}

class ImportErrorBox extends StatelessWidget {
  const ImportErrorBox({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Text(
            message,
            style: context.s.caption.copyWith(color: context.c.danger),
          ),
        ),
        TextButton(onPressed: onRetry, child: const Text('重试')),
      ],
    );
  }
}
