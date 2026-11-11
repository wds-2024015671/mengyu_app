import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/settings_provider.dart';
import '../../../providers/sleep_tracking_provider.dart';

/// 我的页权限状态：自动记录开关 + 通知是否被拦截。
class ProfileTrackingStatus extends StatelessWidget {
  const ProfileTrackingStatus({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingsProvider settings = context.watch<SettingsProvider>();
    final SleepTrackingProvider tracking =
        context.watch<SleepTrackingProvider>();
    final String message = !settings.autoSleepTracking
        ? '自动记录已关闭'
        : tracking.hasPermission
            ? '自动记录已开启 · 晨间提醒已开启'
            : '自动记录已开启 · 通知被拦截';
    return Row(
      children: <Widget>[
        Icon(
          tracking.hasPermission
              ? Icons.notifications_active_outlined
              : Icons.notifications_off_outlined,
          size: 16,
          color: context.c.textTertiary,
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(message, style: context.s.captionMuted),
        ),
        if (settings.autoSleepTracking && !tracking.hasPermission)
          TextButton(
            onPressed: tracking.requestNotificationPermission,
            child: const Text('开启'),
          ),
      ],
    );
  }
}
