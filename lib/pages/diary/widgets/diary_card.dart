import 'package:mengyu_app/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/diary_entry.dart';
import '../../../widgets/glass_card.dart';

/// 单篇日记卡片：心情、正文摘要、标签与删除菜单；点击进编辑。
class DiaryCard extends StatelessWidget {
  const DiaryCard({
    super.key,
    required this.entry,
    required this.onTap,
    required this.onDelete,
  });

  final DiaryEntry entry;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final String content = entry.content.trim();
    return GlassCard(
      onTap: onTap,
      outlined: true,
      padding: const EdgeInsets.all(AppSpacing.lg),
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _MoodBadge(mood: entry.mood),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  content.isEmpty ? '（无正文）' : content,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: context.s.body,
                ),
                if (entry.tags.isNotEmpty) ...<Widget>[
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.xs,
                    children: <Widget>[
                      for (final String tag in entry.tags.take(3))
                        _TagPill(label: tag),
                      if (entry.tags.length > 3)
                        Text(
                          '+${entry.tags.length - 3}',
                          style: context.s.captionMuted,
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          PopupMenuButton<String>(
            tooltip: '更多操作',
            icon: Icon(Icons.more_horiz, color: context.c.textTertiary),
            onSelected: (String value) {
              if (value == 'delete') {
                onDelete();
              }
            },
            itemBuilder: (BuildContext context) {
              return <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: context.c.danger,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      const Text('删除'),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
    );
  }
}

class _MoodBadge extends StatelessWidget {
  const _MoodBadge({required this.mood});

  final int mood;

  static const List<IconData> _icons = <IconData>[
    Icons.sentiment_very_dissatisfied,
    Icons.sentiment_dissatisfied,
    Icons.sentiment_neutral,
    Icons.sentiment_satisfied,
    Icons.sentiment_very_satisfied,
  ];

  @override
  Widget build(BuildContext context) {
    final int index = mood.clamp(1, 5) - 1;
    return SizedBox(
      width: 20,
      height: 20,
      child: Icon(
        _icons[index],
        size: 16,
        color: context.c.textSecondary,
      ),
    );
  }
}

class _TagPill extends StatelessWidget {
  const _TagPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.chip),
        border: Border.all(color: context.c.stroke),
      ),
      child: Text('#$label', style: context.s.captionMuted),
    );
  }
}
