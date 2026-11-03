import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../shared/format.dart';
import '../../../../shared/widgets/feedback.dart';
import '../../../exercises/presentation/exercise_details_sheet.dart';
import '../../../exercises/presentation/widgets/exercise_thumb.dart';
import '../../application/active_session_controller.dart';
import '../../application/rest_timer.dart';
import '../../domain/workout_session.dart';
import 'set_edit_sheet.dart';
import 'set_rows.dart';

/// The exercise being done right now: what to do, what you did last time, and the sets.
class ExerciseCard extends ConsumerStatefulWidget {
  const ExerciseCard({super.key, required this.exercise, this.onNext});

  final SessionExercise exercise;

  /// Shown as "Next exercise" once every target set is logged.
  final VoidCallback? onNext;

  @override
  ConsumerState<ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends ConsumerState<ExerciseCard> {
  /// Extra empty rows the user asked for with "+ Add set".
  int _extraRows = 0;

  SessionExercise get _exercise => widget.exercise;

  @override
  void didUpdateWidget(ExerciseCard old) {
    super.didUpdateWidget(old);
    if (old.exercise.id != widget.exercise.id) _extraRows = 0;
  }

  ActiveSessionController get _controller => ref.read(activeSessionControllerProvider.notifier);

  /// How many rows to show before any "+ Add set": the target,
  /// or as many as last time, and at least one.
  int get _plannedRows {
    final target = _exercise.targetSets ?? 0;
    final last = _exercise.lastPerformance?.sets.length ?? 0;
    return [target, last, 1].reduce((a, b) => a > b ? a : b);
  }

  int get _draftCount {
    final logged = _exercise.sets.length;
    final remaining = (_plannedRows - logged).clamp(0, SessionLimits.maxSetsPerExercise);
    return (remaining + _extraRows).clamp(0, SessionLimits.maxSetsPerExercise - logged);
  }

  SessionSet? _lastTime(int setNumber) =>
      _exercise.lastPerformance?.sets.where((s) => s.setNumber == setNumber).firstOrNull;

  /// What to pre-fill: carry on from the set just done, else today's suggestion,
  /// else last time, else the target.
  ({double? kg, int? reps}) _prefill(int setNumber) {
    if (_exercise.sets.isNotEmpty) {
      final previous = _exercise.sets.last;
      return (kg: previous.weightKg, reps: previous.reps);
    }
    final suggestion = _exercise.suggestion;
    if (suggestion != null) return (kg: suggestion.weightKg, reps: suggestion.reps);
    final last = _lastTime(setNumber) ?? _exercise.lastPerformance?.sets.lastOrNull;
    if (last != null) return (kg: last.weightKg, reps: last.reps);
    return (kg: null, reps: _exercise.targetReps);
  }

  Future<bool> _logSet(int reps, double? weightKg) async {
    try {
      await _controller.addSet(_exercise.id, reps: reps, weightKg: weightKg);
      if (_extraRows > 0 && mounted) setState(() => _extraRows--);
      ref.read(restTimerProvider.notifier).start();
      return true;
    } catch (error) {
      if (mounted) showError(context, error);
      return false;
    }
  }

  Future<void> _editSet(SessionSet set) async {
    final edit = await showSetEditSheet(context, set);
    if (edit == null || !mounted) return;
    try {
      switch (edit) {
        case SetChanged(:final reps, :final weightKg):
          await _controller.updateSet(_exercise.id, set.id, reps: reps, weightKg: weightKg);
        case SetDeleted():
          await _controller.deleteSet(_exercise.id, set.id);
      }
    } catch (error) {
      if (mounted) showError(context, error);
    }
  }

  Future<void> _remove() async {
    final hasSets = _exercise.sets.isNotEmpty;
    if (hasSets) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Remove exercise?'),
          content: Text('The ${_exercise.sets.length} logged sets of this exercise will be deleted.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Keep')),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: AppColors.danger),
              child: const Text('Remove'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }
    try {
      await _controller.removeExercise(_exercise.id);
    } catch (error) {
      if (mounted) showError(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final logged = _exercise.sets;
    final drafts = _draftCount;
    final canAddRow = logged.length + drafts < SessionLimits.maxSetsPerExercise;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.cardBorder,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ExerciseThumb(
                url: _exercise.gifUrl,
                size: 88,
                onTap: () => showExerciseDetails(
                  context,
                  exerciseId: _exercise.exerciseId,
                  name: _exercise.name,
                  gifUrl: _exercise.gifUrl,
                  bodyPart: _exercise.bodyPart,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(capitalize(_exercise.name), style: AppText.heading),
                    const SizedBox(height: 2),
                    Text(capitalize(_exercise.bodyPart), style: AppText.caption),
                    if (_exercise.targetSets != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Target ${_exercise.targetSets} × ${_exercise.targetReps}',
                        style: AppText.secondary.copyWith(color: AppColors.accent),
                      ),
                    ],
                  ],
                ),
              ),
              PopupMenuButton<void>(
                tooltip: 'Exercise options',
                icon: const Icon(Icons.more_vert_rounded, color: AppColors.textTertiary),
                itemBuilder: (_) => [
                  PopupMenuItem(onTap: _remove, child: const Text('Remove from workout')),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _LastTime(last: _exercise.lastPerformance),
          if (_exercise.suggestion case final suggestion?) ...[
            const SizedBox(height: AppSpacing.md),
            _SuggestionLine(suggestion: suggestion, lastTop: _topWeight(_exercise.lastPerformance)),
          ],
          const SizedBox(height: AppSpacing.lg),
          const SetTableHeader(),
          const SizedBox(height: AppSpacing.sm),
          for (final set in logged) ...[
            LoggedSetRow(
              key: ValueKey(set.id),
              set: set,
              previous: _lastTime(set.setNumber),
              onTap: () => _editSet(set),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          for (var i = 0; i < drafts; i++) ...[
            Builder(builder: (context) {
              final number = logged.length + 1 + i;
              final prefill = _prefill(number);
              return DraftSetRow(
                // a new key after each logged set, so the pre-filled values follow the last set
                key: ValueKey('${_exercise.id}-$number-${logged.length}'),
                setNumber: number,
                initialKg: prefill.kg,
                initialReps: prefill.reps,
                highlighted: i == 0,
                onDone: _logSet,
              );
            }),
            const SizedBox(height: AppSpacing.sm),
          ],
          Row(
            children: [
              if (canAddRow)
                TextButton.icon(
                  onPressed: () => setState(() => _extraRows++),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add set'),
                ),
              const Spacer(),
              if (widget.onNext != null && _exercise.isDone)
                FilledButton.tonalIcon(
                  onPressed: widget.onNext,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 48),
                    backgroundColor: AppColors.accentTint(0.14),
                    foregroundColor: AppColors.accent,
                  ),
                  iconAlignment: IconAlignment.end,
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text('Next exercise'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

double? _topWeight(LastPerformance? last) => last?.sets
    .map((s) => s.weightKg)
    .whereType<double>()
    .fold<double?>(null, (max, w) => max == null || w > max ? w : max);

/// "Today 62.5 kg × 10  +2.5 · you hit every rep last time"
class _SuggestionLine extends StatelessWidget {
  const _SuggestionLine({required this.suggestion, required this.lastTop});

  final Suggestion suggestion;
  final double? lastTop;

  @override
  Widget build(BuildContext context) {
    final kg = suggestion.weightKg;
    final change = kg != null && lastTop != null ? kg - lastTop! : 0;
    final target = kg == null ? '${suggestion.reps} reps' : '${formatKg(kg)} kg × ${suggestion.reps}';

    return Semantics(
      label: 'Suggested today: $target, ${suggestion.why}',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.accentTint(),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            const Icon(Icons.lightbulb_outline_rounded, color: AppColors.accent, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(text: 'Today  '),
                        TextSpan(text: target, style: const TextStyle(color: AppColors.textPrimary)),
                        if (change != 0)
                          TextSpan(
                            text: '  ${change > 0 ? '+' : '−'}${formatKg(change.abs().toDouble())} kg',
                            style: const TextStyle(color: AppColors.accent),
                          ),
                      ],
                    ),
                    style: AppText.bodyStrong.copyWith(
                      color: AppColors.textSecondary,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(capitalize(suggestion.why), style: AppText.caption),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Last time · 4 days ago   60×10  62.5×8  62.5×8"
class _LastTime extends StatelessWidget {
  const _LastTime({required this.last});

  final LastPerformance? last;

  @override
  Widget build(BuildContext context) {
    final last = this.last;
    if (last == null) {
      return Text(
        'First time doing this one. Today sets your baseline.',
        style: AppText.secondary.copyWith(color: AppColors.textTertiary),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Last time · ${formatDaysAgo(last.performedAt)}', style: AppText.caption),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final set in last.sets)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surface2,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  '${set.weightKg == null ? 'BW' : formatKg(set.weightKg!)} × ${set.reps}',
                  style: AppText.secondary.copyWith(
                    color: AppColors.textPrimary,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
