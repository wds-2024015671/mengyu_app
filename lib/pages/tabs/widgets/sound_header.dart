import 'package:flutter/material.dart';
import 'package:mengyu_app/core/theme/app_tokens.dart';

import '../../../core/theme/app_theme.dart';

/// 声屿头部：20/600 标题 + 11 t2 副标题 + 右上“＋ / 私人库”。
class SoundHeader extends StatelessWidget {
  const SoundHeader({super.key, required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.page,
        AppSpacing.page,
        0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('声屿', style: context.s.title),
                const SizedBox(height: AppSpacing.xs),
                Text('把世界调成静音', style: context.s.caption),
              ],
            ),
          ),
          Semantics(
            button: true,
            label: '添加到私人库',
            child: InkWell(
              onTap: onAdd,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: SizedBox(
                width: 52,
                height: 52,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: context.c.stroke),
                      ),
                      child: Icon(
                        Icons.add,
                        size: 20,
                        color: context.c.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text('私人库', style: context.s.micro),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
