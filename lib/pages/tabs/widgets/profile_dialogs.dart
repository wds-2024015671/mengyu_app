import 'package:mengyu_app/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/routes/app_routes.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/diary_provider.dart';
import '../../../providers/favorite_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../providers/sleep_provider.dart';
import '../../../providers/sleep_tracking_provider.dart';
import '../../../providers/upload_provider.dart';
import 'info_content.dart';
import 'info_dialog.dart';

Future<void> showProfileAbout(BuildContext context) async {
  await showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) {
      return const InfoDialog(
        title: '关于梦屿',
        paragraphs: <String>[
          '梦屿 · 睡眠与声音疗愈',
          '把夜晚还给自己。日记、睡眠与收藏都只存在本机。',
          '版本 1.0.0 · 本地数据版',
        ],
      );
    },
  );
}

Future<void> showProfilePurpose(BuildContext context) async {
  await showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) {
      return const InfoDialog(
        title: AppInfoCopy.purposeTitle,
        paragraphs: AppInfoCopy.purposeParagraphs,
      );
    },
  );
}

Future<void> showProfileTerms(BuildContext context) async {
  await showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) {
      return const InfoDialog(
        title: AppInfoCopy.termsTitle,
        paragraphs: AppInfoCopy.termsParagraphs,
      );
    },
  );
}

Future<void> confirmProfileLogout(BuildContext context) async {
  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('退出登录？'),
        content: const Text('退出后需要重新登录才能查看日记与睡眠记录。'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('退出'),
          ),
        ],
      );
    },
  );
  if (!context.mounted || confirmed != true) {
    return;
  }
  final AuthProvider auth = context.read<AuthProvider>();
  await auth.logout();
  if (!context.mounted) {
    return;
  }
  if (auth.hasSession) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(auth.error ?? '退出失败，请稍后再试')),
    );
    return;
  }
  Navigator.pushNamedAndRemoveUntil(
    context,
    AppRoutes.login,
    (Route<dynamic> route) => false,
  );
}

Future<void> confirmClearProfileData(BuildContext context) async {
  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('清除所有本地数据？'),
        content: const Text('日记、睡眠记录、收藏、上传记录与设置都会被删除，且无法恢复。'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              '清除',
              style: TextStyle(color: context.c.danger),
            ),
          ),
        ],
      );
    },
  );
  if (!context.mounted || confirmed != true) {
    return;
  }
  final SettingsProvider settings = context.read<SettingsProvider>();
  final bool cleared = await settings.clearAllData();
  if (!context.mounted) {
    return;
  }
  if (!cleared) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(settings.error ?? '清除数据失败，请稍后再试')),
    );
    return;
  }

  context.read<AuthProvider>().reset();
  context.read<DiaryProvider>().reset();
  context.read<SleepProvider>().reset();
  context.read<SleepTrackingProvider>().reset();
  context.read<UploadProvider>().reset();
  context.read<FavoriteProvider>().reset();
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('本地数据已清除')),
  );
  Navigator.pushNamedAndRemoveUntil(
    context,
    AppRoutes.login,
    (Route<dynamic> route) => false,
  );
}
