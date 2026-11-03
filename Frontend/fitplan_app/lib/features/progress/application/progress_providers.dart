import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderOrFamily;

import '../../auth/application/auth_controller.dart';
import '../data/stats_repository.dart';
import '../domain/stats.dart';

/// The overview for a week starting on [weekStartsOn] (DateTime.weekday: 1 = Monday ... 7 = Sunday).
final statsOverviewProvider = FutureProvider.family<StatsOverview, int>((ref, weekStartsOn) {
  ref.watch(authControllerProvider.select((auth) => auth.value?.id));
  return ref.watch(statsRepositoryProvider).getOverview(weekStartsOn: weekStartsOn);
});

/// Personal records, the exercises trained most recently first.
final recordsProvider = FutureProvider<List<ExerciseRecords>>((ref) {
  ref.watch(authControllerProvider.select((auth) => auth.value?.id));
  return ref.watch(statsRepositoryProvider).getRecords();
});

final exerciseProgressProvider = FutureProvider.family<ExerciseProgress, String>((ref, exerciseId) {
  ref.watch(authControllerProvider.select((auth) => auth.value?.id));
  return ref.watch(statsRepositoryProvider).getExerciseProgress(exerciseId);
});

final sessionComparisonProvider = FutureProvider.autoDispose.family<SessionComparison, String>(
  (ref, sessionId) => ref.watch(statsRepositoryProvider).getComparison(sessionId),
);

/// Newest first.
final bodyWeightHistoryProvider = FutureProvider<List<BodyWeightEntry>>((ref) {
  ref.watch(authControllerProvider.select((auth) => auth.value?.id));
  return ref.watch(statsRepositoryProvider).getBodyWeightHistory();
});

/// The exercise shown in the strength chart. Null = the most recently trained one.
final selectedExerciseProvider = NotifierProvider<SelectedExercise, String?>(SelectedExercise.new);

class SelectedExercise extends Notifier<String?> {
  @override
  String? build() {
    ref.watch(authControllerProvider.select((auth) => auth.value?.id));
    return null;
  }

  void select(String exerciseId) => state = exerciseId;
}

/// Everything that changes when a workout is finished or deleted.
/// Takes `ref.invalidate`, so it works from a Notifier (Ref) and from a widget (WidgetRef).
void invalidateWorkoutStats(void Function(ProviderOrFamily provider) invalidate) {
  invalidate(statsOverviewProvider);
  invalidate(recordsProvider);
  invalidate(exerciseProgressProvider);
}

/// The first day of the week of the phone's language, as a DateTime.weekday number.
int weekStartOf(BuildContext context) {
  // Material counts from Sunday = 0
  final index = MaterialLocalizations.of(context).firstDayOfWeekIndex;
  return index == 0 ? DateTime.sunday : index;
}
