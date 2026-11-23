import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text.dart';
import '../../../shared/format.dart';
import '../../../shared/widgets/feedback.dart';
import '../../exercises/presentation/widgets/exercise_thumb.dart';
import '../../plans/application/plans_controller.dart';
import '../../plans/data/plans_repository.dart';
import '../../plans/presentation/target_sheet.dart';
import '../application/plan_additions.dart';
import '../domain/workout_session.dart';
import '../../../l10n/l10n.dart';

/// After a finished plan workout: offers the exercises added during it for the plan.
/// The plan changes only for the ones the user confirms. Never throws.
Future<void> offerPlanAdditions(BuildContext context, WidgetRef ref, WorkoutSession session) async {
  final planId = session.workoutPlanId;
  if (planId == null) return;

  final List<PlanAddition> additions;
  try {
    // the plan as it is now (it may have changed, or been deleted, during the workout)
    final current = await ref.read(plansRepositoryProvider).getExercises(planId);
    additions = planAdditions(session, current.map((e) => e.exerciseId));
  } catch (_) {
    return; // deleted plan or no connection: nothing to offer
  }
  if (additions.isEmpty || !context.mounted) return;

  final chosen = await showModalBottomSheet<List<PlanAddition>>(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    builder: (_) => _PlanAdditionsSheet(planName: session.name, additions: additions),
  );
  if (chosen == null || chosen.isEmpty || !context.mounted) return;

  final controller = ref.read(planExercisesProvider(planId).notifier);
  var added = 0;
  try {
    // the order of each new exercise comes from the plan's current list
    await ref.read(planExercisesProvider(planId).future);
    for (final a in chosen) {
      try {
        await controller.add(exerciseId: a.exercise.exerciseId, sets: a.sets, reps: a.reps, restSeconds: a.restSeconds);
        added++;
      } on ApiException catch (error) {
        if (error.code != 'ExerciseAlreadyExists') rethrow; // already there: nothing to do
      }
    }
    if (context.mounted) showMessage(context, l10n.addedToPlan(l10n.exerciseCount(added), session.name));
  } catch (error) {
    if (context.mounted) showError(context, error);
  }
}

class _PlanAdditionsSheet extends StatefulWidget {
  const _PlanAdditionsSheet({required this.planName, required this.additions});

  final String planName;
  final List<PlanAddition> additions;

  @override
  State<_PlanAdditionsSheet> createState() => _PlanAdditionsSheetState();
}

class _PlanAdditionsSheetState extends State<_PlanAdditionsSheet> {
  late final _items = [...widget.additions];
  late final _selected = <int>{for (var i = 0; i < _items.length; i++) i};

  Future<void> _edit(int index) async {
    final item = _items[index];
    final target = await showTargetSheet(
      context,
      title: capitalize(item.exercise.name),
      sets: item.sets,
      reps: item.reps,
      restSeconds: item.restSeconds,
      confirmLabel: l10n.save,
    );
    if (target == null || !mounted) return;
    setState(() {
      _items[index] = (exercise: item.exercise, sets: target.sets, reps: target.reps, restSeconds: target.restSeconds);
      _selected.add(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final count = _selected.length;

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.85),
        child: ListView(
          shrinkWrap: true,
          padding: AppSpacing.screen.copyWith(top: AppSpacing.lg, bottom: AppSpacing.lg),
          children: [
            Text(l10n.addToPlanQuestion(widget.planName), style: AppText.heading),
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.planAdditionsBody,
              style: AppText.secondary,
            ),
            const SizedBox(height: AppSpacing.md),
            for (var i = 0; i < _items.length; i++)
              _AdditionRow(
                item: _items[i],
                selected: _selected.contains(i),
                onToggle: () => setState(() => _selected.contains(i) ? _selected.remove(i) : _selected.add(i)),
                onEdit: () => _edit(i),
              ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: count == 0
                  ? null
                  : () => Navigator.pop(context, [
                        for (var i = 0; i < _items.length; i++)
                          if (_selected.contains(i)) _items[i],
                      ]),
              child: Text(count == 0 ? l10n.addToPlan : l10n.addCountToPlan(count)),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
              child: Text(l10n.notNow),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdditionRow extends StatelessWidget {
  const _AdditionRow({required this.item, required this.selected, required this.onToggle, required this.onEdit});

  final PlanAddition item;
  final bool selected;
  final VoidCallback onToggle;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final name = capitalize(item.exercise.name);
    final target = item.restSeconds == null
        ? '${item.sets} × ${item.reps}'
        : '${item.sets} × ${item.reps} · ${formatRest(item.restSeconds!)}';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Row(
              children: [
                Checkbox(value: selected, onChanged: (_) => onToggle(), semanticLabel: l10n.addName(name)),
                ExerciseThumb(url: item.exercise.gifUrl, size: 44),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(name, style: AppText.bodyStrong, maxLines: 2, overflow: TextOverflow.ellipsis),
                ),
                TextButton(
                  onPressed: onEdit,
                  child: Text(target, semanticsLabel: l10n.targetForSemantics(name, target)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
