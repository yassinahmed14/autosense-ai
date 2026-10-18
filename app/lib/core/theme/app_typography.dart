import 'package:autosense_ai/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Type scale. Display/headline/title-large and numeric readouts use the
/// bundled **Saira** (SemiBold/Bold, motorsport-technical); body and labels
/// use the bundled **Inter** (Regular/Medium/SemiBold). Both are OFL fonts
/// shipped in `assets/fonts/` – nothing is downloaded at runtime.
abstract final class AppTypography {
  /// Display / numeric font family.
  static const display = 'Saira';

  /// Body / label font family.
  static const body = 'Inter';

  /// Builds the app [TextTheme] in [AppColors.textPrimary].
  static TextTheme textTheme() => const TextTheme(
        displaySmall: TextStyle(
            fontFamily: display,
            fontSize: 36,
            height: 44 / 36,
            fontWeight: FontWeight.w700),
        headlineMedium: TextStyle(
            fontFamily: display,
            fontSize: 28,
            height: 36 / 28,
            fontWeight: FontWeight.w700),
        headlineSmall: TextStyle(
            fontFamily: display,
            fontSize: 24,
            height: 32 / 24,
            fontWeight: FontWeight.w600),
        titleLarge: TextStyle(
            fontFamily: display,
            fontSize: 20,
            height: 28 / 20,
            fontWeight: FontWeight.w600),
        titleMedium: TextStyle(
            fontFamily: body,
            fontSize: 16,
            height: 24 / 16,
            fontWeight: FontWeight.w600),
        titleSmall: TextStyle(
            fontFamily: body,
            fontSize: 14,
            height: 20 / 14,
            fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(
            fontFamily: body,
            fontSize: 16,
            height: 24 / 16,
            fontWeight: FontWeight.w400),
        bodyMedium: TextStyle(
            fontFamily: body,
            fontSize: 14,
            height: 20 / 14,
            fontWeight: FontWeight.w400),
        bodySmall: TextStyle(
            fontFamily: body,
            fontSize: 12,
            height: 16 / 12,
            fontWeight: FontWeight.w400),
        labelLarge: TextStyle(
            fontFamily: body,
            fontSize: 14,
            height: 20 / 14,
            fontWeight: FontWeight.w600),
        labelMedium: TextStyle(
            fontFamily: body,
            fontSize: 12,
            height: 16 / 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5),
        labelSmall: TextStyle(
            fontFamily: body,
            fontSize: 11,
            height: 16 / 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5),
      ).apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      );

  /// Large numeric readout inside the RPM gauge.
  static const gaugeValue = TextStyle(
    fontFamily: display,
    fontSize: 56,
    height: 1.1,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// Numeric readout used by metric cards.
  static const metricValue = TextStyle(
    fontFamily: display,
    fontSize: 30,
    height: 36 / 30,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// Upper-case, letter-spaced spec-sheet label (section eyebrows, gauge
  /// caption). Colour it [AppColors.brandInk] or `textSecondary`.
  static const eyebrow = TextStyle(
    fontFamily: body,
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 2,
  );
}
