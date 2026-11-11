import 'package:mengyu_app/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';


/// v7 播放页顶栏：44 高，左下箭头 / 中“正在播放”/ 右更多（定时）。
class PlayerTopBar extends StatelessWidget {
  const PlayerTopBar({
    super.key,
    required this.onBack,
    required this.onMore,
  });

  final VoidCallback onBack;
  final VoidCallback onMore;

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
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: context.c.textSecondary,
              ),
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
            child: IconButton(
              onPressed: onMore,
              tooltip: '更多',
              padding: EdgeInsets.zero,
              iconSize: 20,
              icon: Icon(
                Icons.more_horiz,
                color: context.c.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
