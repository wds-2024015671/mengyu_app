import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/app_tokens.dart';
import 'sleep_tip_data.dart';

class SleepTipSectionView extends StatelessWidget {
  const SleepTipSectionView({super.key, required this.section});

  final SleepTipSection section;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          section.number,
          style: context.s.micro.copyWith(
            color: context.c.secondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(section.title, style: context.s.title),
        for (final String paragraph in section.paragraphs)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.md),
            child: Text(
              paragraph,
              style: context.s.bodySecondary.copyWith(
                color: context.c.textSecondary,
                height: 1.7,
              ),
            ),
          ),
        for (final SleepTipMethod method in section.methods) ...<Widget>[
          const SizedBox(height: AppSpacing.xxl),
          Text(
            method.title,
            style: context.s.subtitle.copyWith(fontWeight: FontWeight.w500),
          ),
          for (final String paragraph in method.paragraphs)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.md),
              child: Text(
                paragraph,
                style: context.s.bodySecondary.copyWith(
                  color: context.c.textSecondary,
                  height: 1.7,
                ),
              ),
            ),
        ],
      ],
    );
  }
}
