import 'package:fitplan_shared/fitplan_shared.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/admin_api.dart';
import 'screens/admins_screen.dart';
import 'screens/coming_soon_screen.dart';
import 'screens/shell.dart';
import 'screens/sign_in_screen.dart';

class AdminApp extends StatefulWidget {
  const AdminApp({super.key, required this.api});

  final AdminApi api;

  @override
  State<AdminApp> createState() => _AdminAppState();
}

class _AdminAppState extends State<AdminApp> {
  late final GoRouter _router = GoRouter(
    // the only finished area for now (12A); Overview becomes the start page in 12E
    initialLocation: AdminArea.admins.path,
    refreshListenable: widget.api.session,
    redirect: (context, state) {
      final signedIn = widget.api.session.value != null;
      final atSignIn = state.matchedLocation == '/sign-in';
      if (!signedIn && !atSignIn) {
        return Uri(path: '/sign-in', queryParameters: {'from': state.uri.toString()}).toString();
      }
      if (signedIn && atSignIn) {
        final from = state.uri.queryParameters['from'];
        // only a path inside this site, never another address
        return from != null && from.startsWith('/') && !from.startsWith('//') ? from : AdminArea.admins.path;
      }
      return null;
    },
    routes: [
      GoRoute(path: '/sign-in', builder: (context, state) => SignInScreen(api: widget.api)),
      ShellRoute(
        builder: (context, state, child) => AdminShell(api: widget.api, location: state.matchedLocation, child: child),
        routes: [
          for (final area in AdminArea.values)
            GoRoute(
              path: area.path,
              pageBuilder: (context, state) => NoTransitionPage(
                child: area == AdminArea.admins ? AdminsScreen(api: widget.api) : ComingSoonScreen(area: area),
              ),
            ),
        ],
      ),
    ],
  );

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = AppTheme.dark;
    final corners = WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)));
    return MaterialApp.router(
      title: 'FitPlan Admin',
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      // the phone theme with desktop-sized buttons
      theme: base.copyWith(
        filledButtonTheme: FilledButtonThemeData(
          style: base.filledButtonTheme.style!.copyWith(minimumSize: const WidgetStatePropertyAll(Size(0, 46)), shape: corners),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: base.outlinedButtonTheme.style!.copyWith(minimumSize: const WidgetStatePropertyAll(Size(0, 42)), shape: corners),
        ),
      ),
    );
  }
}
