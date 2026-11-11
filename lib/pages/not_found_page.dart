import 'package:mengyu_app/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';

import '../core/routes/app_routes.dart';
import '../core/theme/app_theme.dart';

/// 兜底页：未知路由、或命名路由参数类型不符时落到这里。
///
/// 为什么把它做成完整页面而不是 assert：深链/旧版本跳转会传错参数，
/// 线上不能让用户看到红屏；给一个能回首页的出口更稳。
class NotFoundPage extends StatelessWidget {
  const NotFoundPage({
    super.key,
    this.routeName,
    this.reason = '这个页面不存在',
  });

  final String? routeName;
  final String reason;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.c.bgDeep,
      appBar: AppBar(title: const Text('走丢了')),
      body: ColoredBox(
        color: context.c.bgDeep,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _NotFoundMessage(routeName: routeName, reason: reason),
                const SizedBox(height: AppSpacing.xxl),
                const _NotFoundActions(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NotFoundMessage extends StatelessWidget {
  const _NotFoundMessage({required this.routeName, required this.reason});

  final String? routeName;
  final String reason;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Icon(Icons.explore_off_outlined, size: 48, color: context.c.textTertiary),
        const SizedBox(height: AppSpacing.lg),
        Text(
          reason,
          textAlign: TextAlign.center,
          style: context.s.subtitle,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          routeName == null ? '没有更多线索了' : '路由：$routeName',
          textAlign: TextAlign.center,
          style: context.s.captionMuted,
        ),
      ],
    );
  }
}

class _NotFoundActions extends StatelessWidget {
  const _NotFoundActions();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        FilledButton(
          onPressed: () => Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.home,
            (Route<dynamic> route) => false,
          ),
          child: const Text('回到首页'),
        ),
        const SizedBox(height: AppSpacing.sm),
        OutlinedButton(
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
              return;
            }
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.welcome,
              (Route<dynamic> route) => false,
            );
          },
          child: const Text('返回'),
        ),
      ],
    );
  }
}
