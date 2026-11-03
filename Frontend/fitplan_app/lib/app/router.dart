import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/application/auth_controller.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../shared/widgets/coming_soon_screen.dart';
import 'main_shell.dart';
import 'splash_screen.dart';

abstract final class Routes {
  static const splash = '/splash';
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const plans = '/plans';
  static const history = '/history';
  static const progress = '/progress';
  static const profile = '/profile';
}

final routerProvider = Provider<GoRouter>((ref) {
  // go_router re-runs `redirect` whenever this notifier changes,
  // so logging in or out moves the user automatically.
  final auth = ValueNotifier(ref.read(authControllerProvider));
  ref.listen(authControllerProvider, (_, next) => auth.value = next);
  ref.onDispose(auth.dispose);

  return GoRouter(
    initialLocation: Routes.splash,
    refreshListenable: auth,
    redirect: (context, state) {
      final session = auth.value;
      final location = state.matchedLocation;

      // still reading the saved session
      if (session.isLoading && !session.hasValue) return Routes.splash;

      final loggedIn = session.value != null;
      final onAuthScreen = location == Routes.login || location == Routes.register;

      if (!loggedIn) return onAuthScreen ? null : Routes.login;
      if (onAuthScreen || location == Routes.splash) return Routes.home;
      return null;
    },
    routes: [
      GoRoute(path: Routes.splash, builder: (_, _) => const SplashScreen()),
      GoRoute(path: Routes.login, builder: (_, _) => const LoginScreen()),
      GoRoute(path: Routes.register, builder: (_, _) => const RegisterScreen()),
      // outside the tab shell: covers the tab bar, with a back button
      GoRoute(path: Routes.profile, builder: (_, _) => const ProfileScreen()),

      // the 4 tabs; each keeps its own navigation stack
      StatefulShellRoute.indexedStack(
        builder: (_, _, navigationShell) => MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: Routes.home, builder: (_, _) => const HomeScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: Routes.plans,
              builder: (_, _) => const ComingSoonScreen(title: 'Plans'),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: Routes.history,
              builder: (_, _) => const ComingSoonScreen(title: 'History'),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: Routes.progress,
              builder: (_, _) => const ComingSoonScreen(title: 'Progress'),
            ),
          ]),
        ],
      ),
    ],
  );
});
