import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../models/private_media.dart';

class AllMediaEmpty extends StatelessWidget {
  const AllMediaEmpty({
    super.key,
    required this.type,
    required this.error,
    required this.onAdd,
    required this.onRetry,
  });

  final PrivateMediaType type;
  final String error;
  final VoidCallback onAdd;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final bool hasError = error.isNotEmpty;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              type == PrivateMediaType.audio ? '还没有音频' : '还没有视频',
              style: context.s.title,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              hasError ? error : '从手机里添加一段，留在自己的岛上。',
              textAlign: TextAlign.center,
              style: context.s.captionMuted,
            ),
            const SizedBox(height: AppSpacing.md),
            TextButton(
              onPressed: hasError ? onRetry : onAdd,
              child: Text(hasError ? '重试' : '去添加'),
            ),
          ],
        ),
      ),
    );
  }
}
