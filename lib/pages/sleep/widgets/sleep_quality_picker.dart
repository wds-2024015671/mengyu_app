import 'package:mengyu_app/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// 睡眠评分 1–5：五颗星，点哪颗就选几分。
class SleepQualityPicker extends StatelessWidget {
  const SleepQualityPicker({
    super.key,
    required this.quality,
    required this.onChanged,
  });

  final int quality;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            for (int i = 1; i <= 5; i++)
              Expanded(
                child: _Star(
                  filled: i <= quality,
                  onTap: () => onChanged(i),
                  label: '$i 分',
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text('$quality / 5', style: context.s.captionMuted),
      ],
    );
  }
}

class _Star extends StatelessWidget {
  const _Star({
    required this.filled,
    required this.onTap,
    required this.label,
  });

  final bool filled;
  final VoidCallback onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: filled,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.chip),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Icon(
            filled ? Icons.star_rounded : Icons.star_border_rounded,
            size: 24,
            color: filled ? context.c.secondary : context.c.textTertiary,
          ),
        ),
      ),
    );
  }
}
