import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_text_styles.dart';
import 'app_tokens.dart';

/// 圆角只有 20 / 14 / 8 / 999 四档。
abstract final class AppRadius {
  static const double card = 20;
  static const double control = 14;
  static const double chip = 8;
  static const double pill = 999;
}

/// 间距：4 / 8 / 12 / 16 / 20 / 24 / 32。
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double page = 16;
  static const double section = 24;
}

abstract final class AppMotion {
  static const Duration base = Duration(milliseconds: 280);
  static const Duration reverse = Duration(milliseconds: 200);
  static const Curve curve = Curves.easeOutCubic;
  static const Duration welcome = Duration(milliseconds: 900);
}

/// v7 双主题：颜色全部走 AppTokens，控件形状/字号两套共用。
abstract final class AppTheme {
  static ThemeData get dark => _theme(AppTokens.dark, Brightness.dark);

  static ThemeData get light => _theme(AppTokens.light, Brightness.light);

  static ThemeData _theme(AppTokens t, Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: t.secondary,
      brightness: brightness,
    ).copyWith(
      primary: t.primary,
      secondary: t.secondary,
      surface: t.bgDeep,
      onSurface: t.textPrimary,
      error: t.danger,
    );

    return _base(scheme, t).copyWith(
      scaffoldBackgroundColor: t.bgDeep,
      canvasColor: t.bgDeep,
      textTheme: _textTheme(t),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: t.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.title.copyWith(color: t.textPrimary),
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardTheme(
        color: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: BorderSide(color: t.stroke),
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: t.sheet,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: t.sheet,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.card),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: t.sheet,
        contentTextStyle: AppTextStyles.body.copyWith(color: t.textPrimary),
        behavior: SnackBarBehavior.floating,
      ),
      iconTheme: IconThemeData(color: t.textSecondary),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: t.primary),
      dividerTheme: DividerThemeData(color: t.stroke, thickness: 1),
    );
  }

  static TextTheme _textTheme(AppTokens t) {
    return TextTheme(
      displayLarge: AppTextStyles.display.copyWith(color: t.textPrimary),
      headlineSmall: AppTextStyles.title.copyWith(color: t.textPrimary),
      titleMedium: AppTextStyles.subtitle.copyWith(color: t.textPrimary),
      bodyMedium: AppTextStyles.body.copyWith(color: t.textPrimary),
      bodySmall: AppTextStyles.caption.copyWith(color: t.textSecondary),
      labelSmall: AppTextStyles.micro.copyWith(color: t.textTertiary),
    );
  }

  static ThemeData _base(ColorScheme scheme, AppTokens t) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      extensions: <ThemeExtension<dynamic>>[t],
      splashFactory: InkRipple.splashFactory,
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: t.primary,
          foregroundColor: t.onGold,
          disabledBackgroundColor: t.textTertiary,
          disabledForegroundColor: t.onGold,
          minimumSize: const Size.fromHeight(44),
          elevation: 0,
          textStyle: AppTextStyles.buttonLabel.copyWith(color: t.onGold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.control),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: t.textPrimary,
          side: BorderSide(color: t.stroke),
          minimumSize: const Size.fromHeight(44),
          textStyle: AppTextStyles.body.copyWith(color: t.textPrimary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.control),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: t.textSecondary,
          textStyle: AppTextStyles.body.copyWith(color: t.textSecondary),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: t.fill,
        hintStyle: AppTextStyles.caption.copyWith(color: t.textTertiary),
        labelStyle: AppTextStyles.bodySecondary.copyWith(color: t.textSecondary),
        errorStyle: AppTextStyles.caption.copyWith(color: t.danger),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        border: _inputBorder(t.stroke),
        enabledBorder: _inputBorder(t.stroke),
        focusedBorder: _inputBorder(t.secondary),
        errorBorder: _inputBorder(t.danger),
        focusedErrorBorder: _inputBorder(t.danger),
      ),
    );
  }

  static OutlineInputBorder _inputBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.control),
      borderSide: BorderSide(color: color),
    );
  }
}
