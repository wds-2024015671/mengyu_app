import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/app_theme.dart';
import '../../models/sleep_session.dart';
import '../../providers/sleep_provider.dart';
import '../../utils/formatters.dart';
import '../../utils/sleep_validation.dart';
import '../../widgets/app_background.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/primary_button.dart';
import 'sleep_save_coordinator.dart';
import 'widgets/sleep_quality_picker.dart';
import 'widgets/sleep_summary_card.dart';
import 'widgets/sleep_time_card.dart';
/// 睡眠补记：日期/时间选择、自动时长、1–16 小时校验、评分与备注。
class SleepLogFormPage extends StatefulWidget {
  const SleepLogFormPage({super.key, this.session});
  /// id 为 null 时只作为日期预填，不视为编辑既有记录。
  final SleepSession? session;
  @override
  State<SleepLogFormPage> createState() => _SleepLogFormPageState();
}
class _SleepLogFormPageState extends State<SleepLogFormPage> {
  late DateTime _bedTime, _wakeTime;
  late int _quality;
  late final TextEditingController _noteController;
  bool _saving = false;
  String? _error;
  @override
  void initState() {
    super.initState();
    final SleepSession? session = widget.session;
    if (session != null) {
      _bedTime = session.bedTime;
      _wakeTime = session.wakeTime;
      _quality = session.quality;
    } else {
      final DateTime now = DateTime.now();
      final DateTime today = DateTime(now.year, now.month, now.day);
      _bedTime = today
          .subtract(const Duration(days: 1))
          .add(const Duration(hours: 23));
      _wakeTime = today.add(const Duration(hours: 7));
      _quality = 3;
    }
    _noteController = TextEditingController(text: session?.note ?? '');
  }
  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }
  int get _durationMin {
    final int minutes = _wakeTime.difference(_bedTime).inMinutes;
    return minutes > 0 ? minutes : 0;
  }
  String get _durationText =>
      _durationMin > 0 ? formatMinutes(_durationMin) : '—';
  Future<void> _pickDate({required bool bed}) async {
    final DateTime base = bed ? _bedTime : _wakeTime;
    final DateTime now = DateTime.now();
    final DateTime last = DateTime(now.year, now.month, now.day);
    final DateTime first = DateTime(now.year - 1, now.month, now.day);
    final DateTime initial = base.isAfter(last)
        ? last
        : (base.isBefore(first) ? first : base);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
      locale: const Locale('zh', 'CN'),
    );
    if (!mounted || picked == null) {
      return;
    }
    setState(() {
      final DateTime baseTime = bed ? _bedTime : _wakeTime;
      final DateTime updated = DateTime(
        picked.year,
        picked.month,
        picked.day,
        baseTime.hour,
        baseTime.minute,
      );
      if (bed) { _bedTime = updated; } else { _wakeTime = updated; }
      _wakeTime = normalizeWakeTime(_bedTime, _wakeTime);
      _error = null;
    });
  }
  Future<void> _pickTime({required bool bed}) async {
    final DateTime base = bed ? _bedTime : _wakeTime;
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(base),
      helpText: bed ? '入睡时间' : '起床时间',
    );
    if (!mounted || picked == null) {
      return;
    }
    setState(() {
      final DateTime baseTime = bed ? _bedTime : _wakeTime;
      final DateTime updated = DateTime(
        baseTime.year,
        baseTime.month,
        baseTime.day,
        picked.hour,
        picked.minute,
      );
      if (bed) { _bedTime = updated; } else { _wakeTime = updated; }
      _wakeTime = normalizeWakeTime(_bedTime, _wakeTime);
      _error = null;
    });
  }
  Future<void> _save() async {
    final String? validation = validateSleepRange(_bedTime, _wakeTime);
    if (validation != null) {
      setState(() => _error = validation);
      return;
    }
    setState(() => _error = null);
    final SleepSession session = SleepSession(
      id: widget.session?.id,
      bedTime: _bedTime,
      wakeTime: _wakeTime,
      quality: _quality,
      note: _noteController.text.trim(),
      source: widget.session?.source ?? SleepSource.manual,
      nightKeyValue: widget.session?.nightKeyValue,
    );
    final SleepProvider provider = context.read<SleepProvider>();
    final SleepSaveResult result = await saveSleepSession(
      context: context,
      provider: provider,
      session: session,
      isNew: widget.session?.id == null,
      onCommit: () {
        if (mounted) {
          setState(() => _saving = true);
        }
      },
    );
    if (!mounted) {
      return;
    }
    setState(() => _saving = false);
    if (result.outcome == SleepSaveOutcome.cancelled) {
      return;
    }
    if (result.outcome == SleepSaveOutcome.failed) {
      setState(() => _error = result.error ?? '保存失败，请稍后再试');
      return;
    }
    Navigator.pop(context, true);
  }
  @override
  Widget build(BuildContext context) {
    final bool editing = widget.session?.id != null;
    return Scaffold(
      backgroundColor: context.c.bgDeep,
      appBar: AppBar(title: Text(editing ? '编辑睡眠记录' : '补记睡眠')),
      body: AppBackground(
        tint: context.c.tintReport,
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.page,
              AppSpacing.lg,
              AppSpacing.page,
              AppSpacing.xxl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  '补上之前漏记的夜晚，月迹会自动更新。',
                  textAlign: TextAlign.center,
                  style: context.s.captionMuted,
                ),
                const SizedBox(height: AppSpacing.xl),
                SleepTimeCard(
                  label: '入睡',
                  icon: Icons.bedtime_outlined,
                  time: _bedTime,
                  onPickDate: () => _pickDate(bed: true),
                  onPickTime: () => _pickTime(bed: true),
                ),
                const SizedBox(height: AppSpacing.md),
                SleepTimeCard(
                  label: '起床',
                  icon: Icons.wb_sunny_outlined,
                  time: _wakeTime,
                  onPickDate: () => _pickDate(bed: false),
                  onPickTime: () => _pickTime(bed: false),
                ),
                const SizedBox(height: AppSpacing.lg),
                SleepSummaryCard(
                  durationText: _durationText,
                  quality: _quality,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text('睡眠评分', style: context.s.subtitle),
                const SizedBox(height: AppSpacing.sm),
                SleepQualityPicker(
                  quality: _quality,
                  onChanged: (int value) => setState(() => _quality = value),
                ),
                const SizedBox(height: AppSpacing.lg),
                GlassCard(
                  outlined: true,
                  child: TextField(
                    controller: _noteController,
                    maxLines: 3,
                    style: context.s.body,
                    decoration: InputDecoration(
                      hintText: '备注（可选）',
                      hintStyle: context.s.caption,
                      filled: false,
                      border: InputBorder.none,
                    ),
                  ),
                ),
                if (_error != null) ...<Widget>[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: context.s.caption.copyWith(
                      color: context.c.danger,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.xl),
                PrimaryButton(
                  label: '保存记录',
                  loading: _saving,
                  onPressed: _saving ? null : _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
