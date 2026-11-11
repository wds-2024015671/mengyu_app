import 'package:mengyu_app/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// v7 我的两项统计：日记 / 仪式，无卡片底。
class ProfileStats extends StatelessWidget {
  const ProfileStats({
    super.key,
    required this.diaries,
    required this.rituals,
  });

  final int diaries;
  final int rituals;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(child: _Stat(value: '$diaries', label: '日记')),
        Expanded(child: _Stat(value: '$rituals', label: '仪式')),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          value,
          style: context.s.subtitle.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(label, style: context.s.micro),
      ],
    );
  }
}
