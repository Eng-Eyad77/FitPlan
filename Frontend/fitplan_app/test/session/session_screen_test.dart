import 'package:dio/dio.dart';
import 'package:fitplan_app/app/router.dart';
import 'package:fitplan_app/core/network/api_exception.dart';
import 'package:fitplan_app/core/storage/session_storage.dart';
import 'package:fitplan_app/features/auth/domain/auth_session.dart';
import 'package:fitplan_app/features/plans/data/plans_repository.dart';
import 'package:fitplan_app/features/plans/domain/workout_plan.dart';
import 'package:fitplan_app/features/plans/presentation/target_sheet.dart';
import 'package:fitplan_app/features/session/application/plan_additions.dart';
import 'package:fitplan_app/features/session/application/rest_timer.dart';
import 'package:fitplan_app/features/session/data/sessions_repository.dart';
import 'package:fitplan_app/features/session/domain/workout_session.dart';
import 'package:fitplan_app/features/session/presentation/session_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

// Phase 7: fixed order, one open card, kept typing, rest per exercise, the finish flow.

SessionExercise _ex(String id, int order, {int? targetSets, int? restSeconds, int logged = 0, int reps = 10}) =>
    SessionExercise(
      id: id,
      exerciseId: 'x-$id',
      name: id,
      gifUrl: '',
      bodyPart: 'chest',
      order: order,
      targetSets: targetSets,
      targetReps: targetSets == null ? null : 10,
      restSeconds: restSeconds,
      sets: [for (var i = 1; i <= logged; i++) SessionSet(id: '$id-s$i', setNumber: i, reps: reps, weightKg: 50)],
    );

class _FakeSessions extends SessionsRepository {
  _FakeSessions(this.session) : super(Dio());

  WorkoutSession? session;
  final rests = <String, int?>{};
  var completed = false;

  @override
  Future<WorkoutSession?> getActive() async => session;

  @override
  Future<SessionSet> addSet(String sessionId, String sessionExerciseId, {required int reps, double? weightKg}) async {
    final e = session!.exercises.firstWhere((e) => e.id == sessionExerciseId);
    return SessionSet(id: '${e.id}-new${e.sets.length}', setNumber: e.sets.length + 1, reps: reps, weightKg: weightKg);
  }

  @override
  Future<void> updateRest(String sessionId, String sessionExerciseId, int? restSeconds) async =>
      rests[sessionExerciseId] = restSeconds;

  @override
  Future<SessionSummary> complete(String id, {String? notes}) async {
    completed = true;
    return SessionSummary(
      id: id,
      name: session!.name,
      startedAt: session!.startedAt,
      completedAt: DateTime.now(),
      durationSeconds: 600,
      exerciseCount: session!.exercises.length,
      setCount: session!.setCount,
      totalVolumeKg: 0,
      cardioDurationSeconds: 0,
      estimatedCalories: 0,
    );
  }
}

class _FakePlans extends PlansRepository {
  _FakePlans({this.inPlan = const [], this.deleted = false}) : super(Dio());

  final List<String> inPlan;
  final bool deleted;
  final added = <({String exerciseId, int sets, int reps, int? rest})>[];

  @override
  Future<List<PlanExercise>> getExercises(String planId) async {
    if (deleted) throw const ApiException(code: 'WorkoutPlanNotFound', message: 'gone', statusCode: 404);
    return [
      for (final (i, id) in inPlan.indexed)
        PlanExercise(id: 'pe$i', exerciseId: id, name: id, gifUrl: '', bodyPart: 'chest', sets: 3, reps: 10, order: i + 1),
    ];
  }

  @override
  Future<PlanExercise> addExercise(String planId,
      {required String exerciseId, required int sets, required int reps, required int order, int? restSeconds}) async {
    added.add((exerciseId: exerciseId, sets: sets, reps: reps, rest: restSeconds));
    return PlanExercise(
        id: 'new', exerciseId: exerciseId, name: '', gifUrl: '', bodyPart: '', sets: sets, reps: reps, order: order);
  }
}

class _MemoryTimerStore extends RestTimerStore {
  _MemoryTimerStore([this.saved]) : super(const FlutterSecureStorage());

  RestTimer? saved;

  @override
  Future<RestTimer?> read() async => saved;

  @override
  Future<void> write(RestTimer? timer) async => saved = timer;
}

class _NoAuth extends SessionStorage {
  _NoAuth() : super(const FlutterSecureStorage());

  @override
  Future<AuthSession?> read() async => null;
}

WorkoutSession _session(List<SessionExercise> exercises, {String? planId, List<CardioEntry> cardio = const []}) =>
    WorkoutSession(
      id: 's1',
      name: 'Legs',
      workoutPlanId: planId,
      startedAt: DateTime.now(),
      exercises: exercises,
      cardio: cardio,
    );

typedef _Setup = ({_FakeSessions sessions, _FakePlans plans, _MemoryTimerStore timers, ProviderContainer container});

Future<_Setup> _open(WidgetTester tester, WorkoutSession session, {_FakePlans? plans}) async {
  final sessions = _FakeSessions(session);
  final planRepo = plans ?? _FakePlans();
  final timers = _MemoryTimerStore();
  final container = ProviderContainer(overrides: [
    sessionsRepositoryProvider.overrideWithValue(sessions),
    plansRepositoryProvider.overrideWithValue(planRepo),
    restTimerStoreProvider.overrideWithValue(timers),
    sessionStorageProvider.overrideWithValue(_NoAuth()),
  ]);
  addTearDown(container.dispose);

  final router = GoRouter(initialLocation: '/start', routes: [
    GoRoute(path: '/start', builder: (_, _) => const Scaffold(body: Text('start'))),
    GoRoute(path: Routes.session, builder: (_, _) => const SessionScreen()),
    GoRoute(path: Routes.sessionSummary, builder: (_, _) => const Scaffold(body: Text('summary page'))),
  ]);
  addTearDown(router.dispose);

  await tester.binding.setSurfaceSize(const Size(420, 1400));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(UncontrolledProviderScope(
    container: container,
    child: MaterialApp.router(routerConfig: router),
  ));
  router.push(Routes.session);
  await _settle(tester);
  return (sessions: sessions, plans: planRepo, timers: timers, container: container);
}

/// The workout clock ticks every second, so pumpAndSettle would never finish.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

double _top(WidgetTester tester, String text) => tester.getTopLeft(find.textContaining(text).first).dy;

void main() {
  testWidgets('the list keeps the saved order and only one card is open', (tester) async {
    await _open(tester, _session([_ex('alpha', 1, targetSets: 2), _ex('bravo', 2, targetSets: 2), _ex('charlie', 3)]));

    // the first exercise not done is open and marked
    expect(find.byTooltip('Close Alpha'), findsOneWidget);
    expect(find.text('NOW'), findsOneWidget);
    expect(_top(tester, 'Alpha'), lessThan(_top(tester, '2. Bravo')));
    expect(_top(tester, '2. Bravo'), lessThan(_top(tester, '3. Charlie')));

    await tester.tap(find.text('3. Charlie'));
    await _settle(tester);

    expect(find.byTooltip('Close Charlie'), findsOneWidget);
    expect(find.byTooltip('Close Alpha'), findsNothing);
    expect(find.text('1. Alpha'), findsOneWidget); // closed, still first
    expect(_top(tester, '1. Alpha'), lessThan(_top(tester, '2. Bravo')));
    expect(_top(tester, '2. Bravo'), lessThan(_top(tester, 'Charlie')));
  });

  testWidgets('typed values survive closing and reopening the card', (tester) async {
    await _open(tester, _session([_ex('alpha', 1, targetSets: 2), _ex('bravo', 2, targetSets: 2)]));

    await tester.enterText(find.byType(TextField).first, '77.5');
    await tester.enterText(find.byType(TextField).at(1), '8');
    await tester.tap(find.byTooltip('Close Alpha'));
    await _settle(tester);
    expect(find.text('77.5'), findsNothing);

    await tester.tap(find.text('2. Bravo'));
    await _settle(tester);
    await tester.tap(find.text('1. Alpha'));
    await _settle(tester);

    expect(find.text('77.5'), findsOneWidget);
    expect(find.text('8'), findsOneWidget);
  });

  testWidgets('the last target set closes the card, opens the next, and rests as set', (tester) async {
    final setup = await _open(tester, _session([_ex('alpha', 1, targetSets: 1, restSeconds: 45), _ex('bravo', 2)]));

    await tester.tap(find.byTooltip('Log set 1'));
    await _settle(tester);

    expect(find.byTooltip('Close Bravo'), findsOneWidget);
    expect(find.text('1. Alpha'), findsOneWidget); // done, closed, same place
    expect(_top(tester, '1. Alpha'), lessThan(_top(tester, 'Bravo')));
    final timer = setup.container.read(restTimerProvider)!;
    expect(timer.total, const Duration(seconds: 45));
    expect(setup.timers.saved?.endsAt, timer.endsAt); // saved, so a restart keeps it

    // a finished card can be opened again to add a set
    await tester.tap(find.text('1. Alpha'));
    await _settle(tester);
    expect(find.byTooltip('Close Alpha'), findsOneWidget);
  });

  testWidgets('without a rest set, the 90 s default is used; changing it is for this workout', (tester) async {
    final setup = await _open(tester, _session([_ex('alpha', 1, targetSets: 3)]));

    expect(find.bySemanticsLabel(RegExp('^Rest 1:30 between sets')), findsOneWidget);
    await tester.tap(find.bySemanticsLabel(RegExp('^Rest 1:30')));
    await _settle(tester);
    expect(find.textContaining('Your plan stays as it is'), findsOneWidget);
    await tester.tap(find.byTooltip('Increase Rest between sets'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.byTooltip('Increase Rest between sets'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('Save'));
    await _settle(tester);

    expect(setup.sessions.rests, {'alpha': 120});
    expect(find.bySemanticsLabel(RegExp('^Rest 2:00 between sets')), findsOneWidget);

    await tester.tap(find.byTooltip('Log set 1'));
    await _settle(tester);
    expect(setup.container.read(restTimerProvider)!.total, const Duration(seconds: 120));
  });

  testWidgets('finishing without cardio asks once, and finishing without it works', (tester) async {
    final setup = await _open(tester, _session([_ex('alpha', 1, targetSets: 1, logged: 1)]));

    await tester.tap(find.text('Finish'));
    await _settle(tester);
    expect(find.text('No cardio today?'), findsOneWidget);
    await tester.tap(find.text('Finish without cardio'));
    await _settle(tester);

    expect(find.text('Finish workout?'), findsOneWidget);
    await tester.tap(find.text('Finish workout'));
    await _settle(tester);
    expect(setup.sessions.completed, isTrue);
    expect(find.text('summary page'), findsOneWidget);
  });

  testWidgets('with cardio logged there is no reminder', (tester) async {
    await _open(
      tester,
      _session([_ex('alpha', 1, targetSets: 1, logged: 1)],
          cardio: const [CardioEntry(id: 'c1', machine: CardioMachine.treadmill, durationSeconds: 600)]),
    );

    await tester.tap(find.text('Finish'));
    await _settle(tester);

    expect(find.text('No cardio today?'), findsNothing);
    expect(find.text('Finish workout?'), findsOneWidget);
  });

  Future<void> finishPlanWorkout(WidgetTester tester) async {
    await tester.tap(find.text('Finish'));
    await _settle(tester);
    await tester.tap(find.text('Finish without cardio'));
    await _settle(tester);
    await tester.tap(find.text('Finish workout'));
    await _settle(tester);
  }

  final planWorkout = _session([
    _ex('squat', 1, targetSets: 3, logged: 3), // from the plan
    _ex('lunge', 2, logged: 6, reps: 25, restSeconds: 60), // added, more than the plan allows
    _ex('curl', 3), // added, nothing logged
  ], planId: 'p1');

  testWidgets('after a plan workout, declining the new exercises changes no plan', (tester) async {
    final setup = await _open(tester, planWorkout, plans: _FakePlans(inPlan: ['x-squat']));

    await finishPlanWorkout(tester);
    expect(setup.sessions.completed, isTrue); // saved before the question
    expect(find.text('Add to Legs?'), findsOneWidget);
    expect(find.text('Lunge'), findsOneWidget);
    expect(find.text('Curl'), findsNothing); // no sets logged
    expect(find.text('Squat'), findsNothing); // already in the plan
    expect(find.text('4 × 20 · 1:00'), findsOneWidget); // within the plan limits

    await tester.tap(find.text('Not now'));
    await _settle(tester);
    expect(setup.plans.added, isEmpty);
    expect(find.text('summary page'), findsOneWidget);
  });

  testWidgets('confirming adds only the chosen exercises with their targets', (tester) async {
    final setup = await _open(tester, planWorkout, plans: _FakePlans(inPlan: ['x-squat']));

    await finishPlanWorkout(tester);
    await tester.tap(find.text('Add 1 to plan'));
    await _settle(tester);

    expect(setup.plans.added, [(exerciseId: 'x-lunge', sets: 4, reps: 20, rest: 60)]);
    expect(find.text('summary page'), findsOneWidget);
  });

  testWidgets('a plan deleted during the workout asks nothing', (tester) async {
    final setup = await _open(tester, planWorkout, plans: _FakePlans(deleted: true));

    await finishPlanWorkout(tester);

    expect(find.text('Add to Legs?'), findsNothing);
    expect(setup.plans.added, isEmpty);
    expect(find.text('summary page'), findsOneWidget);
  });

  group('plan additions', () {
    test('only added exercises with sets that the plan lacks, within the limits', () {
      final additions = planAdditions(planWorkout, ['x-squat']);
      expect(additions.map((a) => (a.exercise.id, a.sets, a.reps, a.restSeconds)), [('lunge', 4, 20, 60)]);
      expect(planAdditions(planWorkout, ['x-squat', 'x-lunge']), isEmpty);
      expect(planAdditions(planWorkout.copyWith(workoutPlanId: null), const []).length, 1);
    });

    test('the most common reps win, a tie goes to the higher', () {
      SessionSet s(int reps) => SessionSet(id: '$reps', setNumber: 1, reps: reps);
      expect(commonReps([s(8), s(10), s(10)]), 10);
      expect(commonReps([s(12), s(8)]), 12);
      expect(planAdditions(_session([_ex('a', 1, logged: 1, reps: 0)]), const []).single.reps, 1);
    });
  });

  test('a saved rest that is still running comes back after a restart; an ended one is dropped', () async {
    final running = RestTimer(endsAt: DateTime.now().add(const Duration(seconds: 40)), total: const Duration(seconds: 90));
    final container = ProviderContainer(overrides: [restTimerStoreProvider.overrideWithValue(_MemoryTimerStore(running))]);
    addTearDown(container.dispose);
    expect(container.read(restTimerProvider), isNull);
    await Future<void>.delayed(Duration.zero);
    expect(container.read(restTimerProvider)?.endsAt, running.endsAt);

    final ended = _MemoryTimerStore(
        RestTimer(endsAt: DateTime.now().subtract(const Duration(seconds: 5)), total: const Duration(seconds: 90)));
    final second = ProviderContainer(overrides: [restTimerStoreProvider.overrideWithValue(ended)]);
    addTearDown(second.dispose);
    second.read(restTimerProvider);
    await Future<void>.delayed(Duration.zero);
    expect(second.read(restTimerProvider), isNull);
    expect(ended.saved, isNull);
  });

  test('the timer saves as JSON and reads back', () {
    final timer = RestTimer(endsAt: DateTime(2026, 11, 19, 12), total: const Duration(seconds: 75));
    final back = RestTimer.fromJson(timer.toJson())!;
    expect(back.endsAt, timer.endsAt);
    expect(back.total, timer.total);
    expect(RestTimer.fromJson({'endsAt': 'nonsense'}), isNull);
  });

  testWidgets('the plan target sheet keeps an untouched default empty and saves a changed rest', (tester) async {
    final results = <PlanTarget?>[];
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => Column(children: [
          TextButton(onPressed: () async => results.add(await showTargetSheet(context, title: 'Squat')), child: const Text('new')),
          TextButton(
            onPressed: () async => results.add(await showTargetSheet(context, title: 'Squat', restSeconds: 60, canRemove: true)),
            child: const Text('edit'),
          ),
        ]),
      ),
    ));

    await tester.tap(find.text('new'));
    await tester.pumpAndSettle();
    expect(find.text('1:30'), findsOneWidget);
    await tester.tap(find.text('Add to plan'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('edit'));
    await tester.pumpAndSettle();
    expect(find.text('1:00'), findsOneWidget);
    await tester.tap(find.byTooltip('Decrease Rest between sets'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(results.map((r) => r?.restSeconds), [null, 45]);
  });

  test('formatRest', () {
    expect(formatRest(45), '45 s');
    expect(formatRest(90), '1:30');
    expect(formatRest(600), '10:00');
  });
}
