import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_controller.dart';
import '../../history/application/history_controller.dart';
import '../../progress/application/progress_providers.dart';
import '../data/sessions_repository.dart';
import '../domain/workout_session.dart';

final activeSessionControllerProvider =
    AsyncNotifierProvider<ActiveSessionController, WorkoutSession?>(ActiveSessionController.new);

/// The workout in progress, or null. The server is the source of truth, so
/// closing the app mid-workout and opening it again resumes the same session.
///
/// Actions throw ApiException on failure; the screen shows the message.
class ActiveSessionController extends AsyncNotifier<WorkoutSession?> {
  SessionsRepository get _repository => ref.read(sessionsRepositoryProvider);

  @override
  Future<WorkoutSession?> build() {
    ref.watch(authControllerProvider.select((auth) => auth.value?.id));
    return _repository.getActive();
  }

  WorkoutSession get _session {
    final session = state.value;
    if (session == null) throw StateError('No workout in progress');
    return session;
  }

  Future<WorkoutSession> start({String? planId}) async {
    final session = await _repository.start(planId: planId);
    state = AsyncData(session);
    return session;
  }

  /// Reloads from the server (after deletes, the server renumbers the sets).
  Future<void> refresh() async {
    state = AsyncData(await _repository.getActive());
  }

  Future<SessionSummary> finish({String? notes}) async {
    final summary = await _repository.complete(_session.id, notes: notes);
    state = const AsyncData(null);
    // the new workout shows up in History, Home and Progress
    ref.invalidate(historyControllerProvider);
    invalidateWorkoutStats(ref.invalidate);
    return summary;
  }

  Future<void> cancel() async {
    await _repository.delete(_session.id);
    state = const AsyncData(null);
  }

  // ---- exercises ----

  Future<void> addExercise(String exerciseId) async {
    final added = await _repository.addExercise(_session.id, exerciseId);
    state = AsyncData(_session.copyWith(exercises: [..._session.exercises, added]));
  }

  Future<void> removeExercise(String sessionExerciseId) async {
    await _repository.removeExercise(_session.id, sessionExerciseId);
    state = AsyncData(_session.copyWith(
      exercises: [..._session.exercises.where((e) => e.id != sessionExerciseId)],
    ));
  }

  // ---- sets ----

  Future<void> addSet(String sessionExerciseId, {required int reps, double? weightKg}) async {
    final set = await _repository.addSet(
      _session.id,
      sessionExerciseId,
      reps: reps,
      weightKg: weightKg,
    );
    _updateExercise(sessionExerciseId, (e) => e.copyWith(sets: [...e.sets, set]));
  }

  Future<void> updateSet(
    String sessionExerciseId,
    String setId, {
    required int reps,
    double? weightKg,
  }) async {
    final updated = await _repository.updateSet(
      _session.id,
      sessionExerciseId,
      setId,
      reps: reps,
      weightKg: weightKg,
    );
    _updateExercise(
      sessionExerciseId,
      (e) => e.copyWith(sets: [for (final s in e.sets) s.id == setId ? updated : s]),
    );
  }

  Future<void> deleteSet(String sessionExerciseId, String setId) async {
    await _repository.deleteSet(_session.id, sessionExerciseId, setId);
    // the remaining sets are renumbered by the server: 1, 2, 3...
    _updateExercise(sessionExerciseId, (e) {
      final remaining = e.sets.where((s) => s.id != setId).toList();
      return e.copyWith(sets: [
        for (var i = 0; i < remaining.length; i++) remaining[i].copyWith(setNumber: i + 1),
      ]);
    });
  }

  // ---- cardio ----

  Future<void> addCardio(CardioInput input) async {
    final entry = await _repository.addCardio(_session.id, input);
    state = AsyncData(_session.copyWith(cardio: [..._session.cardio, entry]));
  }

  Future<void> deleteCardio(String id) async {
    await _repository.deleteCardio(_session.id, id);
    state = AsyncData(_session.copyWith(cardio: [..._session.cardio.where((c) => c.id != id)]));
  }

  void _updateExercise(String id, SessionExercise Function(SessionExercise) change) {
    state = AsyncData(_session.copyWith(
      exercises: [for (final e in _session.exercises) e.id == id ? change(e) : e],
    ));
  }
}
