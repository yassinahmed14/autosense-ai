import 'package:autosense_ai/core/theme/app_colors.dart';
import 'package:autosense_ai/core/theme/app_spacing.dart';
import 'package:autosense_ai/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// Builds the Material 3 light [ThemeData] from the design tokens.
abstract final class AppTheme {
  /// Light [ColorScheme]: seeded from racing yellow, then every role that the
  /// app uses is pinned explicitly to an [AppColors] token.
  static final ColorScheme colorScheme = ColorScheme.fromSeed(
    seedColor: AppColors.brandYellow,
    brightness: Brightness.light,
  ).copyWith(
    primary: AppColors.brandYellow,
    onPrimary: AppColors.onBrandYellow,
    primaryContainer: AppColors.primaryContainer,
    onPrimaryContainer: AppColors.onPrimaryContainer,
    secondary: AppColors.carbon,
    onSecondary: AppColors.onCarbon,
    secondaryContainer: AppColors.surfaceContainer,
    onSecondaryContainer: AppColors.carbon,
    tertiary: AppColors.info,
    onTertiary: AppColors.onCarbon,
    tertiaryContainer: AppColors.infoContainer,
    onTertiaryContainer: AppColors.onInfoContainer,
    error: AppColors.error,
    onError: AppColors.onError,
    errorContainer: AppColors.errorContainer,
    onErrorContainer: AppColors.onErrorContainer,
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
    onSurfaceVariant: AppColors.textSecondary,
    surfaceDim: AppColors.surfaceContainer,
    surfaceBright: AppColors.surface,
    surfaceContainerLowest: AppColors.surface,
    surfaceContainerLow: AppColors.background,
    surfaceContainer: AppColors.surfaceContainer,
    surfaceContainerHigh: AppColors.surfaceContainer,
    surfaceContainerHighest: AppColors.surfaceContainer,
    outline: AppColors.outline,
    outlineVariant: AppColors.outline,
    inverseSurface: AppColors.carbon,
    onInverseSurface: AppColors.onCarbon,
    inversePrimary: AppColors.brandYellow,
    shadow: AppColors.carbon,
    scrim: AppColors.carbon,
    surfaceTint: Colors.transparent,
  );

  /// The single app theme. Used by the main app and the subscription overlay.
  static ThemeData light() {
    final textTheme = AppTypography.textTheme();
    const buttonShape = RoundedRectangleBorder(borderRadius: AppRadius.medium);
    const buttonSize = Size(AppSpacing.minTouchTarget, AppSpacing.buttonHeight);
    const inputBorder = OutlineInputBorder(
      borderRadius: AppRadius.small,
      borderSide: BorderSide(color: AppColors.outline),
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      fontFamily: AppTypography.body,
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.background,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppColors.carbon,
        selectionColor: AppColors.brandYellow.withValues(alpha: 0.45),
        selectionHandleColor: AppColors.brandInk,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.carbon,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        shape: const Border(bottom: BorderSide(color: AppColors.outline)),
        titleTextStyle: textTheme.titleLarge,
        iconTheme: const IconThemeData(color: AppColors.carbon),
        actionsIconTheme: const IconThemeData(color: AppColors.carbon),
      ),
      iconTheme: const IconThemeData(color: AppColors.carbon),
      cardTheme: const CardThemeData(
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.symmetric(vertical: AppSpacing.xs),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.large,
          side: BorderSide(color: AppColors.outline),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: buttonSize,
          shape: buttonShape,
          backgroundColor: AppColors.brandYellow,
          foregroundColor: AppColors.onBrandYellow,
          disabledBackgroundColor: AppColors.surfaceContainer,
          disabledForegroundColor: AppColors.textSecondary,
          textStyle: textTheme.labelLarge,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: buttonSize,
          shape: buttonShape,
          foregroundColor: AppColors.carbon,
          backgroundColor: AppColors.surface,
          disabledForegroundColor: AppColors.textSecondary,
          side: const BorderSide(color: AppColors.carbon, width: 1.5),
          textStyle: textTheme.labelLarge,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        ).copyWith(
          side: WidgetStateProperty.resolveWith((states) => BorderSide(
              color: states.contains(WidgetState.disabled)
                  ? AppColors.outline
                  : AppColors.carbon,
              width: 1.5)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize:
              const Size(AppSpacing.minTouchTarget, AppSpacing.minTouchTarget),
          foregroundColor: AppColors.brandInk,
          shape: buttonShape,
          textStyle: textTheme.labelLarge,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize:
              const Size(AppSpacing.minTouchTarget, AppSpacing.minTouchTarget),
          foregroundColor: AppColors.carbon,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        border: inputBorder,
        enabledBorder: inputBorder,
        disabledBorder: inputBorder.copyWith(
            borderSide: const BorderSide(color: AppColors.surfaceContainer)),
        focusedBorder: inputBorder.copyWith(
            borderSide:
                const BorderSide(color: AppColors.brandYellow, width: 2)),
        errorBorder: inputBorder.copyWith(
            borderSide: const BorderSide(color: AppColors.error)),
        focusedErrorBorder: inputBorder.copyWith(
            borderSide: const BorderSide(color: AppColors.error, width: 2)),
        labelStyle:
            textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
        floatingLabelStyle:
            textTheme.bodyLarge?.copyWith(color: AppColors.brandInk),
        helperStyle:
            textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
        prefixIconColor: AppColors.textSecondary,
        helperMaxLines: 3,
        errorMaxLines: 3,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.brandYellow,
        checkmarkColor: AppColors.onBrandYellow,
        labelStyle: textTheme.labelLarge?.copyWith(color: AppColors.carbon),
        secondaryLabelStyle:
            textTheme.labelLarge?.copyWith(color: AppColors.onBrandYellow),
        side: const BorderSide(color: AppColors.outline),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.small),
        padding: const EdgeInsets.all(AppSpacing.sm),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(AppSpacing.xs))),
        side: const BorderSide(color: AppColors.textSecondary, width: 2),
        checkColor: const WidgetStatePropertyAll(AppColors.onBrandYellow),
        fillColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? AppColors.brandYellow
                : Colors.transparent),
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: AppColors.textSecondary,
        textColor: AppColors.textPrimary,
        selectedColor: AppColors.brandInk,
        minVerticalPadding: AppSpacing.md,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.small),
      ),
      expansionTileTheme: const ExpansionTileThemeData(
        shape: Border(),
        collapsedShape: Border(),
        iconColor: AppColors.brandInk,
        textColor: AppColors.carbon,
        collapsedIconColor: AppColors.textSecondary,
        collapsedTextColor: AppColors.carbon,
        tilePadding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        childrenPadding: EdgeInsets.only(bottom: AppSpacing.md),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.brandInk,
        linearTrackColor: AppColors.surfaceContainer,
        circularTrackColor: AppColors.surfaceContainer,
      ),
      dividerTheme: const DividerThemeData(
          color: AppColors.outline, thickness: 1, space: 1),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        iconColor: AppColors.brandInk,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.extraLarge),
        titleTextStyle: textTheme.headlineSmall,
        contentTextStyle: textTheme.bodyMedium,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.carbon,
        actionTextColor: AppColors.brandYellow,
        contentTextStyle:
            textTheme.bodyMedium?.copyWith(color: AppColors.onCarbon),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.small),
      ),
      dropdownMenuTheme: const DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(AppColors.surface),
          surfaceTintColor: WidgetStatePropertyAll(Colors.transparent),
        ),
      ),
      popupMenuTheme: const PopupMenuThemeData(
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.small),
      ),
    );
  }
}
