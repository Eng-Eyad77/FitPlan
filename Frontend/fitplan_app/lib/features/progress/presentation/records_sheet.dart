import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text.dart';
import '../../../shared/format.dart';
import '../../exercises/presentation/widgets/exercise_thumb.dart';
import '../domain/stats.dart';

/// The four records of one exercise.
Future<void> showRecordsSheet(BuildContext context, ExerciseRecords records) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (_) => SafeArea(
      child: SingleChildScrollView(
        padding: AppSpacing.screen.copyWith(bottom: AppSpacing.xl),
        child: _ExerciseRecordsView(records: records),
      ),
    ),
  );
}

/// Every exercise with its records.
Future<void> showAllRecordsSheet(BuildContext context, List<ExerciseRecords> all) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (context) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      builder: (context, scroll) => ListView.separated(
        controller: scroll,
        padding: AppSpacing.screen.copyWith(bottom: AppSpacing.xl),
        itemCount: all.length,
        separatorBuilder: (_, _) => const Divider(height: AppSpacing.xxxl),
        itemBuilder: (_, i) => _ExerciseRecordsView(records: all[i]),
      ),
    ),
  );
}

class _ExerciseRecordsView extends StatelessWidget {
  const _ExerciseRecordsView({required this.records});

  final ExerciseRecords records;

  @override
  Widget build(BuildContext context) {
    final rows = [
      (RecordType.heaviestWeight, records.heaviestWeight),
      (RecordType.estimated1Rm, records.bestEstimated1Rm),
      (RecordType.mostReps, records.mostReps),
      (RecordType.bestSetVolume, records.bestSetVolume),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            ExerciseThumb(url: records.gifUrl, size: 52),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(capitalize(records.name), style: AppText.heading),
                  Text(
                    '${records.sessionCount} ${records.sessionCount == 1 ? 'workout' : 'workouts'} · '
                    'last ${formatDaysAgo(records.lastPerformedAt)}',
                    style: AppText.caption,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        for (final (type, set) in rows)
          if (set != null) _RecordLine(type: type, set: set),
      ],
    );
  }
}

class _RecordLine extends StatelessWidget {
  const _RecordLine({required this.type, required this.set});

  final RecordType type;
  final RecordSet set;

  @override
  Widget build(BuildContext context) {
    final value = switch (type) {
      RecordType.heaviestWeight || RecordType.estimated1Rm => '${formatKg(set.value)} kg',
      RecordType.mostReps => '${set.value.round()} reps',
      RecordType.bestSetVolume => '${NumberFormat.decimalPattern().format(set.value.round())} kg',
    };
    final from = formatSet(set.weightKg, set.reps);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          const Icon(Icons.emoji_events_rounded, color: AppColors.success, size: 20),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(type.label, style: AppText.body),
                Text('$from · ${DateFormat('d MMM y').format(set.achievedAt.toLocal())}', style: AppText.caption),
              ],
            ),
          ),
          Text(value, style: AppText.bodyStrong.copyWith(fontFeatures: const [FontFeature.tabularFigures()])),
        ],
      ),
    );
  }
}
