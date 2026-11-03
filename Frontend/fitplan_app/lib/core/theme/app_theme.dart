import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_text.dart';

/// Maps our tokens onto Material's ThemeData, so standard widgets
/// (TextField, FilledButton, SnackBar...) already look like FitPlan.
abstract final class AppTheme {
  static ThemeData get dark {
    const colorScheme = ColorScheme.dark(
      primary: AppColors.accent,
      onPrimary: AppColors.onAccent,
      secondary: AppColors.accentMid,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      surfaceContainerHighest: AppColors.surface2,
      outline: AppColors.border,
      error: AppColors.danger,
    );

    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: const BorderSide(color: AppColors.border),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      fontFamily: AppText.family,
      scaffoldBackgroundColor: AppColors.background,
      splashFactory: InkSparkle.splashFactory,

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: AppText.secondary.copyWith(color: AppColors.textTertiary),
        labelStyle: AppText.secondary,
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: inputBorder.copyWith(
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
        errorBorder: inputBorder.copyWith(
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        focusedErrorBorder: inputBorder.copyWith(
          borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
        ),
        errorStyle: AppText.caption.copyWith(color: AppColors.danger),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.button,
          foregroundColor: AppColors.onButton,
          disabledBackgroundColor: AppColors.button.withValues(alpha: 0.5),
          disabledForegroundColor: AppColors.onButton.withValues(alpha: 0.7),
          minimumSize: const Size.fromHeight(56),
          textStyle: AppText.button,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonBorder),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          minimumSize: const Size.fromHeight(56),
          side: const BorderSide(color: AppColors.border),
          textStyle: AppText.button.copyWith(fontWeight: FontWeight.w500),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonBorder),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accent,
          textStyle: AppText.bodyStrong,
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surface2,
        contentTextStyle: AppText.body,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        showDragHandle: true,
        dragHandleColor: AppColors.border,
      ),

      dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 1),
    );
  }
}
