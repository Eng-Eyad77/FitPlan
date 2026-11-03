import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text.dart';
import '../../../shared/format.dart';
import '../../../shared/widgets/feedback.dart';
import '../../exercises/domain/exercise.dart';
import '../../exercises/presentation/exercise_details_sheet.dart';
import '../../exercises/presentation/widgets/exercise_thumb.dart';
import '../../session/presentation/start_workout.dart';
import '../application/plans_controller.dart';
import '../domain/workout_plan.dart';
import 'plan_form_sheet.dart';
import 'target_sheet.dart';

class PlanDetailScreen extends ConsumerWidget {
  const PlanDetailScreen({super.key, required this.planId});

  final String planId;

  Future<void> _addExercise(BuildContext context, WidgetRef ref, List<PlanExercise> current) async {
    final exercise = await context.push<Exercise>(
      Routes.exercisePicker,
      extra: {for (final e in current) e.exerciseId},
    );
    if (exercise == null || !context.mounted) return;

    final target = await showTargetSheet(context, title: capitalize(exercise.name));
    if (target == null || !context.mounted) return;

    try {
      await ref
          .read(planExercisesProvider(planId).notifier)
          .add(exerciseId: exercise.id, sets: target.sets, reps: target.reps);
    } catch (error) {
      if (context.mounted) showError(context, error);
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, WorkoutPlan plan) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete plan?'),
        content: Text('"${plan.name}" will be deleted. Your past workouts stay in your history.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Keep')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    try {
      await ref.read(plansControllerProvider.notifier).delete(plan.id);
      if (context.mounted) context.pop();
    } catch (error) {
      if (context.mounted) showError(context, error);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(
      plansControllerProvider.select(
        (plans) => plans.value?.where((p) => p.id == planId).firstOrNull,
      ),
    );
    final exercises = ref.watch(planExercisesProvider(planId));
    final list = exercises.value ?? const <PlanExercise>[];

    return Scaffold(
      appBar: AppBar(
        title: Text(plan?.name ?? 'Plan', style: AppText.heading),
        actions: [
          if (plan != null)
            PopupMenuButton<String>(
              tooltip: 'Plan options',
              onSelected: (value) => switch (value) {
                'edit' => showPlanFormSheet(context, plan: plan),
                _ => _delete(context, ref, plan),
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit name')),
                PopupMenuItem(value: 'delete', child: Text('Delete plan')),
              ],
            ),
        ],
      ),
      body: exercises.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => LoadError(
          message: errorMessage(error, 'Could not load this plan.'),
          onRetry: () => ref.invalidate(planExercisesProvider(planId)),
        ),
        data: (list) => list.isEmpty
            ? EmptyState(
                icon: Icons.fitness_center_rounded,
                title: 'Add your first exercise',
                message: 'Pick from 1,500 exercises and set your target sets and reps.',
                action: FilledButton.icon(
                  onPressed: () => _addExercise(context, ref, list),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add exercise'),
                ),
              )
            : ReorderableListView.builder(
                padding: AppSpacing.screen.copyWith(top: AppSpacing.sm, bottom: AppSpacing.lg),
                buildDefaultDragHandles: false,
                header: plan?.description == null
                    ? null
                    : Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                        child: Text(plan!.description!, style: AppText.secondary),
                      ),
                itemCount: list.length,
                onReorderItem: (oldIndex, newIndex) async {
                  if (newIndex == oldIndex) return;
                  try {
                    await ref.read(planExercisesProvider(planId).notifier).reorder(oldIndex, newIndex);
                  } catch (error) {
                    if (context.mounted) showError(context, error);
                  }
                },
                itemBuilder: (context, index) => Padding(
                  key: ValueKey(list[index].id),
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _PlanExerciseTile(planId: planId, exercise: list[index], index: index),
                ),
              ),
      ),
      bottomNavigationBar: list.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: AppSpacing.screen.copyWith(top: AppSpacing.sm, bottom: AppSpacing.md),
                child: Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _addExercise(context, ref, list),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 56),
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                      ),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Add'),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => startWorkout(context, ref, planId: planId),
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('Start workout'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _PlanExerciseTile extends ConsumerWidget {
  const _PlanExerciseTile({required this.planId, required this.exercise, required this.index});

  final String planId;
  final PlanExercise exercise;
  final int index;

  Future<void> _edit(BuildContext context, WidgetRef ref) async {
    final target = await showTargetSheet(
      context,
      title: capitalize(exercise.name),
      sets: exercise.sets,
      reps: exercise.reps,
      canRemove: true,
    );
    if (target == null || !context.mounted) return;

    final controller = ref.read(planExercisesProvider(planId).notifier);
    try {
      if (target.remove) {
        await controller.remove(exercise.id);
      } else {
        await controller.updateTarget(exercise, sets: target.sets, reps: target.reps);
      }
    } catch (error) {
      if (context.mounted) showError(context, error);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: const BorderSide(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _edit(context, ref),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              ExerciseThumb(
                url: exercise.gifUrl,
                size: 64,
                onTap: () => showExerciseDetails(
                  context,
                  exerciseId: exercise.exerciseId,
                  name: exercise.name,
                  gifUrl: exercise.gifUrl,
                  bodyPart: exercise.bodyPart,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      capitalize(exercise.name),
                      style: AppText.bodyStrong,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(capitalize(exercise.bodyPart), style: AppText.caption),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.accentTint(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  '${exercise.sets} × ${exercise.reps}',
                  style: AppText.bodyStrong.copyWith(color: AppColors.accent, fontSize: 14),
                ),
              ),
              ReorderableDragStartListener(
                index: index,
                child: const Padding(
                  padding: EdgeInsets.only(left: AppSpacing.sm),
                  child: Icon(Icons.drag_indicator_rounded, color: AppColors.textTertiary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
