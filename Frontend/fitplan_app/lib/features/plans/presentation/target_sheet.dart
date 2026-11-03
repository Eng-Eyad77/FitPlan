import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text.dart';
import '../../../shared/widgets/number_stepper.dart';
import '../domain/workout_plan.dart';

typedef PlanTarget = ({int sets, int reps, bool remove});

/// Sets × reps for an exercise in a plan. Returns null when dismissed.
Future<PlanTarget?> showTargetSheet(
  BuildContext context, {
  required String title,
  int sets = 3,
  int reps = 10,
  bool canRemove = false,
}) {
  return showModalBottomSheet<PlanTarget>(
    context: context,
    // cover the tab bar too
    useRootNavigator: true,
    builder: (_) => _TargetSheet(title: title, sets: sets, reps: reps, canRemove: canRemove),
  );
}

class _TargetSheet extends StatefulWidget {
  const _TargetSheet({
    required this.title,
    required this.sets,
    required this.reps,
    required this.canRemove,
  });

  final String title;
  final int sets;
  final int reps;
  final bool canRemove;

  @override
  State<_TargetSheet> createState() => _TargetSheetState();
}

class _TargetSheetState extends State<_TargetSheet> {
  late int _sets = widget.sets.clamp(1, PlanLimits.maxSets);
  late int _reps = widget.reps.clamp(1, PlanLimits.maxReps);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: AppSpacing.screen.copyWith(bottom: AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.title, style: AppText.heading, maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: AppSpacing.xs),
            const Text('Your target for each workout', style: AppText.secondary),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: NumberStepper(
                    label: 'Sets',
                    value: _sets,
                    min: 1,
                    max: PlanLimits.maxSets,
                    onChanged: (v) => setState(() => _sets = v),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: NumberStepper(
                    label: 'Reps',
                    value: _reps,
                    min: 1,
                    max: PlanLimits.maxReps,
                    onChanged: (v) => setState(() => _reps = v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton(
              onPressed: () => Navigator.pop(context, (sets: _sets, reps: _reps, remove: false)),
              child: Text(widget.canRemove ? 'Save' : 'Add to plan'),
            ),
            if (widget.canRemove) ...[
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: () => Navigator.pop(context, (sets: _sets, reps: _reps, remove: true)),
                style: TextButton.styleFrom(foregroundColor: AppColors.danger),
                child: const Text('Remove from plan'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
