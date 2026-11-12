import 'package:mengyu_app/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../models/sleep_session.dart';
import '../../providers/sleep_provider.dart';
import '../../utils/formatters.dart';
import '../../utils/sleep_stats.dart';
import '../../widgets/app_background.dart';
import 'widgets/report_empty.dart';
import 'widgets/report_header.dart';
import 'widgets/report_moon_grid.dart';
import 'widgets/report_stats.dart';
import 'widgets/report_summary.dart';
import 'widgets/report_week_chart.dart';
/// v7 月迹：周汇总、7 晚柱状图、三项统计、30 天月相。
class ReportTab extends StatefulWidget {
  const ReportTab({super.key, required this.active});
  final bool active;
  @override
  State<ReportTab> createState() => _ReportTabState();
}
class _ReportTabState extends State<ReportTab> {
  int _weekOffset = 0;
  @override
  void initState() {
    super.initState();
    _loadIfActive();
  }
  @override
  void didUpdateWidget(covariant ReportTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.active && widget.active) {
      _loadIfActive();
    }
  }
  void _loadIfActive() {
    if (!widget.active) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.active) {
        context.read<SleepProvider>().ensureLoaded();
      }
    });
  }
  Future<void> _openSleepLog({SleepSession? session}) async {
    final bool? saved = await Navigator.pushNamed<bool>(
      context,
      AppRoutes.sleepLogForm,
      arguments: session,
    );
    if (!mounted || saved != true) {
      return;
    }
    await context.read<SleepProvider>().load();
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已补记，月迹已更新')),
    );
  }
  SleepSession _blankForDate(DateTime date) {
    return SleepSession(
      bedTime: DateTime(date.year, date.month, date.day, 23),
      wakeTime: DateTime(date.year, date.month, date.day + 1, 7),
      quality: 3,
    );
  }
  String _range(SleepWeekStats stats) {
    final String first =
        formatMonthDay(stats.days.first.date).replaceAll(' ', '');
    final String last =
        formatMonthDay(stats.days.last.date).replaceAll(' ', '');
    return '$first — $last';
  }
  String get _weekLabel {
    if (_weekOffset == 0) {
      return '本周';
    }
    if (_weekOffset == -1) {
      return '上周';
    }
    return '${-_weekOffset} 周前';
  }
  @override
  Widget build(BuildContext context) {
    final SleepProvider sleep = context.watch<SleepProvider>();
    final DateTime selectedToday = sleep.today.add(
      Duration(days: _weekOffset * 7),
    );
    final SleepWeekStats stats = buildSleepWeek(
      sleep.sessions,
      today: selectedToday,
    );
    final SleepWeekStats previous = buildSleepWeek(
      sleep.sessions,
      today: addDays(selectedToday, -7),
    );
    final DateTime start = weekStart(selectedToday);
    final DateTime end = addDays(start, 7);
    final List<SleepSession> weekSessions = sleep.sessions
        .where(
          (SleepSession session) =>
              !session.date.isBefore(start) && session.date.isBefore(end),
        )
        .toList(growable: false);
    return AppBackground(
      tint: context.c.tintReport,
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                ReportHeader(
                  range: _range(stats),
                  weekLabel: _weekLabel,
                  canNext: _weekOffset < 0,
                  onPrevious: () => setState(() => _weekOffset--),
                  onNext: () => setState(() => _weekOffset++),
                ),
                Expanded(
                  child: _body(
                    sleep,
                    stats,
                    previous,
                    weekSessions,
                  ),
                ),
              ],
            ),
            Positioned(
              right: AppSpacing.page,
              bottom: AppSpacing.page,
              child: _ReportAddButton(onTap: () => _openSleepLog()),
            ),
          ],
        ),
      ),
    );
  }
  Widget _body(
    SleepProvider sleep,
    SleepWeekStats stats,
    SleepWeekStats previous,
    List<SleepSession> weekSessions,
  ) {
    if (widget.active &&
        (!sleep.hasLoaded || sleep.isLoading) &&
        sleep.sessions.isEmpty) {
      return Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: context.c.secondary,
        ),
      );
    }
    if (sleep.error != null && sleep.sessions.isEmpty) {
      return ReportEmpty(
        icon: Icons.cloud_off_outlined,
        message: sleep.error!,
        actionLabel: '重试',
        onAction: sleep.load,
      );
    }
    if (sleep.sessions.isEmpty) {
      return ReportEmpty(
        icon: Icons.nightlight_outlined,
        message: '还没有睡眠记录',
        actionLabel: '补记昨晚',
        onAction: () => _openSleepLog(),
      );
    }
    return RefreshIndicator(
      color: context.c.secondary,
      backgroundColor: context.c.cover,
      onRefresh: sleep.load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.page,
          AppSpacing.sm,
          AppSpacing.page,
          80,
        ),
        children: <Widget>[
          ReportSummary(
            stats: stats,
            previousAverage: previous.averageMinutes,
            label: _weekOffset == 0 ? '本周平均睡眠' : '周平均睡眠',
          ),
          const SizedBox(height: AppSpacing.lg),
          ReportWeekChart(stats: stats, today: sleep.today),
          const SizedBox(height: AppSpacing.xxl),
          ReportStats(
            stats: stats,
            averageBedtime: ReportStats.bedtimeLabel(weekSessions),
          ),
          const SizedBox(height: AppSpacing.xxl),
          ReportMoonGrid(
            sessions: sleep.sessions,
            today: sleep.today,
            onAdd: () => _openSleepLog(),
            onPickDate: (DateTime date) =>
                _openSleepLog(session: _blankForDate(date)),
            onEditSession: (SleepSession session) =>
                _openSleepLog(session: session),
          ),
        ],
      ),
    );
  }
}
/// 月迹固定悬浮补记按钮：不随列表滚动，位置在页面右下角。
class _ReportAddButton extends StatelessWidget {
  const _ReportAddButton({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '补记睡眠',
      child: Material(
        color: context.c.primary,
        shape: const CircleBorder(),
        child: InkWell(
          key: const ValueKey<String>('report-add'),
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 56,
            height: 56,
            child: Icon(
              Icons.add,
              size: 24,
              color: context.c.onGold,
            ),
          ),
        ),
      ),
    );
  }
}
