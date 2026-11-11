import 'package:mengyu_app/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/audio_item.dart';
import '../../../models/sleep_session.dart';
import '../../../utils/formatters.dart';

/// v7 最近播放：56 高行 + 1px 分隔线，无卡片。
///
/// 数据来自最近睡眠/声音仪式记录；能匹配到本地音景就打开播放器，
/// 否则打开对应睡眠记录。
class HomeRecentList extends StatelessWidget {
  const HomeRecentList({
    super.key,
    required this.sessions,
    required this.audios,
    required this.onOpenAudio,
    required this.onOpenSession,
  });

  final List<SleepSession> sessions;
  final List<AudioItem> audios;
  final ValueChanged<AudioItem> onOpenAudio;
  final ValueChanged<SleepSession> onOpenSession;

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      children: <Widget>[
        for (int i = 0; i < sessions.length; i++) ...<Widget>[
          if (i > 0)
            Divider(height: 1, thickness: 1, color: context.c.stroke),
          _RecentRow(
            session: sessions[i],
            audio: _audioFor(sessions[i]),
            onTap: () {
              final AudioItem? audio = _audioFor(sessions[i]);
              if (audio != null) {
                onOpenAudio(audio);
              } else {
                onOpenSession(sessions[i]);
              }
            },
          ),
        ],
      ],
    );
  }

  AudioItem? _audioFor(SleepSession session) {
    const String prefix = '声音仪式：';
    if (!session.note.startsWith(prefix)) {
      return null;
    }
    final String title = session.note.substring(prefix.length).trim();
    for (final AudioItem item in audios) {
      if (item.title == title) {
        return item;
      }
    }
    return null;
  }
}

class _RecentRow extends StatelessWidget {
  const _RecentRow({
    required this.session,
    required this.audio,
    required this.onTap,
  });

  final SleepSession session;
  final AudioItem? audio;
  final VoidCallback onTap;

  String get _title {
    const String prefix = '声音仪式：';
    if (session.note.startsWith(prefix)) {
      return session.note.substring(prefix.length).trim();
    }
    final String note = session.note.trim();
    return note.isEmpty ? '睡眠记录' : note;
  }

  String get _time {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime day = DateTime(
      session.bedTime.year,
      session.bedTime.month,
      session.bedTime.day,
    );
    final int diff = today.difference(day).inDays;
    final String label = diff == 0
        ? '今天'
        : diff == 1
            ? '昨晚'
            : formatMonthDay(day).replaceAll(' ', '');
    return '$label ${formatClock(session.bedTime)}';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 56,
        child: Row(
          children: <Widget>[
            Icon(
              audio != null ? Icons.graphic_eq : Icons.bedtime_outlined,
              size: 20,
              color: context.c.textSecondary,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                _title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.s.body.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(_time, style: context.s.captionMuted),
            const SizedBox(width: AppSpacing.sm),
            Icon(
              Icons.play_arrow,
              size: 16,
              color: context.c.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
