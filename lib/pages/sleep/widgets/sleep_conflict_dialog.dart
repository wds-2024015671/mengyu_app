import 'package:flutter/material.dart';

import '../../../core/theme/app_tokens.dart';

enum SleepConflictAction { cancel, merge, overwrite }

Future<SleepConflictAction?> showSleepConflictDialog(
  BuildContext context, {
  required int count,
}) {
  return showDialog<SleepConflictAction>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('同一天已有睡眠记录'),
        content: Text(
          '这一天已有 $count 条记录。可以合并成一条，或覆盖当天记录。',
          style: context.s.bodySecondary,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, SleepConflictAction.cancel),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, SleepConflictAction.merge),
            child: const Text('合并'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, SleepConflictAction.overwrite),
            child: Text(
              '覆盖',
              style: TextStyle(color: context.c.danger),
            ),
          ),
        ],
      );
    },
  );
}
