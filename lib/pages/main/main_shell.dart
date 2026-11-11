import 'package:mengyu_app/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/avatar_provider.dart';
import '../tabs/home_tab.dart';
import '../tabs/profile_tab.dart';
import '../tabs/report_tab.dart';
import '../tabs/sound_tab.dart';
import 'widgets/tab_icon.dart';

/// 主框架：IndexedStack 保住 4 个 tab 的状态，底部导航自己画。
///
/// 首帧后检查登录态：没有会话（账号或游客）就替换成 /login，
/// 避免未登录用户看到首页数据；游客 hasSession=true 可以正常停留。
class MainShell extends StatefulWidget {
  const MainShell({super.key, this.initialTab = 0});

  /// 命名路由 /home /sound /report /profile 通过它指定首屏 tab。
  final int initialTab;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  static const int _tabCount = 4;

  late int _index;
  bool _authChecked = false;

  @override
  void initState() {
    super.initState();
    _index = _safeIndex(widget.initialTab);
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureSession());
  }

  Future<void> _ensureSession() async {
    if (_authChecked || !mounted) {
      return;
    }
    _authChecked = true;
    final AuthProvider auth = context.read<AuthProvider>();
    await auth.ensureLoaded();
    if (!mounted) {
      return;
    }
    await context.read<AvatarProvider>().ensureLoaded();
    if (!mounted) {
      return;
    }
    if (!auth.hasSession) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  void didUpdateWidget(covariant MainShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 同一个 MainShell 换了 initialTab（路由复用）时跟着切，不重新建 State。
    if (oldWidget.initialTab != widget.initialTab) {
      _index = _safeIndex(widget.initialTab);
    }
  }

  int _safeIndex(int value) {
    if (value <= 0) {
      return 0;
    }
    if (value >= _tabCount) {
      return _tabCount - 1;
    }
    return value;
  }

  void _select(int value) {
    if (value == _index) {
      return;
    }
    setState(() => _index = value);
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness:
            isDark ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: context.c.bgDeep,
        body: IndexedStack(
          index: _index,
          children: <Widget>[
            HomeTab(
              onOpenReport: () => _select(2),
              onOpenSound: () => _select(1),
            ),
            SoundTab(active: _index == 1),
            ReportTab(active: _index == 2),
            ProfileTab(active: _index == 3),
          ],
        ),
        bottomNavigationBar: _MainBottomBar(index: _index, onSelect: _select),
      ),
    );
  }
}

/// tab 的静态描述，避免在 build 里拼图标与文案。
class _TabSpec {
  const _TabSpec({required this.label, required this.kind});

  final String label;
  final TabIconKind kind;
}

/// v7 底部导航：64 高、1px 顶部 stroke、无模糊/阴影/浮岛。
class _MainBottomBar extends StatelessWidget {
  const _MainBottomBar({required this.index, required this.onSelect});

  final int index;
  final ValueChanged<int> onSelect;

  static const List<_TabSpec> _specs = <_TabSpec>[
    _TabSpec(label: '今晚', kind: TabIconKind.moon),
    _TabSpec(label: '声屿', kind: TabIconKind.sound),
    _TabSpec(label: '月迹', kind: TabIconKind.phase),
    _TabSpec(label: '我的', kind: TabIconKind.person),
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
              for (int i = 0; i < _specs.length; i++)
                Expanded(
                  child: _MainTabItem(
                    spec: _specs[i],
                    selected: i == index,
                    onTap: () => onSelect(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MainTabItem extends StatelessWidget {
  const _MainTabItem({
    required this.spec,
    required this.selected,
    required this.onTap,
  });

  final _TabSpec spec;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color tint = selected ? context.c.secondary : context.c.textTertiary;
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TabIcon(kind: spec.kind, color: tint),
            const SizedBox(height: AppSpacing.xs),
            Text(
              spec.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.s.micro.copyWith(color: tint),
            ),
            const SizedBox(height: AppSpacing.xs),
            Container(
              width: 16,
              height: 3,
              decoration: BoxDecoration(
                color: selected ? context.c.secondary : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
