import 'package:fitplan_shared/fitplan_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/adaptive.dart';
import '../../../../shared/widgets/exercise_note.dart';
import '../../../../shared/format.dart';
import '../../../../shared/widgets/feedback.dart';
import '../../../exercises/presentation/exercise_details_sheet.dart';
import '../../../exercises/presentation/widgets/exercise_thumb.dart';
import '../../application/active_session_controller.dart';
import '../../application/next_set.dart';
import '../../application/rest_notifications.dart';
import '../../application/rest_timer.dart';
import '../../application/session_drafts.dart';
import '../../domain/workout_session.dart';
import 'rest_sheet.dart';
import 'set_edit_sheet.dart';
import 'set_rows.dart';
import '../../../../l10n/l10n.dart';
import '../../../exercises/presentation/widgets/exercise_name.dart';

/// The open exercise in the list: what to do, what you did last time, and the sets.
class ExerciseCard extends ConsumerStatefulWidget {
  const ExerciseCard({
    super.key,
    required this.exercise,
    this.isActive = false,
    this.onNext,
    this.onCollapse,
    this.onCompleted,
  });

  final SessionExercise exercise;

  /// The exercise to do now (the first one not done), marked without moving it.
  final bool isActive;

  /// Shown as "Next exercise" once it is done (an exercise without a target).
  final VoidCallback? onNext;

  /// Closes the card. What was typed stays.
  final VoidCallback? onCollapse;

  /// The last target set was just logged.
  final VoidCallback? onCompleted;

  @override
  ConsumerState<ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends ConsumerState<ExerciseCard> {
  SessionExercise get _exercise => widget.exercise;

  SessionDrafts get _drafts => ref.read(sessionDraftsProvider);

  /// Extra empty rows the user asked for with "+ Add set" (kept while the card is closed).
  int get _extraRows => _drafts.extraRows(_exercise.id);
  set _extraRows(int rows) => _drafts.setExtraRows(_exercise.id, rows);

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

  Future<bool> _logSet(int rowNumber, int reps, double? weightKg) async {
    final rest = Duration(seconds: _exercise.restOrDefault);
    final target = _exercise.targetSets;
    final before = _exercise.sets.length;
    try {
      await _controller.addSet(_exercise.id, reps: reps, weightKg: weightKg);
      _drafts.clearValue(_exercise.id, rowNumber);
      if (_extraRows > 0 && mounted) setState(() => _extraRows--);
      // the next set, pre-filled with this one's values as its row is, so the notification can log it
      final next = NextSet(
        sessionId: ref.read(activeSessionControllerProvider).value?.id ?? '',
        sessionExerciseId: _exercise.id,
        name: capitalize(_exercise.name),
        setNumber: before + 1,
        reps: reps,
        weightKg: weightKg,
        targetSets: target,
        restSeconds: _exercise.restOrDefault,
      ).following;
      final completed = target != null && before + 1 == target;
      ref.read(restTimerProvider.notifier).start(rest, next == null ? RestTexts.nextExercise : null, next);
      if (completed) widget.onCompleted?.call();
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

  Future<void> _changeRest() async {
    final seconds = await showRestSheet(context, title: capitalize(_exercise.name), seconds: _exercise.restOrDefault);
    if (seconds == null || seconds == _exercise.restSeconds || !mounted) return;
    try {
      await _controller.setRest(_exercise.id, seconds);
    } catch (error) {
      if (mounted) showError(context, error);
    }
  }

  Future<void> _remove() async {
    final hasSets = _exercise.sets.isNotEmpty;
    if (hasSets) {
      final confirmed = await confirmAction(
        context,
        title: l10n.removeExerciseTitle,
        body: l10n.removeExerciseBody(_exercise.sets.length),
        confirmLabel: l10n.remove,
        cancelLabel: l10n.keep,
      );
      if (!confirmed) return;
    }
    try {
      await _controller.removeExercise(_exercise.id);
    } catch (error) {
      if (mounted) showError(context, error);
    }
  }

  Future<void> _editNote() async {
    final note = await showNoteSheet(context, initial: _exercise.note);
    if (note == null || !mounted) return;
    try {
      await _controller.setNote(_exercise.id, note);
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
        border: Border.all(color: widget.isActive ? AppColors.accent.withValues(alpha: 0.6) : AppColors.border),
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
                    if (widget.isActive) ...[
                      const NowBadge(),
                      const SizedBox(height: AppSpacing.xs),
                    ],
                    ExerciseName(name: _exercise.name, englishName: _exercise.englishName, style: AppText.heading, maxLines: 3),
                    const SizedBox(height: 2),
                    Text(bodyPartName(_exercise.bodyPart), style: AppText.caption),
                    if (_exercise.targetSets != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        l10n.targetSetsReps(_exercise.targetSets!, _exercise.targetReps!),
                        style: AppText.secondary.copyWith(color: AppColors.accent),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xs),
                    _RestChip(seconds: _exercise.restOrDefault, onTap: _changeRest),
                  ],
                ),
              ),
              if (widget.onCollapse != null)
                IconButton(
                  tooltip: l10n.closeName(capitalize(_exercise.name)),
                  onPressed: widget.onCollapse,
                  icon: const Icon(Icons.expand_less_rounded, color: AppColors.textTertiary),
                ),
              ActionsButton(
                tooltip: l10n.exerciseOptions,
                color: AppColors.textTertiary,
                actions: () => [
                  MenuAction(
                    label: l10n.removeFromWorkout,
                    icon: Icons.remove_circle_outline_rounded,
                    destructive: true,
                    onTap: _remove,
                  ),
                ],
              ),
            ],
          ),
          // where the seat goes, read before the first set; changing it here updates the plan at the end
          const SizedBox(height: AppSpacing.md),
          ExerciseNoteLine(note: _exercise.note, onEdit: _editNote),
          const SizedBox(height: AppSpacing.md),
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
                typed: _drafts.value(_exercise.id, number),
                onTyped: (kg, reps) => _drafts.setValue(_exercise.id, number, kg: kg, reps: reps),
                highlighted: i == 0,
                onDone: (reps, kg) => _logSet(number, reps, kg),
              );
            }),
            const SizedBox(height: AppSpacing.sm),
          ],
          // wraps on narrow screens instead of overflowing
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              if (canAddRow)
                TextButton.icon(
                  onPressed: () => setState(() => _extraRows++),
                  icon: const Icon(Icons.add_rounded),
                  label: Text(l10n.addSet),
                ),
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
                  label: Text(l10n.nextExercise),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// "NOW" on the exercise to do next.
class NowBadge extends StatelessWidget {
  const NowBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.accentTint(0.16),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(l10n.now, style: AppText.overline.copyWith(color: AppColors.accent)),
    );
  }
}

/// "Rest 1:30" with a timer icon. Tap to change it for this workout.
class _RestChip extends StatelessWidget {
  const _RestChip({required this.seconds, required this.onTap});

  final int seconds;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: l10n.restChipSemantics(formatRest(seconds)),
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.timer_outlined, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  l10n.restChip(formatRest(seconds)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.caption.copyWith(color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.edit_outlined, size: 14, color: AppColors.textTertiary),
            ],
          ),
        ),
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
    final target = formatSet(kg, suggestion.reps);

    return Semantics(
      label: l10n.suggestedToday(target, suggestion.why),
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
                        TextSpan(text: l10n.todayPrefix),
                        TextSpan(text: target, style: const TextStyle(color: AppColors.textPrimary)),
                        if (change != 0)
                          TextSpan(
                            text: '  ${l10n.amountKg(signed('${change > 0 ? '+' : '−'}${formatKg(change.abs().toDouble())}'))}',
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
        l10n.firstTimeExercise,
        style: AppText.secondary.copyWith(color: AppColors.textTertiary),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.lastTimeWhen(formatDaysAgo(last.performedAt)), style: AppText.caption),
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
                  '${set.weightKg == null ? l10n.bodyweightShort : formatKg(set.weightKg!)} × ${set.reps}',
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
