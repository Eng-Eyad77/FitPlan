import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Typography. One family (Readex Pro: Latin + Arabic, ready for later).
///
/// Rule from the design review: nothing smaller than 12px.
abstract final class AppText {
  static const family = 'ReadexPro';

  /// Numbers (weights, reps, timers) never jump around when they change.
  static const _tabular = [FontFeature.tabularFigures()];

  // Big numbers: "87.8", "67.5"
  static const display = TextStyle(
    fontFamily: family,
    fontSize: 48,
    fontWeight: FontWeight.w600,
    height: 1,
    letterSpacing: -1.2,
    color: AppColors.textPrimary,
    fontFeatures: _tabular,
  );

  // Screen titles: "Ready to train?"
  static const title = TextStyle(
    fontFamily: family,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 1.15,
    letterSpacing: -0.6,
    color: AppColors.textPrimary,
  );

  // Card titles: "This week", "Last session"
  static const heading = TextStyle(
    fontFamily: family,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Set row values: "60", "10"
  static const number = TextStyle(
    fontFamily: family,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    fontFeatures: _tabular,
  );

  static const body = TextStyle(
    fontFamily: family,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  static const bodyStrong = TextStyle(
    fontFamily: family,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const secondary = TextStyle(
    fontFamily: family,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.textSecondary,
  );

  // "UP NEXT", "LAST SESSION"
  static const overline = TextStyle(
    fontFamily: family,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.4,
    color: AppColors.accent,
  );

  static const caption = TextStyle(
    fontFamily: family,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
  );

  static const button = TextStyle(
    fontFamily: family,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );
}
