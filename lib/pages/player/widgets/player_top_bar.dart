import 'package:mengyu_app/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';


/// v7 播放页顶栏：44 高，左返回 / 中“正在播放”/ 可选右侧列表。
class PlayerTopBar extends StatelessWidget {
  const PlayerTopBar({
    super.key,
    required this.onBack,
    this.backIcon = Icons.keyboard_arrow_down,
    this.onTrailing,
    this.trailingIcon = Icons.format_list_bulleted,
    this.trailingTooltip = '定时',
  });

  final VoidCallback onBack;
  final IconData backIcon;
  final VoidCallback? onTrailing;
  final IconData trailingIcon;
  final String trailingTooltip;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 44,
            height: 44,
            child: IconButton(
              onPressed: onBack,
              tooltip: '返回',
              padding: EdgeInsets.zero,
              iconSize: 20,
              icon: Icon(backIcon, color: context.c.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              '正在播放',
              textAlign: TextAlign.center,
              style: context.s.captionMuted,
            ),
          ),
          SizedBox(
            width: 44,
            height: 44,
            child: onTrailing == null
                ? null
                : IconButton(
                    onPressed: onTrailing,
                    tooltip: trailingTooltip,
                    padding: EdgeInsets.zero,
                    iconSize: 20,
                    icon: Icon(
                      trailingIcon,
                      color: context.c.textSecondary,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
