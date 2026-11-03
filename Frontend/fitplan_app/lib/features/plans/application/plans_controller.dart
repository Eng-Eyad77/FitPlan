import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_controller.dart';
import '../data/plans_repository.dart';
import '../domain/workout_plan.dart';

final plansControllerProvider =
    AsyncNotifierProvider<PlansController, List<WorkoutPlan>>(PlansController.new);

/// The user's plans, newest first. Actions throw ApiException on failure.
class PlansController extends AsyncNotifier<List<WorkoutPlan>> {
  PlansRepository get _repository => ref.read(plansRepositoryProvider);

  @override
  Future<List<WorkoutPlan>> build() {
    ref.watch(authControllerProvider.select((auth) => auth.value?.id));
    return _repository.getPlans();
  }

  Future<WorkoutPlan> create({required String name, String? description}) async {
    final plan = await _repository.createPlan(name: name, description: description);
    state = AsyncData([plan, ...?state.value]);
    return plan;
  }

  Future<void> rename(String id, {required String name, String? description}) async {
    final updated = await _repository.updatePlan(id, name: name, description: description);
    _replace(updated);
  }

  Future<void> delete(String id) async {
    await _repository.deletePlan(id);
    state = AsyncData([...?state.value?.where((plan) => plan.id != id)]);
  }

  /// Called after the plan's exercises change, so the card shows the right count.
  void setExerciseCount(String id, int count) {
    final plan = state.value?.where((plan) => plan.id == id).firstOrNull;
    if (plan != null) _replace(plan.copyWith(exerciseCount: count));
  }

  void _replace(WorkoutPlan updated) {
    state = AsyncData([
      for (final plan in state.value ?? const <WorkoutPlan>[])
        plan.id == updated.id ? updated : plan,
    ]);
  }
}

final planExercisesProvider = AsyncNotifierProvider.family<PlanExercisesController,
    List<PlanExercise>, String>(PlanExercisesController.new);

/// The exercises of one plan, in order. Actions throw ApiException on failure.
class PlanExercisesController extends AsyncNotifier<List<PlanExercise>> {
  PlanExercisesController(this.planId);

  final String planId;

  PlansRepository get _repository => ref.read(plansRepositoryProvider);

  @override
  Future<List<PlanExercise>> build() => _repository.getExercises(planId);

  Future<void> add({required String exerciseId, required int sets, required int reps}) async {
    final current = state.value ?? const <PlanExercise>[];
    // new exercises go to the end
    final nextOrder = current.fold(0, (max, e) => e.order > max ? e.order : max) + 1;
    final added = await _repository.addExercise(
      planId,
      exerciseId: exerciseId,
      sets: sets,
      reps: reps,
      order: nextOrder,
    );
    _set([...current, added]);
  }

  Future<void> updateTarget(PlanExercise exercise, {required int sets, required int reps}) async {
    final updated = await _repository.updateExercise(
      planId,
      exercise.id,
      sets: sets,
      reps: reps,
      order: exercise.order,
    );
    _set([
      for (final e in state.value ?? const <PlanExercise>[]) e.id == updated.id ? updated : e,
    ]);
  }

  Future<void> remove(String id) async {
    await _repository.removeExercise(planId, id);
    _set([...?state.value?.where((e) => e.id != id)]);
  }

  /// Drag and drop. Numbers the list 1..n again and saves only the exercises that moved.
  Future<void> reorder(int oldIndex, int newIndex) async {
    final list = [...?state.value];
    final moved = list.removeAt(oldIndex);
    list.insert(newIndex, moved);

    final renumbered = [for (var i = 0; i < list.length; i++) list[i].copyWith(order: i + 1)];
    final changed = [
      for (final e in renumbered)
        if (state.value!.firstWhere((old) => old.id == e.id).order != e.order) e,
    ];

    // optimistic: show the new order right away, then save
    state = AsyncData(renumbered);
    try {
      for (final e in changed) {
        await _repository.updateExercise(planId, e.id, sets: e.sets, reps: e.reps, order: e.order);
      }
    } catch (_) {
      ref.invalidateSelf(); // reload what the server has
      rethrow;
    }
  }

  void _set(List<PlanExercise> list) {
    state = AsyncData(list);
    ref.read(plansControllerProvider.notifier).setExerciseCount(planId, list.length);
  }
}
