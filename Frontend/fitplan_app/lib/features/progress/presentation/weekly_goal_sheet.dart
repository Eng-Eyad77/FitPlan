import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text.dart';
import '../../../shared/widgets/feedback.dart';
import '../../profile/application/profile_controller.dart';

/// How many workouts a week the user aims for (1-7), or no goal.
Future<void> showWeeklyGoalSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    builder: (_) => const _WeeklyGoalSheet(),
  );
}

class _WeeklyGoalSheet extends ConsumerStatefulWidget {
  const _WeeklyGoalSheet();

  @override
  ConsumerState<_WeeklyGoalSheet> createState() => _WeeklyGoalSheetState();
}

class _WeeklyGoalSheetState extends ConsumerState<_WeeklyGoalSheet> {
  bool _saving = false;

  Future<void> _save(int? goal) async {
    HapticFeedback.selectionClick();
    setState(() => _saving = true);
    try {
      await ref.read(profileControllerProvider.notifier).setWeeklyGoal(goal);
      if (mounted) Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      showError(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = ref.watch(profileControllerProvider).value?.weeklyGoal;

    return SafeArea(
      child: Padding(
        padding: AppSpacing.screen.copyWith(bottom: AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Weekly goal', style: AppText.heading),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              'Workouts per week. Hit it and your streak grows.',
              style: AppText.secondary,
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                for (var goal = 1; goal <= 7; goal++) ...[
                  if (goal > 1) const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _GoalButton(
                      goal: goal,
                      selected: goal == current,
                      onTap: _saving ? null : () => _save(goal),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            if (current != null)
              TextButton(
                onPressed: _saving ? null : () => _save(null),
                style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
                child: const Text('No goal'),
              ),
          ],
        ),
      ),
    );
  }
}

class _GoalButton extends StatelessWidget {
  const _GoalButton({required this.goal, required this.selected, required this.onTap});

  final int goal;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: '$goal ${goal == 1 ? 'workout' : 'workouts'} a week',
      excludeSemantics: true,
      child: Material(
        color: selected ? AppColors.accent : AppColors.surface2,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: SizedBox(
            height: AppSpacing.minTouch,
            child: Center(
              child: Text(
                '$goal',
                style: AppText.number.copyWith(
                  fontSize: 20,
                  color: selected ? AppColors.onAccent : AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
