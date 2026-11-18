import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import '../shared/widgets/waking_server_banner.dart';
import 'router.dart';

class FitPlanApp extends ConsumerWidget {
  const FitPlanApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'FitPlan',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      routerConfig: ref.watch(routerProvider),
      builder: (context, child) => WakingServerBanner(child: child ?? const SizedBox.shrink()),
    );
  }
}
