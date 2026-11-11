import 'package:flutter/material.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/app_theme.dart';
import 'sound_list_entry.dart';

/// 一个外框包住全部声音行；行内不再加卡片/边框。
class SoundListFrame extends StatelessWidget {
  const SoundListFrame({
    super.key,
    required this.entries,
    required this.onOpen,
  });

  final List<SoundListEntry> entries;
  final ValueChanged<SoundListEntry> onOpen;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: context.c.stroke),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: <Widget>[
          for (int i = 0; i < entries.length; i++) ...<Widget>[
            if (i > 0)
              Divider(
                height: 1,
                thickness: 1,
                color: context.c.stroke,
                indent: AppSpacing.md,
                endIndent: AppSpacing.md,
              ),
            _SoundRow(
              entry: entries[i],
              onTap: () => onOpen(entries[i]),
            ),
          ],
        ],
      ),
    );
  }
}

class _SoundRow extends StatelessWidget {
  const _SoundRow({required this.entry, required this.onTap});

  final SoundListEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 56,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: <Widget>[
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: context.c.cover,
                    borderRadius: BorderRadius.circular(AppRadius.control),
                  ),
                  child: Icon(entry.icon, size: 20, color: context.c.textSecondary),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        entry.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.s.body.copyWith(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        entry.category,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.s.micro,
                      ),
                    ],
                  ),
                ),
                Text(entry.durationLabel, style: context.s.micro),
                const SizedBox(width: AppSpacing.sm),
                Icon(Icons.play_arrow, size: 16, color: context.c.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
