import 'package:mengyu_app/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../widgets/app_background.dart';
import '../main/widgets/tab_icon.dart';
import 'welcome_static_home.dart';

/// v7 欢迎页底图：静态复刻今晚页，不接 Provider、不可点、无动画。
class WelcomeBackdrop extends StatelessWidget {
  const WelcomeBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: <Widget>[
          AppBackground(
            tint: context.c.tintTonight,
            child: const SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  AppSpacing.page,
                  AppSpacing.page,
                  80,
                ),
                child: WelcomeStaticHome(),
              ),
            ),
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _StaticTabBar(),
          ),
        ],
      ),
    );
  }
}

class _StaticTabBar extends StatelessWidget {
  const _StaticTabBar();

  static const List<String> _labels = <String>['今晚', '声屿', '月迹', '我的'];
  static const List<TabIconKind> _kinds = <TabIconKind>[
    TabIconKind.moon,
    TabIconKind.sound,
    TabIconKind.phase,
    TabIconKind.person,
  ];

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.c.bgDeep,
        border: Border(top: BorderSide(color: context.c.stroke)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: <Widget>[
              for (int i = 0; i < _labels.length; i++)
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      TabIcon(
                        kind: _kinds[i],
                        color: i == 0
                            ? context.c.secondary
                            : context.c.textTertiary,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        _labels[i],
                        style: context.s.micro.copyWith(
                          color: i == 0
                              ? context.c.secondary
                              : context.c.textTertiary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Container(
                        width: 16,
                        height: 3,
                        decoration: BoxDecoration(
                          color: i == 0
                              ? context.c.secondary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
