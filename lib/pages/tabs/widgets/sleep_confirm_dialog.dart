import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/sleep_tracking_record.dart';
import '../../../providers/sleep_tracking_provider.dart';
import '../../../utils/formatters.dart';

/// 晨间确认：默认起床时间=现在，可调整；确认 / 丢弃。
Future<bool> showSleepConfirmDialog(
  BuildContext context, {
  required SleepTrackingRecord record,
}) async {
  final bool? confirmed = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      return SleepConfirmDialog(record: record);
    },
  );
  return confirmed ?? false;
}

class SleepConfirmDialog extends StatefulWidget {
  const SleepConfirmDialog({super.key, required this.record});

  final SleepTrackingRecord record;

  @override
  State<SleepConfirmDialog> createState() => _SleepConfirmDialogState();
}

class _SleepConfirmDialogState extends State<SleepConfirmDialog> {
  late DateTime _end;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _end = DateTime.now();
  }

  Future<void> _adjust() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_end),
      helpText: '大概几点起床',
    );
    if (!mounted || picked == null) {
      return;
    }
    DateTime next = DateTime(
      _end.year,
      _end.month,
      _end.day,
      picked.hour,
      picked.minute,
    );
    if (!next.isAfter(widget.record.startAt)) {
      next = next.add(const Duration(days: 1));
    }
    setState(() => _end = next);
  }

  Future<void> _confirm() async {
    if (_saving) {
      return;
    }
    setState(() => _saving = true);
    final bool ok =
        await context.read<SleepTrackingProvider>().confirm(endAt: _end);
    if (!mounted) {
      return;
    }
    if (ok) {
      Navigator.pop(context, true);
      return;
    }
    setState(() => _saving = false);
  }

  Future<void> _discard() async {
    await context.read<SleepTrackingProvider>().discard();
    if (mounted) {
      Navigator.pop(context, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final int minutes = widget.record.durationMinAt(_end);
    return AlertDialog(
      title: const Text('昨晚睡眠待确认'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '${formatClock(widget.record.startAt)} 开始 · '
            '${formatClock(_end)} 结束',
            style: context.s.body,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '大概 ${formatMinutes(minutes)}，可以调整。',
            style: context.s.caption,
          ),
          if (_saving) ...<Widget>[
            const SizedBox(height: AppSpacing.md),
            LinearProgressIndicator(color: context.c.primary),
          ],
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: _saving ? null : _discard,
          child: const Text('丢弃'),
        ),
        TextButton(
          onPressed: _saving ? null : _adjust,
          child: const Text('调整'),
        ),
        TextButton(
          onPressed: _saving ? null : _confirm,
          child: const Text('确认'),
        ),
      ],
    );
  }
}
