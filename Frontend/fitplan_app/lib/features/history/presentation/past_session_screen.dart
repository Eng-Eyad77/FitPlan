import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text.dart';
import '../../../shared/format.dart';
import '../../../shared/widgets/feedback.dart';
import '../../exercises/presentation/exercise_details_sheet.dart';
import '../../exercises/presentation/widgets/exercise_thumb.dart';
import '../../session/domain/workout_session.dart';
import '../../session/presentation/cardio_sheet.dart';
import '../application/history_controller.dart';

/// A finished workout with every set, cardio and notes.
class PastSessionScreen extends ConsumerWidget {
  const PastSessionScreen({super.key, required this.sessionId});

  final String sessionId;

  Future<void> _delete(BuildContext context, WidgetRef ref, WorkoutSession session) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete workout?'),
        content: Text('"${session.name}" and all its sets will be deleted. This cannot be undone.'),
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
      await ref.read(historyControllerProvider.notifier).delete(session.id);
      if (context.mounted) context.pop();
    } catch (error) {
      if (context.mounted) showError(context, error);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(pastSessionProvider(sessionId));

    return Scaffold(
      appBar: AppBar(
        title: Text(session.value?.name ?? 'Workout', style: AppText.heading),
        actions: [
          if (session.value != null)
            PopupMenuButton<void>(
              tooltip: 'Workout options',
              itemBuilder: (_) => [
                PopupMenuItem(
                  onTap: () => _delete(context, ref, session.value!),
                  child: const Text('Delete workout', style: TextStyle(color: AppColors.danger)),
                ),
              ],
            ),
        ],
      ),
      body: session.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => LoadError(
          message: errorMessage(error, 'Could not load this workout.'),
          onRetry: () => ref.invalidate(pastSessionProvider(sessionId)),
        ),
        data: (session) => _Body(session: session),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.session});

  final WorkoutSession session;

  @override
  Widget build(BuildContext context) {
    final started = session.startedAt.toLocal();
    final end = (session.completedAt ?? session.startedAt).toLocal();
    final volume = session.exercises
        .expand((e) => e.sets)
        .fold<double>(0, (sum, s) => sum + s.reps * (s.weightKg ?? 0));
    final calories = session.cardio.fold<int>(0, (sum, c) => sum + (c.estimatedCalories ?? 0));
    // exercises added but never done are not interesting here
    final done = session.exercises.where((e) => e.sets.isNotEmpty).toList();

    return ListView(
      padding: AppSpacing.screen.copyWith(top: AppSpacing.sm, bottom: AppSpacing.xxxl),
      children: [
        Text(
          '${DateFormat('EEEE, d MMMM').format(started)} · ${DateFormat.jm().format(started)}',
          style: AppText.secondary,
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            _Stat(label: 'Time', value: formatDuration(end.difference(started).inSeconds)),
            const SizedBox(width: AppSpacing.sm),
            _Stat(label: 'Volume', value: '${NumberFormat.decimalPattern().format(volume.round())} kg'),
            const SizedBox(width: AppSpacing.sm),
            _Stat(label: 'Sets', value: '${session.setCount}'),
            if (calories > 0) ...[
              const SizedBox(width: AppSpacing.sm),
              _Stat(label: 'kcal', value: '≈ $calories'),
            ],
          ],
        ),
        if (session.notes != null) ...[
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.accentTint(),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.notes_rounded, color: AppColors.accent, size: 20),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: Text(session.notes!, style: AppText.body)),
              ],
            ),
          ),
        ],
        if (done.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xxl),
          const Text('Exercises', style: AppText.heading),
          const SizedBox(height: AppSpacing.md),
          for (final exercise in done) ...[
            _ExerciseSets(exercise: exercise),
            const SizedBox(height: AppSpacing.md),
          ],
        ],
        if (session.cardio.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          const Text('Cardio', style: AppText.heading),
          const SizedBox(height: AppSpacing.md),
          for (final entry in session.cardio) ...[
            _CardioRow(entry: entry),
            const SizedBox(height: AppSpacing.sm),
          ],
        ],
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(value, style: AppText.bodyStrong.copyWith(fontSize: 17)),
            ),
            const SizedBox(height: 2),
            Text(label, style: AppText.caption),
          ],
        ),
      ),
    );
  }
}

class _ExerciseSets extends StatelessWidget {
  const _ExerciseSets({required this.exercise});

  final SessionExercise exercise;

  @override
  Widget build(BuildContext context) {
    final best = exercise.sets
        .where((s) => s.weightKg != null)
        .fold<double?>(null, (max, s) => max == null || s.weightKg! > max ? s.weightKg : max);

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
            children: [
              ExerciseThumb(
                url: exercise.gifUrl,
                size: 52,
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
                    Text(capitalize(exercise.name), style: AppText.bodyStrong, maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(
                      best == null ? capitalize(exercise.bodyPart) : 'Top set ${formatKg(best)} kg',
                      style: AppText.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          for (final set in exercise.sets)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  SizedBox(
                    width: 32,
                    child: Text('${set.setNumber}', style: AppText.secondary.copyWith(color: AppColors.textTertiary)),
                  ),
                  Text(
                    set.weightKg == null ? 'Bodyweight' : '${formatKg(set.weightKg!)} kg',
                    style: AppText.body.copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
                  ),
                  const Spacer(),
                  Text(
                    '× ${set.reps}',
                    style: AppText.bodyStrong.copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _CardioRow extends StatelessWidget {
  const _CardioRow({required this.entry});

  final CardioEntry entry;

  @override
  Widget build(BuildContext context) {
    final details = [
      formatDuration(entry.durationSeconds),
      if (entry.speedKmh != null) '${formatKg(entry.speedKmh!)} km/h',
      if (entry.inclinePercent != null) '${formatKg(entry.inclinePercent!)}% incline',
      if (entry.distanceKm != null) '${formatKg(entry.distanceKm!)} km',
    ].join(' · ');

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.md)),
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
          if (entry.estimatedCalories != null)
            Text('≈ ${entry.estimatedCalories} kcal', style: AppText.secondary.copyWith(color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
