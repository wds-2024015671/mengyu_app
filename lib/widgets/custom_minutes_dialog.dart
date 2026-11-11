import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/constants/app_settings.dart';
import '../core/theme/app_tokens.dart';

/// 自定义分钟数：定时页与默认定时共用。
Future<int?> showCustomMinutesDialog(
  BuildContext context, {
  required int initialMinutes,
}) {
  return showDialog<int>(
    context: context,
    builder: (BuildContext dialogContext) {
      return _CustomMinutesDialog(initialMinutes: initialMinutes);
    },
  );
}

class _CustomMinutesDialog extends StatefulWidget {
  const _CustomMinutesDialog({required this.initialMinutes});

  final int initialMinutes;

  @override
  State<_CustomMinutesDialog> createState() => _CustomMinutesDialogState();
}

class _CustomMinutesDialogState extends State<_CustomMinutesDialog> {
  late final TextEditingController _controller;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialMinutes.toString(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final int? value = int.tryParse(_controller.text.trim());
    if (value == null || !isValidTimerMinutes(value)) {
      setState(() {
        _error = '请输入 $kMinTimerMinutes–$kMaxTimerMinutes 之间的分钟数';
      });
      return;
    }
    Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('自定义定时'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly,
        ],
        onSubmitted: (_) => _submit(),
        style: context.s.body,
        decoration: InputDecoration(
          hintText: '分钟数',
          suffixText: '分钟',
          errorText: _error,
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: _submit,
          child: const Text('确定'),
        ),
      ],
    );
  }
}
