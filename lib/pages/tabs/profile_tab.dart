import 'package:app_settings/app_settings.dart';
import 'package:mengyu_app/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../data/services/avatar_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/avatar_provider.dart';
import '../../providers/diary_provider.dart';
import '../../providers/favorite_provider.dart';
import '../../providers/sleep_provider.dart';
import '../../widgets/app_background.dart';
import 'widgets/avatar_sheet.dart';
import 'widgets/profile_dialogs.dart';
import 'widgets/profile_entries.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_stats.dart';
import 'widgets/profile_tracking_status.dart';
import 'widgets/settings_sheet.dart';

/// v7 我的：资料、三项统计、收藏横向卡、设置/关于/退出。
class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key, required this.active});

  final bool active;

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  @override
  void initState() {
    super.initState();
    _loadIfActive();
  }

  @override
  void didUpdateWidget(covariant ProfileTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.active && widget.active) {
      _loadIfActive();
    }
  }

  void _loadIfActive() {
    if (!widget.active) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !widget.active) {
        return;
      }
      context.read<AuthProvider>().ensureLoaded();
      context.read<SleepProvider>().ensureLoaded();
      context.read<DiaryProvider>().load();
      context.read<FavoriteProvider>().ensureLoaded();
      context.read<AvatarProvider>().ensureLoaded();
    });
  }

  int _joinedDays(AuthProvider auth) {
    final DateTime? joinedAt = auth.user?.joinedAt;
    if (joinedAt == null) {
      return 0;
    }
    final int days = DateTime.now().difference(joinedAt).inDays + 1;
    return days < 1 ? 1 : days;
  }

  Future<void> _openAvatar() async {
    final AvatarSource? source = await showAvatarSheet(context);
    if (!mounted || source == null) {
      return;
    }
    final AvatarProvider avatar = context.read<AvatarProvider>();
    final bool ok = await avatar.pick(source);
    if (!mounted) {
      return;
    }
    if (ok) {
      context.read<AuthProvider>().setAvatarPath(avatar.path);
      return;
    }
    final String? error = avatar.error;
    if (error != null) {
      avatar.clearError();
      await _showAvatarError(error);
    }
  }

  Future<void> _showAvatarError(String message) async {
    final bool canOpenSettings =
        message.contains('权限') || message.contains('设置');
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('头像未更新'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('取消'),
            ),
            if (canOpenSettings)
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

  Future<void> _openSettings() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      builder: (BuildContext sheetContext) {
        return SettingsSheet(
          onClearData: () => confirmClearProfileData(context),
          onAbout: () => showProfileAbout(context),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final AuthProvider auth = context.watch<AuthProvider>();
    final SleepProvider sleep = context.watch<SleepProvider>();
    final FavoriteProvider favorites = context.watch<FavoriteProvider>();
    final DiaryProvider diary = context.watch<DiaryProvider>();
    final AvatarProvider avatar = context.watch<AvatarProvider>();
    final int joinedDays = _joinedDays(auth);

    return AppBackground(
      tint: context.c.tintMine,
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.page,
            AppSpacing.page,
            AppSpacing.xxxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text('我的', style: context.s.title),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${auth.nickname}的夜晚',
                style: context.s.caption,
              ),
              const SizedBox(height: AppSpacing.xxl),
              ProfileHeader(
                nickname: auth.nickname,
                streakDays: sleep.weekStats.streakDays,
                joinedDays: joinedDays,
                avatarPath: avatar.path,
                avatarLoading: avatar.isLoading,
                onTapAvatar: _openAvatar,
                onTap: () => showProfileAbout(context),
              ),
              const SizedBox(height: AppSpacing.xxl),
              ProfileStats(
                favorites: favorites.count,
                diaries: diary.entries.length,
                rituals: sleep.sessions.length,
              ),
              const SizedBox(height: AppSpacing.xxl),
              ProfileEntries(
                onSettings: _openSettings,
                onAbout: () => showProfileAbout(context),
                onPurpose: () => showProfilePurpose(context),
                onTerms: () => showProfileTerms(context),
                onLogout: () => confirmProfileLogout(context),
              ),
              const SizedBox(height: AppSpacing.xxl),
              const ProfileTrackingStatus(),
              const SizedBox(height: AppSpacing.md),
              Text(
                'MENGYU v1.0.0',
                textAlign: TextAlign.center,
                style: context.s.micro,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
