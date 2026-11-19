import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text.dart';
import '../../../shared/format.dart';
import '../../../shared/widgets/feedback.dart';
import '../../exercises/domain/exercise.dart';
import '../application/plans_controller.dart';
import '../domain/workout_plan.dart';
import 'plan_form_sheet.dart';
import 'target_sheet.dart';

/// From the library: pick a plan (or create one), set the target, and add [exercise] to it.
/// Returns the plan it was added to, or null when the user stopped on the way.
/// Nothing is created or changed before the last step, except a plan the user chose to create.
Future<WorkoutPlan?> addExerciseToPlan(BuildContext context, WidgetRef ref, Exercise exercise) async {
  final choice = await showModalBottomSheet<_PlanChoice>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (_) => _ChoosePlanSheet(exercise: exercise),
  );
  if (choice == null || !context.mounted) return null;

  final plan = choice.createNew ? await showPlanFormSheet(context) : choice.plan;
  if (plan == null || !context.mounted) return null;

  final target = await showTargetSheet(context, title: capitalize(exercise.name));
  if (target == null || !context.mounted) return null;

  try {
    // the order of the new exercise comes from the plan's current list
    await ref.read(planExercisesProvider(plan.id).future);
    await ref
        .read(planExercisesProvider(plan.id).notifier)
        .add(exerciseId: exercise.id, sets: target.sets, reps: target.reps);
    return plan;
  } catch (error) {
    if (context.mounted) showError(context, error);
    return null;
  }
}

typedef _PlanChoice = ({WorkoutPlan? plan, bool createNew});

class _ChoosePlanSheet extends ConsumerWidget {
  const _ChoosePlanSheet({required this.exercise});

  final Exercise exercise;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plans = ref.watch(plansControllerProvider);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      builder: (context, scroll) => ListView(
        controller: scroll,
        padding: AppSpacing.screen.copyWith(top: AppSpacing.lg, bottom: AppSpacing.xxl),
        children: [
          const Text('Add to which plan?', style: AppText.heading),
          const SizedBox(height: AppSpacing.xs),
          Text(capitalize(exercise.name), style: AppText.secondary),
          const SizedBox(height: AppSpacing.lg),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const CircleAvatar(
              backgroundColor: AppColors.button,
              foregroundColor: AppColors.onButton,
              child: Icon(Icons.add_rounded),
            ),
            title: const Text('New plan', style: AppText.bodyStrong),
            subtitle: const Text('Create a plan and add it there', style: AppText.caption),
            onTap: () => Navigator.pop(context, (plan: null, createNew: true)),
          ),
          const Divider(),
          ...plans.when(
            loading: () => const [
              Padding(padding: EdgeInsets.all(AppSpacing.xl), child: Center(child: CircularProgressIndicator())),
            ],
            error: (error, _) => [
              LoadError(
                message: errorMessage(error, 'Could not load your plans.'),
                onRetry: () => ref.invalidate(plansControllerProvider),
              ),
            ],
            data: (plans) => plans.isEmpty
                ? const [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                      child: Text('You have no plans yet.', style: AppText.secondary),
                    ),
                  ]
                : [for (final plan in plans) _PlanTile(plan: plan, exerciseId: exercise.id)],
          ),
        ],
      ),
    );
  }
}

class _PlanTile extends ConsumerWidget {
  const _PlanTile({required this.plan, required this.exerciseId});

  final WorkoutPlan plan;
  final String exerciseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // a plan can hold an exercise only once (the API refuses a second one too)
    final exercises = ref.watch(planExercisesProvider(plan.id));
    final added = exercises.value?.any((e) => e.exerciseId == exerciseId) ?? false;
    final count = exercises.value?.length ?? plan.exerciseCount;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      enabled: !added && !exercises.isLoading,
      leading: CircleAvatar(
        backgroundColor: AppColors.surface2,
        foregroundColor: AppColors.textSecondary,
        child: Icon(added ? Icons.check_rounded : Icons.list_alt_rounded),
      ),
      title: Text(plan.name, style: AppText.bodyStrong, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        added ? 'Already in this plan' : '$count ${count == 1 ? 'exercise' : 'exercises'}',
        style: AppText.caption,
      ),
      onTap: () => Navigator.pop(context, (plan: plan, createNew: false)),
    );
  }
}
