import 'package:mengyu_app/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../widgets/app_background.dart';
import '../../widgets/primary_button.dart';

/// 定时关闭：15/30/45/60/90 分钟，点“开始计时”把分钟数 pop 回播放页。
class TimerPage extends StatefulWidget {
  const TimerPage({super.key, this.initialMinutes});

  /// 播放器当前剩余的分钟数；不在选项里时默认 30。
  final int? initialMinutes;

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  static const List<int> _options = <int>[15, 30, 45, 60, 90];

  late int _minutes;

  @override
  void initState() {
    super.initState();
    final int? initial = widget.initialMinutes;
    _minutes = initial != null && _options.contains(initial) ? initial : 30;
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
                  options: _options,
                  selected: _minutes,
                  onSelect: (int value) => setState(() => _minutes = value),
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
                value: minutes / 90,
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
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  final List<int> options;
  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        for (int i = 0; i < options.length; i++) ...<Widget>[
          if (i > 0) const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _TimerOption(
              minutes: options[i],
              selected: options[i] == selected,
              onTap: () => onSelect(options[i]),
            ),
          ),
        ],
      ],
    );
  }
}

class _TimerOption extends StatelessWidget {
  const _TimerOption({
    required this.minutes,
    required this.selected,
    required this.onTap,
  });

  final int minutes;
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
            '$minutes 分',
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
