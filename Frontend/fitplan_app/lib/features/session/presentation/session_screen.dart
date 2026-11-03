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
import '../../exercises/presentation/widgets/exercise_thumb.dart';
import '../application/active_session_controller.dart';
import '../application/rest_timer.dart';
import '../domain/workout_session.dart';
import 'cardio_sheet.dart';
import 'finish_sheet.dart';
import 'widgets/elapsed_clock.dart';
import 'widgets/exercise_card.dart';
import 'widgets/rest_timer_bar.dart';

/// The live workout. Everything is saved to the server as it is logged.
class SessionScreen extends ConsumerStatefulWidget {
  const SessionScreen({super.key});

  @override
  ConsumerState<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends ConsumerState<SessionScreen> {
  /// The exercise shown in the big card. Null = the first one not done yet.
  String? _focusedId;

  ActiveSessionController get _controller => ref.read(activeSessionControllerProvider.notifier);

  SessionExercise? _focused(WorkoutSession session) {
    final list = session.exercises;
    if (list.isEmpty) return null;
    return list.where((e) => e.id == _focusedId).firstOrNull ??
        list.where((e) => !e.isDone).firstOrNull ??
        list.last;
  }

  Future<void> _addExercise(WorkoutSession session) async {
    final exercise = await context.push<Exercise>(
      Routes.exercisePicker,
      extra: {for (final e in session.exercises) e.exerciseId},
    );
    if (exercise == null || !mounted) return;
    try {
      await _controller.addExercise(exercise.id);
      final added = ref.read(activeSessionControllerProvider).value?.exercises.lastOrNull;
      if (mounted) setState(() => _focusedId = added?.id);
    } catch (error) {
      if (mounted) showError(context, error);
    }
  }

  Future<void> _cancel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard workout?'),
        content: const Text('Everything you logged in this workout will be deleted.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Keep going')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await _controller.cancel();
      ref.read(restTimerProvider.notifier).skip();
      if (mounted) context.pop();
    } catch (error) {
      if (mounted) showError(context, error);
    }
  }

  Future<void> _finish(WorkoutSession session) async {
    if (!session.hasAnythingLogged) {
      showMessage(context, 'Log at least one set or some cardio first, or discard the workout.');
      return;
    }
    final summary = await showFinishSheet(context, session);
    if (summary == null || !mounted) return;
    ref.read(restTimerProvider.notifier).skip();
    context.pushReplacement(Routes.sessionSummary, extra: summary);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(activeSessionControllerProvider);
    final session = state.value;

    if (session == null) {
      return Scaffold(
        appBar: AppBar(),
        body: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : state.hasError
                ? LoadError(
                    message: errorMessage(state.error!, 'Could not load your workout.'),
                    onRetry: () => ref.invalidate(activeSessionControllerProvider),
                  )
                : EmptyState(
                    icon: Icons.check_circle_outline_rounded,
                    title: 'No workout in progress',
                    message: 'Start one from a plan, or a quick workout.',
                    action: OutlinedButton(onPressed: () => context.pop(), child: const Text('Back')),
                  ),
      );
    }

    final focused = _focused(session);
    // pin it: finishing its last set must not jump to the next one under the user's finger
    // (also re-pins after the focused exercise was removed)
    _focusedId = focused?.id;
    final others = session.exercises.where((e) => e.id != focused?.id).toList();
    final doneCount = session.exercises.where((e) => e.isDone).length;
    final total = session.exercises.length;
    final focusedIndex = focused == null ? -1 : session.exercises.indexOf(focused);
    final nextNotDone = session.exercises
        .skip(focusedIndex + 1)
        .where((e) => !e.isDone)
        .firstOrNull;

    return Scaffold(
        appBar: AppBar(
          // leaving the screen does not stop the workout: Home offers to resume it
          leading: IconButton(
            tooltip: 'Minimise',
            icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 30),
            onPressed: () => context.pop(),
          ),
          titleSpacing: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(session.name, style: AppText.heading, maxLines: 1, overflow: TextOverflow.ellipsis),
              ElapsedClock(
                since: session.startedAt,
                style: AppText.caption.copyWith(
                  color: AppColors.accent,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          actions: [
            PopupMenuButton<void>(
              tooltip: 'Workout options',
              itemBuilder: (_) => [
                PopupMenuItem(
                  onTap: _cancel,
                  child: const Text('Discard workout', style: TextStyle(color: AppColors.danger)),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.md),
              child: FilledButton(
                onPressed: () => _finish(session),
                style: FilledButton.styleFrom(minimumSize: const Size(88, 44)),
                child: const Text('Finish'),
              ),
            ),
          ],
          bottom: total == 0
              ? null
              : PreferredSize(
                  preferredSize: const Size.fromHeight(4),
                  child: _GradientProgress(value: doneCount / total),
                ),
        ),
        body: ListView(
          padding: AppSpacing.screen.copyWith(top: AppSpacing.lg, bottom: AppSpacing.xxxl),
          children: [
            if (focused == null)
              _EmptyWorkoutCard(onAdd: () => _addExercise(session))
            else ...[
              Text('EXERCISE ${focusedIndex + 1} OF $total', style: AppText.overline),
              const SizedBox(height: AppSpacing.md),
              ExerciseCard(
                key: ValueKey(focused.id),
                exercise: focused,
                onNext: nextNotDone == null ? null : () => setState(() => _focusedId = nextNotDone.id),
              ),
            ],
            if (others.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xxl),
              const Text('Exercises', style: AppText.heading),
              const SizedBox(height: AppSpacing.md),
              for (final e in others)
                _ExerciseTile(exercise: e, onTap: () => setState(() => _focusedId = e.id)),
            ],
            if (focused != null) ...[
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton.icon(
                onPressed: () => _addExercise(session),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add exercise'),
              ),
            ],
            const SizedBox(height: AppSpacing.xxl),
            _CardioSection(session: session),
          ],
        ),
        bottomNavigationBar: const RestTimerBar(),
    );
  }
}

class _GradientProgress extends StatelessWidget {
  const _GradientProgress({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 4,
      width: double.infinity,
      child: ColoredBox(
        color: AppColors.surface2,
        child: AnimatedFractionallySizedBox(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          alignment: Alignment.centerLeft,
          widthFactor: value.clamp(0, 1),
          heightFactor: 1,
          child: const DecoratedBox(decoration: BoxDecoration(gradient: AppColors.signatureGradient)),
        ),
      ),
    );
  }
}

class _EmptyWorkoutCard extends StatelessWidget {
  const _EmptyWorkoutCard({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.accentTint(),
        borderRadius: BorderRadius.circular(AppRadius.hero),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('QUICK WORKOUT', style: AppText.overline),
          const SizedBox(height: AppSpacing.md),
          const Text('What are you training?', style: AppText.title),
          const SizedBox(height: AppSpacing.sm),
          const Text('Add exercises as you go, or just log some cardio.', style: AppText.secondary),
          const SizedBox(height: AppSpacing.xl),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add exercise'),
          ),
        ],
      ),
    );
  }
}

/// A row in the exercises list (not the one in focus). Tap to switch to it.
class _ExerciseTile extends StatelessWidget {
  const _ExerciseTile({required this.exercise, required this.onTap});

  final SessionExercise exercise;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final logged = exercise.sets.length;
    final progress = exercise.targetSets == null
        ? '$logged ${logged == 1 ? 'set' : 'sets'}'
        : '$logged / ${exercise.targetSets} sets';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                ExerciseThumb(url: exercise.gifUrl, size: 48),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        capitalize(exercise.name),
                        style: AppText.bodyStrong,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        exercise.targetSets == null
                            ? progress
                            : '$progress · target ${exercise.targetSets} × ${exercise.targetReps}',
                        style: AppText.caption,
                      ),
                    ],
                  ),
                ),
                Icon(
                  exercise.isDone ? Icons.check_circle_rounded : Icons.chevron_right_rounded,
                  color: exercise.isDone ? AppColors.accent : AppColors.textTertiary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CardioSection extends ConsumerWidget {
  const _CardioSection({required this.session});

  final WorkoutSession session;

  Future<void> _delete(BuildContext context, WidgetRef ref, CardioEntry entry) async {
    try {
      await ref.read(activeSessionControllerProvider.notifier).deleteCardio(entry.id);
    } catch (error) {
      if (context.mounted) showError(context, error);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Cardio', style: AppText.heading),
        const SizedBox(height: AppSpacing.xs),
        if (session.cardio.isEmpty)
          const Text('Finish with some cardio? Pick the machine and how long.', style: AppText.secondary),
        for (final entry in session.cardio)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: _CardioTile(entry: entry, onDelete: () => _delete(context, ref, entry)),
          ),
        const SizedBox(height: AppSpacing.md),
        OutlinedButton.icon(
          onPressed: () => showCardioSheet(context),
          icon: const Icon(Icons.directions_run_rounded),
          label: const Text('Add cardio'),
        ),
      ],
    );
  }
}

class _CardioTile extends StatelessWidget {
  const _CardioTile({required this.entry, required this.onDelete});

  final CardioEntry entry;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final details = [
      formatDuration(entry.durationSeconds),
      if (entry.speedKmh != null) '${formatKg(entry.speedKmh!)} km/h',
      if (entry.inclinePercent != null) '${formatKg(entry.inclinePercent!)}% incline',
      if (entry.distanceKm != null) '${formatKg(entry.distanceKm!)} km',
    ].join(' · ');

    return Container(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.xs, AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Icon(cardioIcon(entry.machine), color: AppColors.accent),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.machine.label, style: AppText.bodyStrong),
                const SizedBox(height: 2),
                Text(details, style: AppText.caption),
              ],
            ),
          ),
          Text(
            entry.estimatedCalories == null ? '— kcal' : '≈ ${entry.estimatedCalories} kcal',
            style: AppText.secondary.copyWith(color: AppColors.textPrimary),
          ),
          IconButton(
            tooltip: 'Delete cardio',
            onPressed: onDelete,
            icon: const Icon(Icons.close_rounded, color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }
}
