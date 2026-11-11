import 'package:flutter/material.dart';

/// v7 字号只有 7 档：28 / 20 / 16 / 13 / 11 / 10 / 9。
///
/// 页面只使用这些命名，不在页面里写 fontSize；
/// 中文 ≤10 不加字距，只有英文 kicker 用 letterSpacing。
abstract final class AppTextStyles {
  /// 28/500 —— 今晚问候、页面主数字。
  static const TextStyle display = TextStyle(
    fontSize: 28,
    height: 1.4,
    fontWeight: FontWeight.w500,
  );

  /// 20/600 —— 页面与区块标题。
  static const TextStyle title = TextStyle(
    fontSize: 20,
    height: 1.4,
    fontWeight: FontWeight.w600,
  );

  /// 16/500 —— 卡片标题、CTA、数字。
  static const TextStyle subtitle = TextStyle(
    fontSize: 16,
    height: 1.5,
    fontWeight: FontWeight.w500,
  );

  /// 13/400 —— 正文与菜单。
  static const TextStyle body = TextStyle(
    fontSize: 13,
    height: 1.6,
  );

  /// 11/400 —— 辅助信息与文字链。
  static const TextStyle caption = TextStyle(
    fontSize: 11,
    height: 1.5,
  );

  static const TextStyle bodySecondary = TextStyle(
    fontSize: 13,
    height: 1.6,
  );

  static const TextStyle captionMuted = TextStyle(
    fontSize: 11,
    height: 1.5,
  );

  /// 10/500 —— 标签与注释。
  static const TextStyle micro = TextStyle(
    fontSize: 10,
    height: 1.4,
    fontWeight: FontWeight.w500,
  );

  /// 9/500 —— 仅英文 kicker。
  static const TextStyle kicker = TextStyle(
    fontSize: 9,
    height: 2,
    fontWeight: FontWeight.w500,
    letterSpacing: 2,
  );

  /// 金色主操作上的深色文字：13/600。
  static const TextStyle buttonLabel = TextStyle(
    fontSize: 13,
    height: 1.5,
    fontWeight: FontWeight.w600,
  );

  /// 金色 CTA 上的 16/600 标题与 11 副标题。
  static const TextStyle onGoldTitle = TextStyle(
    fontSize: 16,
    height: 1.5,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle onGoldCaption = TextStyle(
    fontSize: 11,
    height: 1.5,
  );
}
