import 'package:flutter/material.dart';

Future<void> showBreathingCompletionDialog(BuildContext context, int cycles) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: Text('完成 $cycles 轮呼吸'),
        content: const Text('慢慢睁开眼睛，感受一下身体的变化。'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('完成'),
          ),
        ],
      );
    },
  );
}

Future<bool?> showBreathingExitDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('结束这次呼吸？'),
        content: const Text('未完成的轮次不会计入。'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('继续'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('结束'),
          ),
        ],
      );
    },
  );
}
