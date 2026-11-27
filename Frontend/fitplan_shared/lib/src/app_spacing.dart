import 'package:flutter/widgets.dart';

/// Spacing and corner radius scale, taken from the approved design.
abstract final class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 24.0;
  static const xxxl = 32.0;

  /// Horizontal padding of every screen.
  static const screen = EdgeInsets.symmetric(horizontal: 20);

  /// Smallest touch target (Material guideline is 48, ours is bigger for the gym).
  static const minTouch = 52.0;
}

abstract final class AppRadius {
  static const sm = 12.0;
  static const md = 16.0;
  static const button = 18.0;
  static const card = 22.0;
  static const hero = 26.0;
  static const pill = 999.0;

  static final cardBorder = BorderRadius.circular(card);
  static final buttonBorder = BorderRadius.circular(button);
}
