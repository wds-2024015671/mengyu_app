import 'package:mengyu_app/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';


/// v7 播放页顶栏：44 高，左下箭头 / 中“正在播放”。
class PlayerTopBar extends StatelessWidget {
  const PlayerTopBar({
    super.key,
    required this.onBack,
  });

  final VoidCallback onBack;

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
          const SizedBox(width: 44, height: 44),
        ],
      ),
    );
  }
}
