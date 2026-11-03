import 'package:flutter/foundation.dart';

/// Where the FitPlan API lives.
///
/// Override at build time:  flutter run --dart-define=API_BASE_URL=https://api.example.com
/// Defaults (development):
/// - Web / iOS simulator / desktop -> http://localhost:5264
/// - Android emulator              -> http://10.0.2.2:5264 (the emulator's alias for the host computer)
abstract final class Env {
  static const _apiBaseUrlOverride = String.fromEnvironment('API_BASE_URL');

  static String get apiBaseUrl {
    if (_apiBaseUrlOverride.isNotEmpty) return _apiBaseUrlOverride;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:5264';
    }
    return 'http://localhost:5264';
  }
}
