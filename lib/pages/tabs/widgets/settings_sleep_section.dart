import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/sleep_settings.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/settings_provider.dart';
import '../../../providers/sleep_tracking_provider.dart';

/// 设置里的睡眠记录区：自动记录、晨间提醒、提醒时间、通知权限。
class SettingsSleepSection extends StatelessWidget {
  const SettingsSleepSection({super.key});

  String _clock(int minutes) {
    final String hour = (minutes ~/ 60).toString().padLeft(2, '0');
    final String minute = (minutes % 60).toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _toggleAuto(
    BuildContext context,
    SettingsProvider settings,
    bool enabled,
  ) async {
    if (enabled) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      if (!(prefs.getBool(kSleepIntroSeenKey) ?? false)) {
        if (!context.mounted) {
          return;
        }
        await showDialog<void>(
          context: context,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              title: const Text('为什么记录睡眠'),
              content: Text(
                '梦屿只在本地记录大致睡眠时间，用来生成月迹和统计；'
                '不上传、不卖给任何人，可以随时关掉。',
                style: context.s.bodySecondary,
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('知道了'),
                ),
              ],
            );
          },
        );
        await prefs.setBool(kSleepIntroSeenKey, true);
      }
    }
    if (!context.mounted) {
      return;
    }
    await settings.setAutoSleepTracking(enabled);
    if (context.mounted) {
      await context.read<SleepTrackingProvider>().rescheduleReminder();
    }
  }

  Future<void> _requestPermission(
    BuildContext context,
    SleepTrackingProvider tracking,
  ) async {
    final bool granted = await tracking.requestNotificationPermission();
    if (!context.mounted) {
      return;
    }
    if (!granted) {
      await showDialog<void>(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text('通知未开启'),
            content: Text(
              '晨间提醒会被系统拦截。仍可在打开梦屿时看到待确认提示。',
              style: context.s.bodySecondary,
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  AppSettings.openAppSettings();
                },
                child: const Text('去设置'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final SettingsProvider settings = context.watch<SettingsProvider>();
    final SleepTrackingProvider tracking =
        context.watch<SleepTrackingProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          '睡眠记录',
          style: context.s.body.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '只在本机记录大致睡眠时间，不上传；可随时关掉。',
          style: context.s.captionMuted,
        ),
        const SizedBox(height: AppSpacing.sm),
        _ToggleRow(
          label: '自动记录睡眠',
          value: settings.autoSleepTracking,
          onChanged: (bool value) => _toggleAuto(context, settings, value),
        ),
        _ToggleRow(
          label: '晨间确认提醒',
          value: settings.morningReminder,
          onChanged: (bool value) async {
            await settings.setMorningReminder(value);
            if (context.mounted) {
              await context.read<SleepTrackingProvider>().rescheduleReminder();
            }
          },
        ),
        if (settings.morningReminder) ...<Widget>[
          const SizedBox(height: AppSpacing.sm),
          Text('提醒时间', style: context.s.caption),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.sm,
            children: <Widget>[
              for (final int minutes in kReminderOptions)
                ChoiceChip(
                  label: Text(_clock(minutes)),
                  selected: settings.reminderMinutes == minutes,
                  onSelected: (_) async {
                    await settings.setReminderMinutes(minutes);
                    if (context.mounted) {
                      await context
                          .read<SleepTrackingProvider>()
                          .rescheduleReminder();
                    }
                  },
                  labelStyle: context.s.caption,
                  selectedColor: context.c.secondary.withOpacity(0.12),
                  backgroundColor: Colors.transparent,
                  side: BorderSide(
                    color: settings.reminderMinutes == minutes
                        ? context.c.secondary
                        : context.c.stroke,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.chip),
                  ),
                ),
            ],
          ),
        ],
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                tracking.hasPermission ? '通知权限已开启' : '通知权限未开启',
                style: context.s.captionMuted,
              ),
            ),
            if (!tracking.hasPermission)
              TextButton(
                onPressed: () => _requestPermission(context, tracking),
                child: const Text('开启提醒'),
              ),
          ],
        ),
        if (!tracking.hasPermission)
          Text(
            '部分系统还需允许自启动或关闭电池限制，晨间提醒才能准时到达。',
            style: context.s.captionMuted,
          ),
        const SizedBox(height: AppSpacing.lg),
        Divider(height: 1, color: context.c.stroke),
      ],
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Row(
        children: <Widget>[
          Expanded(child: Text(label, style: context.s.body)),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: context.c.primary,
            activeTrackColor: context.c.primary.withOpacity(0.35),
          ),
        ],
      ),
    );
  }
}
