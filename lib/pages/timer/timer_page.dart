import 'package:mengyu_app/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_settings.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/app_background.dart';
import '../../widgets/custom_minutes_dialog.dart';
import '../../widgets/primary_button.dart';

/// 定时关闭：5/10/15/20 分钟快捷项 + 自定义 1–180 分钟。
class TimerPage extends StatefulWidget {
  const TimerPage({super.key, this.initialMinutes});

  /// 播放器当前剩余的分钟数；非法时回退到默认 10 分钟。
  final int? initialMinutes;

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  late int _minutes;

  @override
  void initState() {
    super.initState();
    final int? initial = widget.initialMinutes;
    _minutes = initial != null && isValidTimerMinutes(initial)
        ? initial
        : kDefaultTimerMinutes;
  }

  Future<void> _pickCustom() async {
    final int? value = await showCustomMinutesDialog(
      context,
      initialMinutes: _minutes,
    );
    if (mounted && value != null) {
      setState(() => _minutes = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.c.bgDeep,
      appBar: AppBar(title: const Text('定时关闭')),
      body: AppBackground(
        tint: context.c.tintReport,
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.page,
              AppSpacing.xl,
              AppSpacing.page,
              AppSpacing.xxl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  '让声音在你睡着后停下。',
                  textAlign: TextAlign.center,
                  style: context.s.bodySecondary,
                ),
                const SizedBox(height: AppSpacing.xxl),
                _TimerDial(minutes: _minutes),
                const SizedBox(height: AppSpacing.xxl),
                _TimerOptions(
                  selected: _minutes,
                  onSelect: (int value) => setState(() => _minutes = value),
                  onCustom: _pickCustom,
                ),
                const SizedBox(height: AppSpacing.xxl),
                PrimaryButton(
                  label: '开始计时',
                  onPressed: () => Navigator.pop(context, _minutes),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  '到点后自动暂停，并记录一次声音仪式。',
                  textAlign: TextAlign.center,
                  style: context.s.captionMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TimerDial extends StatelessWidget {
  const _TimerDial({required this.minutes});

  final int minutes;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 200,
        height: 200,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            SizedBox(
              width: 200,
              height: 200,
              child: CircularProgressIndicator(
                value: (minutes / kMaxTimerMinutes).clamp(0.0, 1.0),
                strokeWidth: 3,
                color: context.c.secondary,
                backgroundColor: context.c.stroke,
              ),
            ),
            Container(
              width: 164,
              height: 164,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.c.fill,
                border: Border.all(color: context.c.stroke),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('$minutes', style: context.s.display),
                  const SizedBox(height: AppSpacing.xs),
                  Text('分钟', style: context.s.captionMuted),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimerOptions extends StatelessWidget {
  const _TimerOptions({
    required this.selected,
    required this.onSelect,
    required this.onCustom,
  });

  final int selected;
  final ValueChanged<int> onSelect;
  final VoidCallback onCustom;

  @override
  Widget build(BuildContext context) {
    final bool custom = !kTimerOptions.contains(selected);
    return Row(
      children: <Widget>[
        for (int i = 0; i < kTimerOptions.length; i++) ...<Widget>[
          if (i > 0) const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _TimerOption(
              label: '${kTimerOptions[i]} 分',
              selected: kTimerOptions[i] == selected,
              onTap: () => onSelect(kTimerOptions[i]),
            ),
          ),
        ],
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _TimerOption(
            label: '自定义',
            selected: custom,
            onTap: onCustom,
          ),
        ),
      ],
    );
  }
}

class _TimerOption extends StatelessWidget {
  const _TimerOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(AppRadius.control);
    return Material(
      color: selected
          ? context.c.secondary.withOpacity(0.12)
          : Colors.transparent,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Container(
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: radius,
            border: selected ? null : Border.all(color: context.c.stroke),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: context.s.body.copyWith(
              color: selected ? context.c.secondary : context.c.textSecondary,
              fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}
