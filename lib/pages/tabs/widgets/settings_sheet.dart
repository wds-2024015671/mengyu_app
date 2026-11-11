import 'package:mengyu_app/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_settings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/settings_provider.dart';
import '../../../widgets/custom_minutes_dialog.dart';
import 'settings_controls.dart';
import 'settings_sleep_section.dart';

/// v7 设置底部弹窗：#12152B、20 圆角、48 行高、44/14 选择按钮。
class SettingsSheet extends StatelessWidget {
  const SettingsSheet({
    super.key,
    required this.onClearData,
    required this.onAbout,
  });

  final VoidCallback onClearData;
  final VoidCallback onAbout;

  Future<void> _pickTheme(
    BuildContext context,
    SettingsProvider settings,
    AppThemeMode mode,
  ) async {
    final bool ok = await settings.setThemeMode(mode);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(settings.error ?? '主题保存失败')),
      );
    }
  }

  Future<void> _pickTimer(
    BuildContext context,
    SettingsProvider settings,
    int minutes,
  ) async {
    final bool ok = await settings.setDefaultTimerMinutes(minutes);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(settings.error ?? '默认定时保存失败')),
      );
    }
  }

  Future<void> _pickCustomTimer(
    BuildContext context,
    SettingsProvider settings,
  ) async {
    final int? minutes = await showCustomMinutesDialog(
      context,
      initialMinutes: settings.defaultTimerMinutes,
    );
    if (minutes != null && context.mounted) {
      await _pickTimer(context, settings, minutes);
    }
  }

  @override
  Widget build(BuildContext context) {
    final SettingsProvider settings = context.watch<SettingsProvider>();
    return Container(
      decoration: BoxDecoration(
        color: context.c.sheet,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.card),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.md,
            AppSpacing.page,
            AppSpacing.xxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.c.stroke,
                    borderRadius: BorderRadius.circular(AppRadius.chip),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text('设置', style: context.s.title),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    tooltip: '关闭',
                    padding: EdgeInsets.zero,
                    iconSize: 20,
                    icon: Icon(
                      Icons.close,
                      color: context.c.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                '主题',
                style: context.s.body.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: <Widget>[
                  for (final AppThemeMode mode in AppThemeMode.values)
                    SettingsChoiceButton(
                      label: mode.label,
                      icon: mode.icon,
                      selected: settings.themeModeSetting == mode,
                      onTap: () => _pickTheme(context, settings, mode),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text(
                '默认定时',
                style: context.s.body.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '从播放页打开定时页时的初始分钟数',
                style: context.s.captionMuted,
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: <Widget>[
                  for (final int minutes in kTimerOptions)
                    SettingsChoiceButton(
                      label: '$minutes 分钟',
                      selected: settings.defaultTimerMinutes == minutes,
                      onTap: () => _pickTimer(context, settings, minutes),
                    ),
                  SettingsChoiceButton(
                    label: '自定义',
                    selected: !kTimerOptions.contains(
                      settings.defaultTimerMinutes,
                    ),
                    onTap: () => _pickCustomTimer(context, settings),
                  ),
                ],
              ),
              if (!kTimerOptions.contains(settings.defaultTimerMinutes))
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xs),
                  child: Text(
                    '当前自定义：${settings.defaultTimerMinutes} 分钟',
                    style: context.s.captionMuted,
                  ),
                ),
              const SizedBox(height: AppSpacing.xxl),
              const SettingsSleepSection(),
              const SizedBox(height: AppSpacing.xxl),
              Divider(height: 1, color: context.c.stroke),
              SettingsMenuRow(
                label: '清除数据',
                trailing: '删除本地记录',
                onTap: () {
                  Navigator.pop(context);
                  onClearData();
                },
              ),
              SettingsMenuRow(
                label: '关于',
                trailing: 'v1.0.0',
                onTap: () {
                  Navigator.pop(context);
                  onAbout();
                },
              ),
              if (settings.error != null) ...<Widget>[
                const SizedBox(height: AppSpacing.md),
                Text(
                  settings.error!,
                  textAlign: TextAlign.center,
                  style: context.s.caption.copyWith(
                    color: context.c.danger,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
