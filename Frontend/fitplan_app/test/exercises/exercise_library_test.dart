import 'package:dio/dio.dart';
import 'package:fitplan_app/core/storage/session_storage.dart';
import 'package:fitplan_app/features/auth/domain/auth_session.dart';
import 'package:fitplan_app/features/exercises/data/exercises_repository.dart';
import 'package:fitplan_app/features/exercises/domain/exercise.dart';
import 'package:fitplan_app/features/exercises/presentation/exercise_picker_screen.dart';
import 'package:fitplan_app/features/exercises/presentation/widgets/exercise_thumb.dart';
import 'package:fitplan_app/features/plans/data/plans_repository.dart';
import 'package:fitplan_app/features/plans/domain/workout_plan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

// Phase 6 (3.2, 3.3): the library without a plan, adding from it, and hidden cardio.

const _pushUp = Exercise(id: 'ex1', name: 'push-up', gifUrl: 'https://media.test/ex1.gif', bodyPart: 'chest', instructions: ['Step:1 Push']);
const _squat = Exercise(id: 'ex2', name: 'squat', gifUrl: 'https://media.test/ex2.gif', bodyPart: 'upper legs');

class _FakeExercises extends ExercisesRepository {
  _FakeExercises() : super(Dio());

  @override
  Future<ExercisePage> getPage({int page = 1, String? bodyPart, String? search}) async =>
      const ExercisePage(items: [_pushUp, _squat], page: 1, totalPages: 1, totalCount: 2);

  // what the API sends with cardio hidden
  @override
  Future<List<String>> getBodyParts() async => ['chest', 'upper legs'];

  @override
  Future<Exercise> getExercise(String id) async => id == _pushUp.id ? _pushUp : _squat;
}

class _FakePlans extends PlansRepository {
  _FakePlans() : super(Dio());

  final created = <String>[];
  final added = <({String planId, String exerciseId, int sets, int reps})>[];

  final _legs = WorkoutPlan(id: 'p1', name: 'Legs', createdAt: DateTime(2026), updatedAt: DateTime(2026), exerciseCount: 1);
  final _push = WorkoutPlan(id: 'p2', name: 'Push day', createdAt: DateTime(2026), updatedAt: DateTime(2026));

  @override
  Future<List<WorkoutPlan>> getPlans() async => [_legs, _push];

  @override
  Future<WorkoutPlan> createPlan({required String name, String? description}) async {
    created.add(name);
    return WorkoutPlan(id: 'new', name: name, createdAt: DateTime(2026), updatedAt: DateTime(2026));
  }

  @override
  Future<List<PlanExercise>> getExercises(String planId) async => planId == 'p1'
      ? const [PlanExercise(id: 'pe1', exerciseId: 'ex2', name: 'squat', gifUrl: '', bodyPart: 'upper legs', sets: 3, reps: 10, order: 1)]
      : const [];

  @override
  Future<PlanExercise> addExercise(String planId,
      {required String exerciseId, required int sets, required int reps, required int order, int? restSeconds}) async {
    added.add((planId: planId, exerciseId: exerciseId, sets: sets, reps: reps));
    return PlanExercise(id: 'pe-new', exerciseId: exerciseId, name: 'push-up', gifUrl: '', bodyPart: 'chest', sets: sets, reps: reps, order: order);
  }
}

class _NoSession extends SessionStorage {
  _NoSession() : super(const FlutterSecureStorage());

  @override
  Future<AuthSession?> read() async => null;
}

Future<_FakePlans> _open(WidgetTester tester, Widget home) async {
  final plans = _FakePlans();
  await tester.binding.setSurfaceSize(const Size(420, 900));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(ProviderScope(
    overrides: [
      exercisesRepositoryProvider.overrideWithValue(_FakeExercises()),
      plansRepositoryProvider.overrideWithValue(plans),
      sessionStorageProvider.overrideWithValue(_NoSession()),
    ],
    child: MaterialApp(home: home),
  ));
  await tester.pumpAndSettle();
  return plans;
}

void main() {
  testWidgets('the chips come from the API, so hidden cardio has none', (tester) async {
    await _open(tester, const ExercisePickerScreen(browse: true));

    expect(find.widgetWithText(ChoiceChip, 'Chest'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'Upper legs'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'Cardio'), findsNothing);
  });

  testWidgets('browsing and opening an exercise creates and changes no plan', (tester) async {
    final plans = await _open(tester, const ExercisePickerScreen(browse: true));

    expect(find.text('Exercises'), findsOneWidget);
    await tester.tap(find.text('Push-up'));
    await tester.pumpAndSettle();
    expect(find.text('How to do it'), findsOneWidget);
    expect(find.text('Push'), findsOneWidget);

    await tester.tapAt(const Offset(10, 10)); // close the sheet
    await tester.pumpAndSettle();

    expect(plans.created, isEmpty);
    expect(plans.added, isEmpty);
    expect(find.text('Exercises'), findsOneWidget); // still on the library, nothing was picked
  });

  testWidgets('adding asks which plan, marks a plan that has it, then adds with the target', (tester) async {
    final plans = await _open(tester, const ExercisePickerScreen(browse: true));

    await tester.tap(find.byTooltip('Add squat to a plan'));
    await tester.pumpAndSettle();

    expect(find.text('Add to which plan?'), findsOneWidget);
    expect(find.text('Already in this plan'), findsOneWidget); // Legs has the squat
    await tester.tap(find.text('Legs'));
    await tester.pumpAndSettle();
    expect(find.text('Add to which plan?'), findsOneWidget); // a disabled plan can't be chosen

    await tester.tap(find.text('Push day'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add to plan'));
    await tester.pumpAndSettle();

    expect(plans.added.single, (planId: 'p2', exerciseId: 'ex2', sets: 3, reps: 10));
    expect(plans.created, isEmpty);
    expect(find.text('Added to Push day'), findsOneWidget);
  });

  testWidgets('a new plan can be created on the way', (tester) async {
    final plans = await _open(tester, const ExercisePickerScreen(browse: true));

    await tester.tap(find.byTooltip('Add push-up to a plan'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('New plan'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Chest day');
    await tester.tap(find.widgetWithText(FilledButton, 'Create plan'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add to plan'));
    await tester.pumpAndSettle();

    expect(plans.created, ['Chest day']);
    expect(plans.added.single.planId, 'new');
  });

  testWidgets('picking for a plan still returns the exercise, as before', (tester) async {
    Exercise? picked;
    await _open(
      tester,
      Builder(
        builder: (context) => TextButton(
          onPressed: () async => picked = await Navigator.of(context).push<Exercise>(
            MaterialPageRoute(builder: (_) => const ExercisePickerScreen(excludedIds: {'ex2'})),
          ),
          child: const Text('open'),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Add exercise'), findsOneWidget);
    expect(find.text('Upper legs · added'), findsOneWidget);
    await tester.tap(find.text('Push-up'));
    await tester.pumpAndSettle();

    expect(picked, _pushUp);
  });

  testWidgets('a demo that does not load says so, big and small', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Column(children: [
        ExerciseThumb(url: 'https://media.test/missing.gif', size: 300),
        ExerciseThumb(url: 'https://media.test/missing.gif', size: 56),
      ]),
    ));
    // the test environment answers every image request with an error, like a missing GIF
    await tester.pumpAndSettle();

    expect(find.text('Demo not available'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('^Demo not available')), findsNWidgets(2));
  });
}
