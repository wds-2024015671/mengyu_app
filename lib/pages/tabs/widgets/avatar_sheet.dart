import 'package:flutter/material.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/avatar_service.dart';

/// 头像来源选择：拍一张 / 从相册选 / 取消。
Future<AvatarSource?> showAvatarSheet(BuildContext context) {
  return showModalBottomSheet<AvatarSource>(
    context: context,
    backgroundColor: Colors.transparent,
    elevation: 0,
    builder: (BuildContext sheetContext) {
      return Container(
        decoration: BoxDecoration(
          color: context.c.sheet,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadius.card),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.page,
              AppSpacing.md,
              AppSpacing.page,
              AppSpacing.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                Text('更换头像', style: context.s.title),
                const SizedBox(height: AppSpacing.sm),
                _AvatarSheetRow(
                  icon: Icons.photo_camera_outlined,
                  label: '拍一张',
                  onTap: () =>
                      Navigator.pop(sheetContext, AvatarSource.camera),
                ),
                _AvatarSheetRow(
                  icon: Icons.photo_library_outlined,
                  label: '从相册选择',
                  onTap: () =>
                      Navigator.pop(sheetContext, AvatarSource.gallery),
                ),
                _AvatarSheetRow(
                  icon: Icons.close,
                  label: '取消',
                  onTap: () => Navigator.pop(sheetContext),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _AvatarSheetRow extends StatelessWidget {
  const _AvatarSheetRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: context.c.stroke)),
        ),
        child: Row(
          children: <Widget>[
            Icon(icon, size: 20, color: context.c.textSecondary),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: context.s.body.copyWith(fontWeight: FontWeight.w500),
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 16,
              color: context.c.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
