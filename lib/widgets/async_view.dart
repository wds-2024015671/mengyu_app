import 'package:mengyu_app/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import 'empty_state.dart';

/// 四态视图：loading / error / empty / data。
///
/// 为什么“有旧数据时不显示全屏 loading”：下拉刷新时列表还在，
/// 直接盖一层转圈会让页面闪一下；因此 loading 只在 data 为空时占满。
/// 同理，刷新失败但已有数据时保留数据，错误交给页面的 SnackBar。
class AsyncView<T> extends StatelessWidget {
  const AsyncView({
    super.key,
    required this.isLoading,
    required this.data,
    required this.builder,
    this.error,
    this.onRetry,
    this.isEmpty,
    this.empty,
    this.loadingLabel = '正在加载',
    this.errorTitle = '加载失败',
    this.padding = const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
  });

  final bool isLoading;

  /// 数据态。为 null 时不会调用 builder。
  final T? data;

  /// 数据态构建器；只有 data 非空且不空列表时才调用。
  final Widget Function(BuildContext context, T data) builder;

  /// 错误文案；非空且没有旧数据时展示错误态。
  final String? error;

  /// 重试回调；为空则不显示重试按钮。
  final VoidCallback? onRetry;

  /// 数据为空判断；不传时按 data == null 处理。
  final bool? isEmpty;

  /// 自定义空态；不传用默认 EmptyState。
  final Widget? empty;

  final String loadingLabel;
  final String errorTitle;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final T? value = data;

    if (error != null && value == null) {
      return EmptyState(
        icon: Icons.cloud_off_outlined,
        title: errorTitle,
        message: error,
        actionLabel: onRetry == null ? null : '重试',
        onAction: onRetry,
      );
    }

    if (isLoading && value == null) {
      return Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(loadingLabel, style: context.s.captionMuted),
          ],
        ),
      );
    }

    if (value == null || (isEmpty ?? false)) {
      return empty ??
          const EmptyState(
            icon: Icons.nightlight_outlined,
            title: '这里还是空的',
            message: '等一等，或换个筛选条件再试试。',
          );
    }

    return builder(context, value);
  }
}
