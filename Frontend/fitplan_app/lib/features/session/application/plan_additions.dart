import '../../plans/domain/workout_plan.dart';
import '../domain/workout_session.dart';

/// An exercise added during a plan workout, offered for the plan with targets from what was logged.
typedef PlanAddition = ({SessionExercise exercise, int sets, int reps, int? restSeconds});

/// The exercises added during the workout (no target from the plan) that have logged sets
/// and aren't in the plan now, in the workout's order.
List<PlanAddition> planAdditions(WorkoutSession session, Iterable<String> exerciseIdsInPlan) {
  final inPlan = exerciseIdsInPlan.toSet();
  return [
    for (final e in [...session.exercises]..sort((a, b) => a.order.compareTo(b.order)))
      if (e.targetSets == null && e.sets.isNotEmpty && !inPlan.contains(e.exerciseId))
        (
          exercise: e,
          sets: e.sets.length.clamp(1, PlanLimits.maxSets),
          reps: commonReps(e.sets).clamp(1, PlanLimits.maxReps),
          restSeconds: e.restSeconds,
        ),
  ];
}

/// The reps done in the most sets; a tie goes to the higher reps.
int commonReps(List<SessionSet> sets) {
  final counts = <int, int>{};
  for (final s in sets) {
    counts[s.reps] = (counts[s.reps] ?? 0) + 1;
  }
  return counts.entries.reduce((best, e) => e.value > best.value || (e.value == best.value && e.key > best.key) ? e : best).key;
}
