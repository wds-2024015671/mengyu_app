import 'package:flutter/material.dart';

import '../../../core/theme/app_tokens.dart';

class MediaSelectCircle extends StatelessWidget {
  const MediaSelectCircle({
    super.key,
    required this.selected,
    this.size = 20,
  });

  final bool selected;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? context.c.secondary : Colors.transparent,
        border: Border.all(
          color: selected ? context.c.secondary : context.c.textTertiary,
          width: selected ? 0 : 1.5,
        ),
      ),
      child: selected
          ? Icon(
              Icons.check,
              size: size * 0.6,
              color: context.c.bgDeep,
            )
          : null,
    );
  }
}
