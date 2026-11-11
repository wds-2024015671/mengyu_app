import 'package:mengyu_app/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// v7 欢迎底图的上半部分：静态今晚页内容，不接 Provider。
class WelcomeStaticHome extends StatelessWidget {
  const WelcomeStaticHome({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _StaticHeader(),
        SizedBox(height: AppSpacing.xxl),
        _StaticCta(),
        SizedBox(height: AppSpacing.xxl),
        _StaticSectionHeader(),
        SizedBox(height: AppSpacing.sm),
        _StaticRecommendation(),
        Spacer(),
      ],
    );
  }
}

class _StaticHeader extends StatelessWidget {
  const _StaticHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('11月10日 · 周一', style: context.s.caption),
              const SizedBox(height: AppSpacing.xs),
              Text('晚上好，小屿', style: context.s.display),
              const SizedBox(height: AppSpacing.sm),
              Text('把今天，轻轻放下。', style: context.s.bodySecondary),
              const SizedBox(height: AppSpacing.md),
              Text(
                '昨晚 23:41 · 6h42m · 连续 2 天',
                style: context.s.captionMuted,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        SizedBox(
          width: 72,
          height: 72,
          child: Icon(
            Icons.nightlight_round,
            size: 72,
            color: context.c.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _StaticCta extends StatelessWidget {
  const _StaticCta();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.c.primary,
          borderRadius: const BorderRadius.all(Radius.circular(AppRadius.card)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      '开始今晚的仪式',
                      style: context.s.onGoldTitle,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '约 15 分钟',
                      style: context.s.onGoldCaption,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward,
                size: 24,
                color: context.c.onGold,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StaticSectionHeader extends StatelessWidget {
  const _StaticSectionHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Text('今夜推荐', style: context.s.title),
        const Spacer(),
        Text('查看全部 ›', style: context.s.caption),
      ],
    );
  }
}

class _StaticRecommendation extends StatelessWidget {
  const _StaticRecommendation();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(AppRadius.card)),
        border: Border.fromBorderSide(BorderSide(color: context.c.stroke)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 64,
              height: 64,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: context.c.cover,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(AppRadius.control),
                  ),
                ),
                child: Icon(
                  Icons.graphic_eq,
                  size: 20,
                  color: context.c.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('雨落窗台', style: context.s.subtitle),
                  const SizedBox(height: AppSpacing.xs),
                  Text('雨声 · 45 分钟', style: context.s.caption),
                  const SizedBox(height: AppSpacing.xs),
                  Text('细密的雨，盖住杂念', style: context.s.captionMuted),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            SizedBox(
              width: 36,
              height: 36,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.fromBorderSide(
                    BorderSide(color: context.c.stroke),
                  ),
                ),
                child: Icon(
                  Icons.play_arrow,
                  size: 20,
                  color: context.c.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
