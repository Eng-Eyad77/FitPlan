import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../shared/format.dart';
import '../../application/progress_providers.dart';
import '../../domain/stats.dart';

/// The records beaten in a workout and how it compares with the previous run of the same plan.
/// Used by the summary after finishing and by a past workout in History.
class ComparisonSection extends ConsumerWidget {
  const ComparisonSection({super.key, required this.sessionId, required this.sessionName});

  final String sessionId;
  final String sessionName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final comparison = ref.watch(sessionComparisonProvider(sessionId));

    // the comparison is a bonus: while loading or on error the screen simply goes without it
    final data = comparison.value;
    if (data == null) return const SizedBox.shrink();

    final hasPrevious = data.previousSessionId != null;
    if (!hasPrevious && data.newRecords.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: AppSpacing.lg),
        child: Text(
          'First time with "$sessionName". Next time you will see how you compare.',
          style: AppText.caption,
          textAlign: TextAlign.center,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (data.newRecords.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xxl),
          _NewRecords(records: data.newRecords),
        ],
        if (hasPrevious) ...[
          const SizedBox(height: AppSpacing.lg),
          _VersusLast(comparison: data, sessionName: sessionName),
        ],
      ],
    );
  }
}

class _NewRecords extends StatelessWidget {
  const _NewRecords({required this.records});

  final List<NewRecord> records;

  String _format(RecordType type, double value) => switch (type) {
        RecordType.mostReps => '${value.round()} reps',
        RecordType.bestSetVolume => '${NumberFormat.decimalPattern().format(value.round())} kg',
        _ => '${formatKg(double.parse(value.toStringAsFixed(1)))} kg',
      };

  /// Records of the same exercise together, in the order the API sent them.
  List<List<NewRecord>> get _byExercise {
    final groups = <String, List<NewRecord>>{};
    for (final record in records) {
      groups.putIfAbsent(record.exerciseId, () => []).add(record);
    }
    return groups.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.08),
        borderRadius: AppRadius.cardBorder,
        border: Border.all(color: AppColors.success.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.emoji_events_rounded, color: AppColors.success),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '${records.length} personal ${records.length == 1 ? 'record' : 'records'}',
                style: AppText.heading.copyWith(color: AppColors.success),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          // grouped by exercise: the name once, then each record it broke
          for (final group in _byExercise) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(capitalize(group.first.name), style: AppText.bodyStrong, maxLines: 1, overflow: TextOverflow.ellipsis),
            for (final record in group)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    Expanded(child: Text(record.type.label, style: AppText.secondary)),
                    Text(_format(record.type, record.value), style: AppText.bodyStrong),
                    const SizedBox(width: AppSpacing.sm),
                    SizedBox(
                      width: 64,
                      child: Text(
                        '+${_format(record.type, record.value - record.previousBest)}',
                        textAlign: TextAlign.end,
                        style: AppText.caption.copyWith(color: AppColors.success, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).scaleXY(begin: 0.96, end: 1, curve: Curves.easeOutBack);
  }
}

class _VersusLast extends StatelessWidget {
  const _VersusLast({required this.comparison, required this.sessionName});

  final SessionComparison comparison;
  final String sessionName;

  @override
  Widget build(BuildContext context) {
    final volume = comparison.volumeKg;
    final change = volume.percentChange;
    final number = NumberFormat.decimalPattern();

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
              Expanded(child: Text('Volume vs last $sessionName', style: AppText.bodyStrong)),
              if (change != null)
                Text(
                  '${change >= 0 ? '+' : '−'}${change.abs().round()}%',
                  style: AppText.heading.copyWith(color: change >= 0 ? AppColors.accent : AppColors.textSecondary),
                ),
            ],
          ),
          if (comparison.previousPerformedAt != null)
            Text('Last time was ${formatDaysAgo(comparison.previousPerformedAt!)}', style: AppText.caption),
          const SizedBox(height: AppSpacing.md),
          _VolumeBar(label: 'Today', value: volume.current, max: _max(volume), highlight: true, number: number),
          const SizedBox(height: AppSpacing.sm),
          _VolumeBar(label: 'Last', value: volume.previous ?? 0, max: _max(volume), highlight: false, number: number),
          if (comparison.exercises.any((e) => e.previousTopSetReps != null)) ...[
            const SizedBox(height: AppSpacing.lg),
            for (final e in comparison.exercises)
              if (e.previousTopSetReps != null) _ExerciseChange(exercise: e),
          ],
        ],
      ),
    );
  }

  static double _max(ComparedValue v) => [v.current, v.previous ?? 0, 1.0].reduce((a, b) => a > b ? a : b);
}

class _VolumeBar extends StatelessWidget {
  const _VolumeBar({
    required this.label,
    required this.value,
    required this.max,
    required this.highlight,
    required this.number,
  });

  final String label;
  final double value;
  final double max;
  final bool highlight;
  final NumberFormat number;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 48, child: Text(label, style: AppText.caption)),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 10,
              child: ColoredBox(
                color: AppColors.surface2,
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: (value / max).clamp(0, 1),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: highlight ? AppColors.signatureGradient : null,
                      color: highlight ? null : AppColors.textTertiary.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          width: 76,
          child: Text(
            '${number.format(value.round())} kg',
            style: AppText.secondary.copyWith(color: AppColors.textPrimary),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

/// "Bench press   60 × 10 → 65 × 8"
class _ExerciseChange extends StatelessWidget {
  const _ExerciseChange({required this.exercise});

  final ExerciseComparison exercise;

  String _set(double? kg, int reps) => kg == null ? '$reps reps' : '${formatKg(kg)} × $reps';

  @override
  Widget build(BuildContext context) {
    final before = exercise.previousTopSetWeightKg ?? 0;
    final now = exercise.topSetWeightKg ?? 0;
    final better = now > before || (now == before && exercise.topSetReps > exercise.previousTopSetReps!);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(capitalize(exercise.name), style: AppText.secondary, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          Text(
            _set(exercise.previousTopSetWeightKg, exercise.previousTopSetReps!),
            style: AppText.caption,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 6),
            child: Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.textTertiary),
          ),
          Text(
            _set(exercise.topSetWeightKg, exercise.topSetReps),
            style: AppText.secondary.copyWith(
              color: better ? AppColors.accent : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
