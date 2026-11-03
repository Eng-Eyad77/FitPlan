import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/application/auth_controller.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import '../features/exercises/presentation/exercise_picker_screen.dart';
import '../features/history/presentation/history_screen.dart';
import '../features/history/presentation/past_session_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/plans/presentation/plan_detail_screen.dart';
import '../features/plans/presentation/plans_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/session/domain/workout_session.dart';
import '../features/session/presentation/session_screen.dart';
import '../features/session/presentation/summary_screen.dart';
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
  static String planDetail(String id) => '/plans/$id';
  static String historyDetail(String id) => '/history/$id';

  /// Pops with the chosen Exercise. extra: `Set<String>` of exercise ids already added.
  static const exercisePicker = '/exercises/pick';
  static const session = '/session';

  /// extra: the SessionSummary returned when finishing.
  static const sessionSummary = '/session/summary';
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
      GoRoute(
        path: Routes.exercisePicker,
        builder: (_, state) =>
            ExercisePickerScreen(excludedIds: state.extra as Set<String>? ?? const {}),
      ),
      GoRoute(
        path: Routes.session,
        builder: (_, _) => const SessionScreen(),
        routes: [
          GoRoute(
            path: 'summary',
            // without the summary (e.g. the page was reloaded) there is nothing to show
            redirect: (_, state) => state.extra is SessionSummary ? null : Routes.home,
            builder: (_, state) => SummaryScreen(summary: state.extra! as SessionSummary),
          ),
        ],
      ),

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
              builder: (_, _) => const PlansScreen(),
              routes: [
                GoRoute(
                  path: ':id',
                  builder: (_, state) => PlanDetailScreen(planId: state.pathParameters['id']!),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: Routes.history,
              builder: (_, _) => const HistoryScreen(),
              routes: [
                GoRoute(
                  path: ':id',
                  builder: (_, state) => PastSessionScreen(sessionId: state.pathParameters['id']!),
                ),
              ],
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
