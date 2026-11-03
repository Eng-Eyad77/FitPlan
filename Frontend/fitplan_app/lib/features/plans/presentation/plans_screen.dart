import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text.dart';
import '../../../shared/widgets/feedback.dart';
import '../../session/presentation/start_workout.dart';
import '../application/plans_controller.dart';
import '../domain/workout_plan.dart';
import 'plan_form_sheet.dart';

class PlansScreen extends ConsumerWidget {
  const PlansScreen({super.key});

  Future<void> _create(BuildContext context, WidgetRef ref) async {
    final plan = await showPlanFormSheet(context);
    if (plan != null && context.mounted) context.push(Routes.planDetail(plan.id));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plans = ref.watch(plansControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: plans.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => LoadError(
            message: errorMessage(error, 'Could not load your plans.'),
            onRetry: () => ref.invalidate(plansControllerProvider),
          ),
          data: (plans) => RefreshIndicator(
            onRefresh: () => ref.refresh(plansControllerProvider.future),
            child: ListView(
              padding: AppSpacing.screen.copyWith(top: 28, bottom: 24),
              children: [
                Row(
                  children: [
                    const Expanded(child: Text('Plans', style: AppText.title)),
                    IconButton.filled(
                      tooltip: 'New plan',
                      onPressed: () => _create(context, ref),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.button,
                        foregroundColor: AppColors.onButton,
                        fixedSize: const Size.square(AppSpacing.minTouch - 4),
                      ),
                      icon: const Icon(Icons.add_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                const Text('Your routines. Start one and log as you go.', style: AppText.secondary),
                const SizedBox(height: AppSpacing.xxl),
                if (plans.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 48),
                    child: EmptyState(
                      icon: Icons.event_note_rounded,
                      title: 'No plans yet',
                      message: 'Make a plan like "Push day" and add the exercises you do.',
                      action: FilledButton.icon(
                        onPressed: () => _create(context, ref),
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Create a plan'),
                      ),
                    ),
                  )
                else
                  ...[
                    for (final plan in plans) ...[
                      _PlanCard(plan: plan),
                      const SizedBox(height: AppSpacing.md),
                    ],
                  ].animate(interval: 40.ms).fadeIn(duration: 250.ms).slideY(begin: 0.05, end: 0),
                const SizedBox(height: AppSpacing.md),
                Center(
                  child: TextButton.icon(
                    onPressed: () => startWorkout(context, ref),
                    icon: const Icon(Icons.bolt_rounded),
                    label: const Text('Quick workout, no plan'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlanCard extends ConsumerWidget {
  const _PlanCard({required this.plan});

  final WorkoutPlan plan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = plan.exerciseCount;

    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.cardBorder,
        side: const BorderSide(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(Routes.planDetail(plan.id)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.lg, AppSpacing.md, AppSpacing.lg),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(plan.name, style: AppText.heading, maxLines: 1, overflow: TextOverflow.ellipsis),
                    if (plan.description != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        plan.description!,
                        style: AppText.secondary,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      count == 0 ? 'No exercises yet' : '$count ${count == 1 ? 'exercise' : 'exercises'}',
                      style: AppText.caption.copyWith(
                        color: count == 0 ? AppColors.textTertiary : AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              IconButton.filledTonal(
                tooltip: 'Start ${plan.name}',
                onPressed: count == 0 ? null : () => startWorkout(context, ref, planId: plan.id),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.accentTint(),
                  foregroundColor: AppColors.accent,
                  fixedSize: const Size.square(AppSpacing.minTouch),
                ),
                icon: const Icon(Icons.play_arrow_rounded, size: 28),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
