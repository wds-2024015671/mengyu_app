import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/app_theme.dart';

/// v7 我的资料行：56 头像 + 昵称 + 连续/加入信息 + chevron。
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.nickname,
    required this.streakDays,
    required this.joinedDays,
    required this.onTap,
    required this.onTapAvatar,
    this.avatarPath,
    this.avatarLoading = false,
  });

  final String nickname;
  final int streakDays;
  final int joinedDays;
  final VoidCallback onTap;
  final VoidCallback onTapAvatar;
  final String? avatarPath;
  final bool avatarLoading;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 56,
        child: Row(
          children: <Widget>[
            _AvatarButton(
              path: avatarPath,
              loading: avatarLoading,
              onTap: onTapAvatar,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    nickname,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.s.subtitle.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '连续靠岸 $streakDays 天 · 加入 $joinedDays 天',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.s.caption,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: context.c.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _AvatarButton extends StatelessWidget {
  const _AvatarButton({
    required this.path,
    required this.loading,
    required this.onTap,
  });

  final String? path;
  final bool loading;
  final VoidCallback onTap;

  bool get _hasImage {
    final String? value = path;
    return value != null && value.isNotEmpty && File(value).existsSync();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: const Key('profile-avatar'),
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 56,
        height: 56,
        child: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.c.cover,
                border: Border.all(color: context.c.stroke),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  if (_hasImage)
                    Image.file(
                      File(path!),
                      key: ValueKey<String>(path!),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const _DefaultAvatarIcon(),
                    )
                  else
                    const _DefaultAvatarIcon(),
                ],
              ),
            ),
            Positioned(
              right: -2,
              bottom: -2,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.c.sheet,
                  border: Border.all(color: context.c.stroke),
                ),
                child: loading
                    ? Padding(
                        padding: const EdgeInsets.all(4),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: context.c.textSecondary,
                        ),
                      )
                    : Icon(
                        Icons.photo_camera_outlined,
                        size: 12,
                        color: context.c.textSecondary,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DefaultAvatarIcon extends StatelessWidget {
  const _DefaultAvatarIcon();

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.nightlight_outlined,
      size: 24,
      color: context.c.textSecondary,
    );
  }
}
