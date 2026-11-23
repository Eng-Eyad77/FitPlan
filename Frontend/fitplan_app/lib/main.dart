import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/app.dart';
import 'l10n/l10n.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // every screen is laid out for a phone held upright
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // Arabic and English month and day names, for DateFormat outside the widget tree too
  await initializeDateFormatting();
  final language = await LanguageController.load();
  // strings are ready before the first frame, so notifications and the launch screen match
  useStrings(resolveLocale(language, WidgetsBinding.instance.platformDispatcher.locale));
  runApp(ProviderScope(
    overrides: [initialLanguageProvider.overrideWithValue(language)],
    child: const FitPlanApp(),
  ));
}
