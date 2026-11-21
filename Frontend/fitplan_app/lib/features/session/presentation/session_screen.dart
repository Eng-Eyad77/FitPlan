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
import '../application/session_drafts.dart';
import '../domain/workout_session.dart';
import 'cardio_sheet.dart';
import 'finish_sheet.dart';
import 'plan_additions_sheet.dart';
import 'widgets/elapsed_clock.dart';
import 'widgets/exercise_card.dart';
import 'widgets/rest_timer_bar.dart';

/// The live workout. Everything is saved to the server as it is logged.
class SessionScreen extends ConsumerStatefulWidget {
  const SessionScreen({super.key});

  @override
  ConsumerState<SessionScreen> createState() => _SessionScreenState();
}

enum _CardioChoice { add, finishWithout }

class _SessionScreenState extends ConsumerState<SessionScreen> {
  /// The one open card. Null = all closed. The list itself never changes order.
  String? _openId;

  /// The first build opens the exercise to do now.
  bool _opened = false;

  /// Finished: keep the screen blank behind the last sheets instead of "No workout".
  bool _finishing = false;

  final _openKey = GlobalKey();

  ActiveSessionController get _controller => ref.read(activeSessionControllerProvider.notifier);

  static List<SessionExercise> _inOrder(WorkoutSession session) =>
      [...session.exercises]..sort((a, b) => a.order.compareTo(b.order));

  /// The first exercise not done yet, in the saved order.
  static SessionExercise? _active(List<SessionExercise> list) => list.where((e) => !e.isDone).firstOrNull;

  /// The next one not done after [id], wrapping round to earlier ones.
  static SessionExercise? _nextNotDone(List<SessionExercise> list, String id) {
    final index = list.indexWhere((e) => e.id == id);
    return [...list.skip(index + 1), ...list.take(index < 0 ? 0 : index)].where((e) => !e.isDone).firstOrNull;
  }

  void _open(String? id) {
    setState(() => _openId = id);
    if (id == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final target = _openKey.currentContext;
      if (target != null && target.mounted) {
        Scrollable.ensureVisible(target, duration: const Duration(milliseconds: 300), alignment: 0.05);
      }
    });
  }

  void _toggle(String id) => _open(_openId == id ? null : id);

  /// Its last target set was logged: close it and open the next one not done.
  void _completed(String id) {
    final session = ref.read(activeSessionControllerProvider).value;
    if (session == null || !mounted) return;
    _open(_nextNotDone(_inOrder(session), id)?.id);
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
      if (mounted) _open(added?.id);
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
      ref.read(sessionDraftsProvider).clear();
      if (mounted) context.pop();
    } catch (error) {
      if (mounted) showError(context, error);
    }
  }

  /// No cardio yet: offer it once, never force it. Null = stay in the workout.
  Future<_CardioChoice?> _askCardio() => showModalBottomSheet<_CardioChoice>(
        context: context,
        builder: (context) => SafeArea(
          child: Padding(
            padding: AppSpacing.screen.copyWith(bottom: AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('No cardio today?', style: AppText.heading),
                const SizedBox(height: AppSpacing.xs),
                const Text('A few minutes of cardio is a good way to finish. It is up to you.',
                    style: AppText.secondary),
                const SizedBox(height: AppSpacing.lg),
                FilledButton.icon(
                  onPressed: () => Navigator.pop(context, _CardioChoice.add),
                  icon: const Icon(Icons.directions_run_rounded),
                  label: const Text('Add cardio'),
                ),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context, _CardioChoice.finishWithout),
                  child: const Text('Finish without cardio'),
                ),
              ],
            ),
          ),
        ),
      );

  /// Cardio reminder, then notes and finish, then the plan question, then the summary.
  Future<void> _finish(WorkoutSession session) async {
    if (!session.hasAnythingLogged) {
      showMessage(context, 'Log at least one set or some cardio first, or discard the workout.');
      return;
    }
    if (session.cardio.isEmpty) {
      final choice = await _askCardio();
      if (choice == null || !mounted) return;
      if (choice == _CardioChoice.add) {
        await showCardioSheet(context);
        if (!mounted) return;
        // closed without adding: back to the workout
        if (ref.read(activeSessionControllerProvider).value?.cardio.isEmpty ?? true) return;
      }
    }

    // the latest state, before finishing clears it
    final finished = ref.read(activeSessionControllerProvider).value ?? session;
    final summary = await showFinishSheet(context, finished);
    if (summary == null || !mounted) return;
    setState(() => _finishing = true);
    ref.read(restTimerProvider.notifier).skip();
    ref.read(sessionDraftsProvider).clear();

    // the workout is saved; declining here changes nothing
    await offerPlanAdditions(context, ref, finished);
    if (!mounted) return;
    context.pushReplacement(Routes.sessionSummary, extra: summary);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(activeSessionControllerProvider);
    final session = state.value;

    if (session == null) {
      if (_finishing) return const Scaffold(body: SizedBox.shrink());
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

    final exercises = _inOrder(session);
    final active = _active(exercises);
    if (!_opened) {
      _opened = true;
      _openId = active?.id;
    }
    final doneCount = exercises.where((e) => e.isDone).length;
    final total = exercises.length;

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
          // scrolling the workout closes the keyboard
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: AppSpacing.screen.copyWith(top: AppSpacing.lg, bottom: AppSpacing.xxxl),
          children: [
            if (exercises.isEmpty)
              _EmptyWorkoutCard(onAdd: () => _addExercise(session))
            else ...[
              Text('$doneCount OF $total DONE', style: AppText.overline),
              const SizedBox(height: AppSpacing.md),
              for (final (index, e) in exercises.indexed)
                if (e.id == _openId)
                  Padding(
                    key: _openKey,
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: ExerciseCard(
                      key: ValueKey(e.id),
                      exercise: e,
                      isActive: e.id == active?.id,
                      onCollapse: () => _toggle(e.id),
                      onCompleted: () => _completed(e.id),
                      onNext: switch (_nextNotDone(exercises, e.id)) {
                        final next? => () => _open(next.id),
                        null => null,
                      },
                    ),
                  )
                else
                  _ExerciseTile(
                    key: ValueKey('tile-${e.id}'),
                    number: index + 1,
                    exercise: e,
                    isActive: e.id == active?.id,
                    onTap: () => _toggle(e.id),
                  ),
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

/// A closed exercise in the list. Tap to open it; its place never changes.
class _ExerciseTile extends StatelessWidget {
  const _ExerciseTile({
    super.key,
    required this.number,
    required this.exercise,
    required this.isActive,
    required this.onTap,
  });

  final int number;
  final SessionExercise exercise;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final logged = exercise.sets.length;
    final progress = exercise.targetSets == null
        ? '$logged ${logged == 1 ? 'set' : 'sets'}'
        : '$logged / ${exercise.targetSets} sets';
    final name = capitalize(exercise.name);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Semantics(
        button: true,
        label: '$number. $name, $progress${exercise.isDone ? ', done' : ''}${isActive ? ', do this now' : ''}. Tap to open.',
        excludeSemantics: true,
        child: Material(
          color: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            side: isActive
                ? BorderSide(color: AppColors.accent.withValues(alpha: 0.6))
                : BorderSide.none,
          ),
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
                        if (isActive) ...[
                          const NowBadge(),
                          const SizedBox(height: 2),
                        ],
                        Text(
                          '$number. $name',
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
                    exercise.isDone ? Icons.check_circle_rounded : Icons.expand_more_rounded,
                    color: exercise.isDone ? AppColors.accent : AppColors.textTertiary,
                  ),
                ],
              ),
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
    final details = [formatDuration(entry.durationSeconds), ...entry.details].join(' · ');

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
