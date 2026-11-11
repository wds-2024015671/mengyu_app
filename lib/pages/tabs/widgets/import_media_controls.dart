import 'package:flutter/material.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/private_media.dart';
import '../../../data/services/yt_dlp_service.dart';
class ImportLinkField extends StatelessWidget {
  const ImportLinkField({
    super.key,
    required this.controller,
    required this.onPaste,
    required this.enabled,
  });
  final TextEditingController controller;
  final VoidCallback onPaste;
  final bool enabled;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.control),
        border: Border.all(color: context.c.stroke),
      ),
      child: Row(
        children: <Widget>[
          const SizedBox(width: AppSpacing.md),
          Icon(Icons.link, size: 20, color: context.c.textTertiary),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled,
              style: context.s.body,
              keyboardType: TextInputType.url,
              decoration: InputDecoration(
                hintText: 'https://b23.tv/…',
                hintStyle: context.s.body.copyWith(
                  color: context.c.textTertiary,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          TextButton(
            onPressed: enabled ? onPaste : null,
            child: const Text('粘贴'),
          ),
        ],
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
            color: selected ? context.c.secondary.withOpacity(0.55) : context.c.stroke,
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
                      color: selected ? context.c.secondary : context.c.textPrimary,
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
class ImportParsedCard extends StatelessWidget {
  const ImportParsedCard({super.key, required this.media});
  final ParsedMediaInfo media;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.c.fill,
        borderRadius: BorderRadius.circular(AppRadius.control),
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.movie_outlined, size: 20, color: context.c.textSecondary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  media.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.s.body,
                ),
                Text(
                  '${media.platform} · ${media.extension.toUpperCase()}',
                  style: context.s.micro,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
class ImportProgress extends StatelessWidget {
  const ImportProgress({
    super.key,
    required this.progress,
    required this.onCancel,
  });
  final double progress;
  final VoidCallback onCancel;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        LinearProgressIndicator(
          value: progress > 0 ? progress : null,
          color: context.c.secondary,
          backgroundColor: context.c.stroke,
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: <Widget>[
            Text(
              progress > 0 ? '下载中 ${(progress * 100).round()}%' : '准备下载…',
              style: context.s.caption,
            ),
            const Spacer(),
            TextButton(onPressed: onCancel, child: const Text('取消')),
          ],
        ),
      ],
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
