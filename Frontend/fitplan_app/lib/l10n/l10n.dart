/// The app's language (Phase 11): which one is chosen, and the strings for it.
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

import 'generated/app_localizations.dart';

export 'generated/app_localizations.dart';

/// The strings for the language on screen. Screens, notifications and formatters all read it,
/// so code without a BuildContext (controllers, notifications) speaks the same language.
/// The app sets it whenever the language changes and rebuilds every screen (see [FitPlanApp]).
/// Tests that don't set it get English.
AppLocalizations get l10n => _current;
AppLocalizations _current = lookupAppLocalizations(const Locale('en'));

/// True while the app is in Arabic: for the few places that need more than a string.
bool get isArabic => _current.localeName == 'ar';

void useStrings(Locale locale) {
  _current = lookupAppLocalizations(locale);
  // dates and numbers follow the language; Arabic still uses Western digits (0–9), as agreed
  Intl.defaultLocale = locale.languageCode;
  // intl writes Arabic dates with Arabic-Indic digits (٢٣) unless told otherwise
  DateFormat.useNativeDigitsByDefaultFor('ar', false);
}

/// "+2.5" or "−12%" kept as one left-to-right piece, so Arabic doesn't move the sign to the far side.
String signed(String text) => isArabic ? '\u2066$text\u2069' : text;

/// What the user picked in Profile. [system] follows the phone.
enum AppLanguage { system, english, arabic }

/// The language shown for a choice, on a phone set to [device].
Locale resolveLocale(AppLanguage choice, Locale device) => switch (choice) {
      AppLanguage.english => const Locale('en'),
      AppLanguage.arabic => const Locale('ar'),
      AppLanguage.system => device.languageCode == 'ar' ? const Locale('ar') : const Locale('en'),
    };

/// Read before the first frame (see main.dart), so the app never flashes in the other language.
final initialLanguageProvider = Provider<AppLanguage>((ref) => AppLanguage.system);

final languageProvider = NotifierProvider<LanguageController, AppLanguage>(LanguageController.new);

class LanguageController extends Notifier<AppLanguage> {
  static const _key = 'fitplan.language';
  static const _storage = FlutterSecureStorage();

  @override
  AppLanguage build() => ref.watch(initialLanguageProvider);

  Future<void> choose(AppLanguage language) async {
    state = language;
    try {
      await _storage.write(key: _key, value: language.name);
    } catch (_) {
      // the choice still applies until the app closes
    }
  }

  static Future<AppLanguage> load() async {
    try {
      final saved = await _storage.read(key: _key);
      return AppLanguage.values.firstWhere((l) => l.name == saved, orElse: () => AppLanguage.system);
    } catch (_) {
      return AppLanguage.system;
    }
  }
}
