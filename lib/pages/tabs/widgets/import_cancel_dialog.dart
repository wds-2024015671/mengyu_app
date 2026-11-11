import 'package:flutter/material.dart';

import '../../../core/theme/app_tokens.dart';

Future<bool> confirmCancelDownload(BuildContext context) async {
  final bool? close = await showDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('正在下载'),
        content: Text(
          '关闭会取消本次下载并删除临时文件。',
          style: context.s.bodySecondary,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('继续下载'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('取消并关闭'),
          ),
        ],
      );
    },
  );
  return close ?? false;
}
