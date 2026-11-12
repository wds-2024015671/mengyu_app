import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/app_tokens.dart';
import '../../widgets/app_background.dart';
import 'sleep_tip_data.dart';
import 'sleep_tip_section.dart';

class SleepTipsPage extends StatelessWidget {
  const SleepTipsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        tint: context.c.tintTonight,
        showStars: false,
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  AppSpacing.sm,
                  AppSpacing.page,
                  0,
                ),
                child: Row(
                  children: <Widget>[
                    Tooltip(
                      message: '返回',
                      child: InkWell(
                        onTap: () => Navigator.pop(context),
                        customBorder: const CircleBorder(),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: context.c.stroke),
                          ),
                          child: Icon(
                            Icons.chevron_left,
                            size: 20,
                            color: context.c.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('睡眠温馨提醒', style: context.s.title),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            '4 个练习与原则',
                            style: context.s.caption,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Expanded(
                child: SingleChildScrollView(
                  key: const Key('sleep-tips-scroll'),
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.page,
                    0,
                    AppSpacing.page,
                    48,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      for (int i = 0; i < kSleepTipSections.length; i++) ...<Widget>[
                        if (i > 0)
                          Divider(
                            height: 49,
                            thickness: 1,
                            color: context.c.stroke,
                          ),
                        SleepTipSectionView(section: kSleepTipSections[i]),
                      ],
                      const SizedBox(height: AppSpacing.xxl),
                      Container(
                        padding: const EdgeInsets.only(top: AppSpacing.lg),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: context.c.stroke),
                          ),
                        ),
                        child: Text(
                          kSleepTipCbti,
                          style: context.s.captionMuted.copyWith(height: 1.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
