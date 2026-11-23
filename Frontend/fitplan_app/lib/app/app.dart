import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import '../features/auth/presentation/recovery_code_notice.dart';
import '../features/session/application/rest_timer.dart';
import '../l10n/l10n.dart';
import 'router.dart';

class FitPlanApp extends ConsumerStatefulWidget {
  const FitPlanApp({super.key});

  @override
  ConsumerState<FitPlanApp> createState() => _FitPlanAppState();
}

class _FitPlanAppState extends ConsumerState<FitPlanApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // the phone's language changed while the app was open ("same as phone" follows it)
  @override
  void didChangeLocales(List<Locale>? locales) => setState(() {});

  @override
  Widget build(BuildContext context) {
    // The rest timer runs from launch, not only on the workout screen: it clears the rest
    // notifications when the app opens on any screen, and handles their buttons (Phase 9).
    ref.listen(restTimerProvider, (_, _) {});
    final locale = resolveLocale(
      ref.watch(languageProvider),
      WidgetsBinding.instance.platformDispatcher.locale,
    );
    useStrings(locale);

    return MaterialApp.router(
      title: 'FitPlan',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: ref.watch(routerProvider),
      builder: (context, child) => _RebuildOnLanguage(
        locale: locale,
        child: DismissKeyboard(
          child: RecoveryCodeNotice(child: child ?? const SizedBox.shrink()),
        ),
      ),
    );
  }
}

/// Screens read their text from [l10n], which doesn't tell Flutter when it changes.
/// So when the language changes, every widget on screen (open sheets included) builds again.
class _RebuildOnLanguage extends StatefulWidget {
  const _RebuildOnLanguage({required this.locale, required this.child});

  final Locale locale;
  final Widget child;

  @override
  State<_RebuildOnLanguage> createState() => _RebuildOnLanguageState();
}

class _RebuildOnLanguageState extends State<_RebuildOnLanguage> {
  @override
  void didUpdateWidget(_RebuildOnLanguage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.locale != widget.locale) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        void rebuild(Element element) {
          element.markNeedsBuild();
          element.visitChildren(rebuild);
        }

        (context as Element).visitChildren(rebuild);
      });
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Tapping anywhere outside a text field closes the keyboard.
/// The iPhone number pad has no Done key, so without this it stays open over the screen.
/// Buttons and fields still get their taps first.
class DismissKeyboard extends StatelessWidget {
  const DismissKeyboard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: child,
    );
  }
}
