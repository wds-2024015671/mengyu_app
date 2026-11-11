import 'package:flutter/material.dart';

import '../../models/sleep_session.dart';
import '../../providers/sleep_provider.dart';
import 'widgets/sleep_conflict_dialog.dart';

enum SleepSaveOutcome { saved, cancelled, failed }

class SleepSaveResult {
  const SleepSaveResult(this.outcome, [this.error]);

  final SleepSaveOutcome outcome;
  final String? error;
}

/// 补记保存：同日/时间重叠时交由用户选择合并、覆盖或取消。
Future<SleepSaveResult> saveSleepSession({
  required BuildContext context,
  required SleepProvider provider,
  required SleepSession session,
  required bool isNew,
  VoidCallback? onCommit,
}) async {
  final List<SleepSession> conflicts = isNew
      ? provider.sessions.where((SleepSession existing) {
          if (existing.id == session.id) {
            return false;
          }
          final bool sameDay = existing.date == session.date;
          final bool overlaps = existing.bedTime.isBefore(session.wakeTime) &&
              session.bedTime.isBefore(existing.wakeTime);
          return sameDay || overlaps;
        }).toList(growable: false)
      : const <SleepSession>[];

  if (conflicts.isNotEmpty) {
    final SleepConflictAction? action = await showSleepConflictDialog(
      context,
      count: conflicts.length,
    );
    if (!context.mounted || action == null || action == SleepConflictAction.cancel) {
      return const SleepSaveResult(SleepSaveOutcome.cancelled);
    }

    if (action == SleepConflictAction.merge) {
      onCommit?.call();
      final SleepSession first = conflicts.first;
      DateTime bed = first.bedTime;
      DateTime wake = first.wakeTime;
      if (session.bedTime.isBefore(bed)) {
        bed = session.bedTime;
      }
      if (session.wakeTime.isAfter(wake)) {
        wake = session.wakeTime;
      }
      final SleepSession merged = SleepSession(
        id: first.id,
        bedTime: bed,
        wakeTime: wake,
        quality: session.quality,
        note: session.note.isEmpty ? first.note : session.note,
      );
      if (!await provider.save(merged)) {
        return SleepSaveResult(
          SleepSaveOutcome.failed,
          provider.error ?? '合并失败，请稍后再试',
        );
      }
      for (final SleepSession item in conflicts.skip(1)) {
        if (item.id != null && !await provider.delete(item.id!)) {
          return SleepSaveResult(
            SleepSaveOutcome.failed,
            provider.error ?? '合并后清理旧记录失败',
          );
        }
      }
      return const SleepSaveResult(SleepSaveOutcome.saved);
    }

    for (final SleepSession item in conflicts) {
      if (item.id != null && !await provider.delete(item.id!)) {
        return SleepSaveResult(
          SleepSaveOutcome.failed,
          provider.error ?? '覆盖前删除旧记录失败',
        );
      }
    }
  }

  onCommit?.call();
  if (!await provider.save(session)) {
    return SleepSaveResult(
      SleepSaveOutcome.failed,
      provider.error ?? '保存失败，请稍后再试',
    );
  }
  return const SleepSaveResult(SleepSaveOutcome.saved);
}
