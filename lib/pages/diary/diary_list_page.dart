import 'package:mengyu_app/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../models/diary_entry.dart';
import '../../providers/diary_provider.dart';
import '../../utils/formatters.dart';
import '../../widgets/app_background.dart';
import 'widgets/diary_card.dart';
import 'widgets/diary_empty_card.dart';
import 'widgets/diary_group_header.dart';

/// 日记列表：按 entry_date 倒序分组、下拉刷新、删除二次确认、FAB 新建。
class DiaryListPage extends StatefulWidget {
  const DiaryListPage({super.key});

  @override
  State<DiaryListPage> createState() => _DiaryListPageState();
}

class _DiaryListPageState extends State<DiaryListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<DiaryProvider>().load();
      }
    });
  }

  Future<void> _openEditor([DiaryEntry? entry]) async {
    final DiaryEntry? saved = await Navigator.pushNamed<DiaryEntry?>(
      context,
      AppRoutes.diaryEdit,
      arguments: entry,
    );
    if (!mounted || saved == null) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(entry == null ? '日记已保存' : '日记已更新')),
    );
  }

  Future<void> _confirmDelete(DiaryEntry entry) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('删除这篇日记？'),
          content: const Text('删除后无法恢复。'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(
                '删除',
                style: TextStyle(color: context.c.danger),
              ),
            ),
          ],
        );
      },
    );
    if (!mounted || confirmed != true) {
      return;
    }
    final int? id = entry.id;
    if (id == null) {
      return;
    }
    final DiaryProvider provider = context.read<DiaryProvider>();
    final bool deleted = await provider.delete(id);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(deleted ? '已删除' : (provider.error ?? '删除失败')),
      ),
    );
  }

  List<Widget> _buildGroups(List<DiaryEntry> entries) {
    final List<DiaryEntry> sorted = List<DiaryEntry>.of(entries)
      ..sort((DiaryEntry a, DiaryEntry b) {
        final int byDate = b.entryDate.compareTo(a.entryDate);
        if (byDate != 0) {
          return byDate;
        }
        final DateTime aCreated = a.createdAt ?? a.entryDate;
        final DateTime bCreated = b.createdAt ?? b.entryDate;
        return bCreated.compareTo(aCreated);
      });

    final Map<String, List<DiaryEntry>> groups = <String, List<DiaryEntry>>{};
    for (final DiaryEntry entry in sorted) {
      groups
          .putIfAbsent(formatDateKey(entry.entryDate), () => <DiaryEntry>[])
          .add(entry);
    }

    final List<Widget> children = <Widget>[];
    for (final List<DiaryEntry> group in groups.values) {
      children.add(
        DiaryGroupHeader(date: group.first.entryDate, count: group.length),
      );
      for (final DiaryEntry entry in group) {
        children.add(
          DiaryCard(
            entry: entry,
            onTap: () => _openEditor(entry),
            onDelete: () => _confirmDelete(entry),
          ),
        );
      }
    }
    return children;
  }

  Widget _buildBody(DiaryProvider provider) {
    if (provider.isLoading && !provider.hasData) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            CircularProgressIndicator(
              strokeWidth: 2,
              color: context.c.secondary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text('正在加载日记', style: context.s.captionMuted),
          ],
        ),
      );
    }
    if (provider.error != null && !provider.hasData) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.page),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.cloud_off_outlined,
                size: 24,
                color: context.c.textTertiary,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                provider.error!,
                textAlign: TextAlign.center,
                style: context.s.caption,
              ),
              TextButton(
                onPressed: provider.load,
                style: TextButton.styleFrom(
                  foregroundColor: context.c.textSecondary,
                  textStyle: context.s.caption,
                ),
                child: const Text('重试'),
              ),
            ],
          ),
        ),
      );
    }
    if (!provider.hasData) {
      return RefreshIndicator(
        onRefresh: provider.load,
        color: context.c.secondary,
        backgroundColor: context.c.cover,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.xxl,
            AppSpacing.page,
            AppSpacing.xxxl,
          ),
          children: <Widget>[
            DiaryEmptyCard(onWrite: _openEditor),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: provider.load,
      color: context.c.secondary,
      backgroundColor: context.c.cover,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.page,
          AppSpacing.sm,
          AppSpacing.page,
          AppSpacing.xxxl,
        ),
        children: _buildGroups(provider.entries),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final DiaryProvider provider = context.watch<DiaryProvider>();
    return Scaffold(
      backgroundColor: context.c.bgDeep,
      appBar: AppBar(
        title: const Text('睡前日记'),
        actions: <Widget>[
          TextButton(
            onPressed: () => _openEditor(),
            style: TextButton.styleFrom(
              foregroundColor: context.c.textSecondary,
              textStyle: context.s.caption,
            ),
            child: const Text('写一句'),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditor(),
        backgroundColor: context.c.primary,
        foregroundColor: context.c.onGold,
        elevation: 0,
        highlightElevation: 0,
        tooltip: '写日记',
        child: const Icon(Icons.edit_outlined),
      ),
      body: AppBackground(
        tint: context.c.tintTonight,
        child: SafeArea(top: false, child: _buildBody(provider)),
      ),
    );
  }
}
