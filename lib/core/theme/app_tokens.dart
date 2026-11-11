import 'package:flutter/material.dart';

import 'app_text_styles.dart';

/// v7 双主题令牌：所有页面/组件只从这里取色。
@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  const AppTokens({
    required this.bgDeep,
    required this.bgBase,
    required this.card,
    required this.glass,
    required this.border,
    required this.primary,
    required this.secondary,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.danger,
    required this.star,
    required this.tintTonight,
    required this.tintSound,
    required this.tintReport,
    required this.tintMine,
    required this.cover,
    required this.fill,
    required this.stroke,
    required this.sheet,
    required this.overlay,
    required this.onGold,
    required this.onGoldMuted,
    required this.playerGradient,
  });

  final Color bgDeep;
  final Color bgBase;
  final Color card;
  final Color glass;
  final Color border;
  final Color primary;
  final Color secondary;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color danger;
  final Color star;
  final Color tintTonight;
  final Color tintSound;
  final Color tintReport;
  final Color tintMine;
  final Color cover;
  final Color fill;
  final Color stroke;
  final Color sheet;
  final Color overlay;
  final Color onGold;
  final Color onGoldMuted;
  final List<Color> playerGradient;

  static const AppTokens dark = AppTokens(
    bgDeep: Color(0xFF070B1A),
    bgBase: Color(0xFF070B1A),
    card: Color(0xFF141B3C),
    glass: Color(0x0AFFFFFF),
    border: Color(0x14FFFFFF),
    primary: Color(0xFFF2D6A2),
    secondary: Color(0xFF8B7CF6),
    textPrimary: Color(0xFFF5F3FF),
    textSecondary: Color(0xFFA6A3C2),
    textTertiary: Color(0xFF7E7C9C),
    danger: Color(0xFFFF9AA8),
    star: Color(0xFFF5F3FF),
    tintTonight: Color(0xFF101838),
    tintSound: Color(0xFF0D1633),
    tintReport: Color(0xFF160F2E),
    tintMine: Color(0xFF101838),
    cover: Color(0xFF141B3C),
    fill: Color(0x0AFFFFFF),
    stroke: Color(0x14FFFFFF),
    sheet: Color(0xFF12152B),
    overlay: Color(0xC704060D),
    onGold: Color(0xFF070B1A),
    onGoldMuted: Color(0x9E070B1A),
    playerGradient: <Color>[
      Color(0xFF241A4A),
      Color(0xFF0C1029),
      Color(0xFF060A18),
    ],
  );

  static const AppTokens light = AppTokens(
    bgDeep: Color(0xFFF7F5FF),
    bgBase: Color(0xFFF7F5FF),
    card: Color(0xFFFFFFFF),
    glass: Color(0x0A1A1830),
    border: Color(0x141A1830),
    primary: Color(0xFFA8732A),
    secondary: Color(0xFF6F5BE8),
    textPrimary: Color(0xFF1A1830),
    textSecondary: Color(0xFF5E5B78),
    textTertiary: Color(0xFF8A87A3),
    danger: Color(0xFFB3261E),
    star: Color(0x2E1A1830),
    tintTonight: Color(0xFFEFEAFF),
    tintSound: Color(0xFFE8EEFF),
    tintReport: Color(0xFFF0E8FF),
    tintMine: Color(0xFFEFEAFF),
    cover: Color(0xFFE9E4FF),
    fill: Color(0x0A1A1830),
    stroke: Color(0x141A1830),
    sheet: Color(0xFFFFFFFF),
    overlay: Color(0x8A07101A),
    onGold: Color(0xFF141020),
    onGoldMuted: Color(0x99141020),
    playerGradient: <Color>[
      Color(0xFFF0EAFF),
      Color(0xFFF8F5FF),
      Color(0xFFFFFFFF),
    ],
  );

  @override
  AppTokens copyWith({
    Color? bgDeep,
    Color? bgBase,
    Color? card,
    Color? glass,
    Color? border,
    Color? primary,
    Color? secondary,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? danger,
    Color? star,
    Color? tintTonight,
    Color? tintSound,
    Color? tintReport,
    Color? tintMine,
    Color? cover,
    Color? fill,
    Color? stroke,
    Color? sheet,
    Color? overlay,
    Color? onGold,
    Color? onGoldMuted,
    List<Color>? playerGradient,
  }) {
    return AppTokens(
      bgDeep: bgDeep ?? this.bgDeep,
      bgBase: bgBase ?? this.bgBase,
      card: card ?? this.card,
      glass: glass ?? this.glass,
      border: border ?? this.border,
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      danger: danger ?? this.danger,
      star: star ?? this.star,
      tintTonight: tintTonight ?? this.tintTonight,
      tintSound: tintSound ?? this.tintSound,
      tintReport: tintReport ?? this.tintReport,
      tintMine: tintMine ?? this.tintMine,
      cover: cover ?? this.cover,
      fill: fill ?? this.fill,
      stroke: stroke ?? this.stroke,
      sheet: sheet ?? this.sheet,
      overlay: overlay ?? this.overlay,
      onGold: onGold ?? this.onGold,
      onGoldMuted: onGoldMuted ?? this.onGoldMuted,
      playerGradient: playerGradient ?? this.playerGradient,
    );
  }

  @override
  AppTokens lerp(covariant ThemeExtension<AppTokens>? other, double t) {
    if (other is! AppTokens) {
      return this;
    }
    return AppTokens(
      bgDeep: Color.lerp(bgDeep, other.bgDeep, t)!,
      bgBase: Color.lerp(bgBase, other.bgBase, t)!,
      card: Color.lerp(card, other.card, t)!,
      glass: Color.lerp(glass, other.glass, t)!,
      border: Color.lerp(border, other.border, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      star: Color.lerp(star, other.star, t)!,
      tintTonight: Color.lerp(tintTonight, other.tintTonight, t)!,
      tintSound: Color.lerp(tintSound, other.tintSound, t)!,
      tintReport: Color.lerp(tintReport, other.tintReport, t)!,
      tintMine: Color.lerp(tintMine, other.tintMine, t)!,
      cover: Color.lerp(cover, other.cover, t)!,
      fill: Color.lerp(fill, other.fill, t)!,
      stroke: Color.lerp(stroke, other.stroke, t)!,
      sheet: Color.lerp(sheet, other.sheet, t)!,
      overlay: Color.lerp(overlay, other.overlay, t)!,
      onGold: Color.lerp(onGold, other.onGold, t)!,
      onGoldMuted: Color.lerp(onGoldMuted, other.onGoldMuted, t)!,
      playerGradient: <Color>[
        for (int i = 0; i < playerGradient.length; i++)
          Color.lerp(
            playerGradient[i],
            other.playerGradient[i % other.playerGradient.length],
            t,
          )!,
      ],
    );
  }
}

/// 语境的 7 档排版；颜色随主题变化，字号/字重仍只来自 AppTextStyles。
class AppTextStylesX {
  const AppTextStylesX(this.c);

  final AppTokens c;

  TextStyle get display => AppTextStyles.display.copyWith(color: c.textPrimary);
  TextStyle get title => AppTextStyles.title.copyWith(color: c.textPrimary);
  TextStyle get subtitle => AppTextStyles.subtitle.copyWith(color: c.textPrimary);
  TextStyle get body => AppTextStyles.body.copyWith(color: c.textPrimary);
  TextStyle get bodySecondary =>
      AppTextStyles.bodySecondary.copyWith(color: c.textSecondary);
  TextStyle get caption => AppTextStyles.caption.copyWith(color: c.textSecondary);
  TextStyle get captionMuted =>
      AppTextStyles.captionMuted.copyWith(color: c.textTertiary);
  TextStyle get micro => AppTextStyles.micro.copyWith(color: c.textTertiary);
  TextStyle get kicker => AppTextStyles.kicker.copyWith(color: c.textTertiary);
  TextStyle get buttonLabel =>
      AppTextStyles.buttonLabel.copyWith(color: c.onGold);
  TextStyle get onGoldTitle =>
      AppTextStyles.onGoldTitle.copyWith(color: c.onGold);
  TextStyle get onGoldCaption =>
      AppTextStyles.onGoldCaption.copyWith(color: c.onGoldMuted);
}

extension AppThemeContext on BuildContext {
  AppTokens get c =>
      Theme.of(this).extension<AppTokens>() ?? AppTokens.dark;

  AppTextStylesX get s => AppTextStylesX(c);
}
