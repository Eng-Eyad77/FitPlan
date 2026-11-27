import 'package:flutter/material.dart';

/// "Arctic Teal" — the FitPlan palette.
///
/// Every color has ONE job. Widgets never use raw hex values,
/// they always go through these tokens, so changing the look later
/// means changing this file only.
abstract final class AppColors {
  // Grounds
  static const background = Color(0xFF101719);
  static const surface = Color(0xFF172124); // cards
  static const surface2 = Color(0xFF1E2B2D); // inner cards, inputs, inactive bars
  static const border = Color(0xFF2A3A3C);

  // Text
  static const textPrimary = Color(0xFFEAF4F3);
  static const textSecondary = Color(0xFFA3C7C4);
  static const textTertiary = Color(0xFF7C9A97); // captions, inactive tabs

  // Accent
  static const accent = Color(0xFF36D6C5); // emphasis, active states, current set
  static const accentMid = Color(0xFF19A6A5);
  static const accentDeep = Color(0xFF087E8B);
  static const onAccent = Color(0xFF062523); // text on the bright accent

  // Primary button: muted teal with white text
  static const button = Color(0xFF226E6A);
  static const onButton = Color(0xFFFFFFFF);

  // Status
  static const success = Color(0xFFF2C46B); // personal records (warm gold)
  static const danger = Color(0xFFFF8A80);

  /// Tints used for highlighted cards and completed rows.
  static Color accentTint([double opacity = 0.06]) =>
      accent.withValues(alpha: opacity);

  /// The signature gradient. Use it ONLY where the design says:
  /// week strip, hero card strip, rest timer, completed set numbers,
  /// summary ring, chart line, current week bar.
  static const signatureGradient = LinearGradient(
    colors: [accent, accentMid, accentDeep],
  );
}
