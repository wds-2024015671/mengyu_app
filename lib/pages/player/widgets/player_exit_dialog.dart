import 'package:flutter/material.dart';

import '../../../core/theme/app_tokens.dart';

/// 退出播放页时询问是否开始睡眠记录。
Future<bool?> showSleepRecordingPrompt(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('要开始记录睡眠吗？'),
        content: Text(
          '声音已停止。梦屿可以从现在开始计时，明早提醒你确认。',
          style: context.s.bodySecondary,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('不用了'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('开始记录'),
          ),
        ],
      );
    },
  );
}
