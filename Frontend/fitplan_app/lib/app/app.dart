import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import '../features/auth/presentation/recovery_code_notice.dart';
import '../features/session/application/rest_timer.dart';
import '../shared/widgets/waking_server_banner.dart';
import 'router.dart';

class FitPlanApp extends ConsumerWidget {
  const FitPlanApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // The rest timer runs from launch, not only on the workout screen: it clears the rest
    // notifications when the app opens on any screen, and handles their buttons (Phase 9).
    ref.listen(restTimerProvider, (_, _) {});
    return MaterialApp.router(
      title: 'FitPlan',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      routerConfig: ref.watch(routerProvider),
      builder: (context, child) => DismissKeyboard(
        child: WakingServerBanner(child: RecoveryCodeNotice(child: child ?? const SizedBox.shrink())),
      ),
    );
  }
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
