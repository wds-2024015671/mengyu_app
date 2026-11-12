import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../widgets/glass_card.dart';
import '../../sleep/sleep_tip_data.dart';
import '../../sleep/sleep_tips_page.dart';

class SleepTipsCard extends StatelessWidget {
  const SleepTipsCard({super.key});

  void _open(BuildContext context) {
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext pageContext) => const SleepTipsPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      outlined: true,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                Icons.favorite_border,
                size: 20,
                color: context.c.textSecondary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  '睡眠温馨提醒',
                  style: context.s.subtitle.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(
                width: 36,
                height: 36,
                child: IconButton(
                  onPressed: () => _open(context),
                  tooltip: '查看睡眠提醒',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(
                    width: 36,
                    height: 36,
                  ),
                  iconSize: 20,
                  icon: Icon(
                    Icons.chevron_right,
                    color: context.c.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          for (int i = 0; i < kSleepTipRowTitles.length; i++)
            SizedBox(
              height: 28,
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 24,
                    child: Text(
                      '${i + 1}'.padLeft(2, '0'),
                      style: context.s.micro.copyWith(
                        color: context.c.secondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      kSleepTipRowTitles[i],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.s.body.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: AppSpacing.sm),
          Divider(height: 1, thickness: 1, color: context.c.stroke),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '如果长期失眠，建议寻求专业评估',
            style: context.s.micro.copyWith(color: context.c.textTertiary),
          ),
        ],
      ),
    );
  }
}
