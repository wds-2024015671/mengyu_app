import 'package:mengyu_app/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/audio_item.dart';

/// 收藏全部列表：底部弹层，不新开页面。
class ProfileFavoriteSheet extends StatelessWidget {
  const ProfileFavoriteSheet({
    super.key,
    required this.items,
    required this.onOpen,
  });

  final List<AudioItem> items;
  final ValueChanged<AudioItem> onOpen;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.c.sheet,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.card),
        ),
      ),
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(height: AppSpacing.md),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.c.stroke,
                  borderRadius: BorderRadius.circular(AppRadius.chip),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  AppSpacing.md,
                  AppSpacing.sm,
                  0,
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text('我的收藏', style: context.s.title),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      tooltip: '关闭',
                      iconSize: 20,
                      icon: Icon(
                        Icons.close,
                        color: context.c.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (items.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.xxl),
                  child: Column(
                    children: <Widget>[
                      Icon(
                        Icons.favorite_border,
                        size: 24,
                        color: context.c.textTertiary,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text('还没有收藏', style: context.s.caption),
                    ],
                  ),
                )
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.page,
                    ),
                    itemCount: items.length,
                    itemBuilder: (BuildContext context, int index) {
                      final AudioItem item = items[index];
                      return InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          onOpen(item);
                        },
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: context.c.stroke),
                            ),
                          ),
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.graphic_eq,
                                size: 20,
                                color: context.c.textSecondary,
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Text(
                                  item.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: context.s.body.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
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
                    },
                  ),
                ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),
      ),
    );
  }
}
