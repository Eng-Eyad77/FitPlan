import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text.dart';
import '../../../shared/widgets/number_stepper.dart';
import '../../session/domain/workout_session.dart';
import '../domain/workout_plan.dart';

/// [restSeconds] null = the default rest (90 s).
typedef PlanTarget = ({int sets, int reps, int? restSeconds, bool remove});

/// Sets × reps and the rest for an exercise in a plan. Returns null when dismissed.
Future<PlanTarget?> showTargetSheet(
  BuildContext context, {
  required String title,
  int sets = 3,
  int reps = 10,
  int? restSeconds,
  bool canRemove = false,
  String? confirmLabel,
}) {
  return showModalBottomSheet<PlanTarget>(
    context: context,
    // cover the tab bar too
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (_) => _TargetSheet(
      title: title,
      sets: sets,
      reps: reps,
      restSeconds: restSeconds,
      canRemove: canRemove,
      confirmLabel: confirmLabel,
    ),
  );
}

class _TargetSheet extends StatefulWidget {
  const _TargetSheet({
    required this.title,
    required this.sets,
    required this.reps,
    required this.restSeconds,
    required this.canRemove,
    this.confirmLabel,
  });

  final String title;
  final int sets;
  final int reps;
  final int? restSeconds;
  final bool canRemove;
  final String? confirmLabel;

  @override
  State<_TargetSheet> createState() => _TargetSheetState();
}

class _TargetSheetState extends State<_TargetSheet> {
  late int _sets = widget.sets.clamp(1, PlanLimits.maxSets);
  late int _reps = widget.reps.clamp(1, PlanLimits.maxReps);
  late int _rest = (widget.restSeconds ?? RestLimits.defaultSeconds).clamp(RestLimits.min, RestLimits.max);

  /// Untouched default stays null, so a later change of the default still applies.
  int? get _restToSave => widget.restSeconds == null && _rest == RestLimits.defaultSeconds ? null : _rest;

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
            const SizedBox(height: AppSpacing.md),
            NumberStepper(
              label: 'Rest between sets',
              value: _rest,
              min: RestLimits.min,
              max: RestLimits.max,
              step: RestLimits.step,
              format: formatRest,
              onChanged: (v) => setState(() => _rest = v),
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton(
              onPressed: () => Navigator.pop(context, (sets: _sets, reps: _reps, restSeconds: _restToSave, remove: false)),
              child: Text(widget.confirmLabel ?? (widget.canRemove ? 'Save' : 'Add to plan')),
            ),
            if (widget.canRemove) ...[
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: () => Navigator.pop(context, (sets: _sets, reps: _reps, restSeconds: _restToSave, remove: true)),
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
