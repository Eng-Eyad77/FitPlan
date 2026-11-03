import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text.dart';
import '../../../shared/format.dart';
import '../../../shared/widgets/feedback.dart';
import '../../exercises/presentation/widgets/exercise_thumb.dart';
import '../../profile/presentation/profile_screen.dart';
import '../application/progress_providers.dart';
import '../domain/stats.dart';
import 'records_sheet.dart';
import 'weekly_goal_sheet.dart';
import 'widgets/trend_chart.dart';
import 'widgets/weekly_bars.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weekStart = weekStartOf(context);
    final overview = ref.watch(statsOverviewProvider(weekStart));

    return Scaffold(
      body: SafeArea(
        child: overview.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => LoadError(
            message: errorMessage(error, 'Could not load your progress.'),
            onRetry: () => ref.invalidate(statsOverviewProvider(weekStart)),
          ),
          data: (overview) => RefreshIndicator(
            onRefresh: () async {
              invalidateWorkoutStats(ref.invalidate);
              ref.invalidate(bodyWeightHistoryProvider);
              await ref.read(statsOverviewProvider(weekStart).future);
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: AppSpacing.screen.copyWith(top: 28, bottom: 32),
              children: [
                const Text('Progress', style: AppText.title),
                const SizedBox(height: AppSpacing.xs),
                const Text('What your training adds up to.', style: AppText.secondary),
                const SizedBox(height: AppSpacing.xl),
                ...[
                  _StreakCard(overview: overview),
                  const SizedBox(height: AppSpacing.md),
                  _WeekCompare(overview: overview),
                  const SizedBox(height: AppSpacing.lg),
                  const _TrendCard(),
                  const SizedBox(height: AppSpacing.xxl),
                  const _RecentRecords(),
                  _WeeklyVolume(overview: overview),
                  const SizedBox(height: AppSpacing.xxl),
                  const _WeighIns(),
                ].animate(interval: 40.ms).fadeIn(duration: 250.ms).slideY(begin: 0.04, end: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child, this.padding = const EdgeInsets.all(AppSpacing.lg)});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.cardBorder,
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

// ---------------------------------------------------------------- streak

class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.overview});

  final StatsOverview overview;

  @override
  Widget build(BuildContext context) {
    final goal = overview.weeklyGoal;
    final done = overview.thisWeek.workouts;
    final streak = overview.currentStreakWeeks;

    final subtitle = goal == null
        ? 'A week counts when you train at least once. Set a goal to aim higher.'
        : done >= goal
            ? 'Goal reached this week: $done of $goal. Nice.'
            : '$done of $goal this week, ${goal - done} to go.';

    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.cardBorder,
        side: const BorderSide(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => showWeeklyGoalSheet(context),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: streak > 0 ? AppColors.signatureGradient : null,
                  color: streak > 0 ? null : AppColors.surface2,
                ),
                child: Icon(
                  Icons.local_fire_department_rounded,
                  color: streak > 0 ? AppColors.onAccent : AppColors.textTertiary,
                  size: 30,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      streak == 0 ? 'No streak yet' : '$streak-week streak',
                      style: AppText.heading,
                    ),
                    const SizedBox(height: 2),
                    Text(subtitle, style: AppText.secondary),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Column(
                children: [
                  Text(goal == null ? '—' : '$goal', style: AppText.number.copyWith(fontSize: 20)),
                  Text(goal == null ? 'Set goal' : 'a week', style: AppText.caption.copyWith(color: AppColors.accent)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- this week vs last

class _WeekCompare extends StatelessWidget {
  const _WeekCompare({required this.overview});

  final StatsOverview overview;

  @override
  Widget build(BuildContext context) {
    final now = overview.thisWeek;
    final last = overview.lastWeek;
    final tonnes = NumberFormat('0.0');

    return Row(
      children: [
        _Delta(label: 'Workouts', value: '${now.workouts}', diff: (now.workouts - last.workouts).toDouble()),
        const SizedBox(width: AppSpacing.sm),
        _Delta(
          label: 'Volume',
          value: '${tonnes.format(now.volumeKg / 1000)} t',
          diff: (now.volumeKg - last.volumeKg) / 1000,
          diffText: (d) => '${tonnes.format(d.abs())} t',
        ),
        const SizedBox(width: AppSpacing.sm),
        _Delta(label: 'Sets', value: '${now.sets}', diff: (now.sets - last.sets).toDouble()),
        const SizedBox(width: AppSpacing.sm),
        _Delta(
          label: 'Cardio',
          value: '${(now.cardioSeconds / 60).round()}m',
          diff: (now.cardioSeconds - last.cardioSeconds) / 60,
          diffText: (d) => '${d.abs().round()}m',
        ),
      ],
    );
  }
}

/// A number of this week, with how it moved since last week underneath.
class _Delta extends StatelessWidget {
  const _Delta({required this.label, required this.value, required this.diff, this.diffText});

  final String label;
  final String value;
  final double diff;
  final String Function(double diff)? diffText;

  @override
  Widget build(BuildContext context) {
    final text = diffText?.call(diff) ?? '${diff.abs().round()}';
    final up = diff > 0.05;
    final down = diff < -0.05;

    return Expanded(
      child: _Card(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppText.caption),
            const SizedBox(height: AppSpacing.xs),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(value, style: AppText.number.copyWith(fontSize: 20)),
            ),
            const SizedBox(height: 2),
            // a drop is shown calmly (grey), never in red: a light week is not a failure
            Text(
              up ? '▲ $text' : down ? '▼ $text' : 'same',
              style: AppText.caption.copyWith(
                color: up ? AppColors.accent : AppColors.textTertiary,
                fontWeight: up ? FontWeight.w600 : FontWeight.w400,
              ),
              maxLines: 1,
              overflow: TextOverflow.fade,
              softWrap: false,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- strength / body chart

enum _Trend { strength, body }

class _TrendCard extends StatefulWidget {
  const _TrendCard();

  @override
  State<_TrendCard> createState() => _TrendCardState();
}

class _TrendCardState extends State<_TrendCard> {
  _Trend _trend = _Trend.strength;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton<_Trend>(
            segments: const [
              ButtonSegment(value: _Trend.strength, label: Text('Strength'), icon: Icon(Icons.fitness_center_rounded)),
              ButtonSegment(value: _Trend.body, label: Text('Body'), icon: Icon(Icons.monitor_weight_outlined)),
            ],
            selected: {_trend},
            showSelectedIcon: false,
            onSelectionChanged: (value) => setState(() => _trend = value.first),
            style: SegmentedButton.styleFrom(
              backgroundColor: AppColors.surface2,
              foregroundColor: AppColors.textSecondary,
              selectedBackgroundColor: AppColors.accentTint(0.16),
              selectedForegroundColor: AppColors.accent,
              side: const BorderSide(color: AppColors.border),
              textStyle: AppText.secondary.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _trend == _Trend.strength ? const _StrengthTrend() : const _BodyTrend(),
          ),
        ],
      ),
    );
  }
}

/// "87.8 kg  +5.8 kg" with its caption, above a trend chart.
class _Headline extends StatelessWidget {
  const _Headline({required this.title, required this.value, required this.unit, this.delta, this.caption});

  final Widget title;
  final double value;
  final String unit;
  final double? delta;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final delta = this.delta;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        title,
        const SizedBox(height: AppSpacing.sm),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(formatKg(value), style: AppText.display.copyWith(fontSize: 40)),
            const SizedBox(width: AppSpacing.xs),
            Text(unit, style: AppText.secondary),
            const Spacer(),
            if (delta != null && delta.abs() >= 0.05)
              Text(
                '${delta > 0 ? '+' : '−'}${formatKg(double.parse(delta.abs().toStringAsFixed(1)))} $unit',
                style: AppText.bodyStrong.copyWith(color: delta > 0 ? AppColors.accent : AppColors.textSecondary),
              ),
          ],
        ),
        if (caption != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(caption!, style: AppText.caption),
        ],
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}

class _StrengthTrend extends ConsumerWidget {
  const _StrengthTrend();

  Future<void> _pickExercise(BuildContext context, WidgetRef ref, List<ExerciseRecords> records) async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        builder: (context, scroll) => ListView(
          controller: scroll,
          padding: AppSpacing.screen.copyWith(bottom: AppSpacing.xl),
          children: [
            const Text('Choose an exercise', style: AppText.heading),
            const SizedBox(height: AppSpacing.md),
            for (final r in records)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: ExerciseThumb(url: r.gifUrl, size: 44),
                title: Text(capitalize(r.name), style: AppText.bodyStrong),
                subtitle: Text('${r.sessionCount} ${r.sessionCount == 1 ? 'workout' : 'workouts'}', style: AppText.caption),
                onTap: () => Navigator.pop(context, r.exerciseId),
              ),
          ],
        ),
      ),
    );
    if (picked != null) ref.read(selectedExerciseProvider.notifier).select(picked);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(recordsProvider);

    return records.when(
      loading: () => const SizedBox(height: 240, child: Center(child: CircularProgressIndicator())),
      error: (error, _) => Text(errorMessage(error), style: AppText.secondary),
      data: (records) {
        if (records.isEmpty) {
          return const SizedBox(
            height: 200,
            child: Center(
              child: Text(
                'Finish a workout and your strength trend shows up here.',
                style: AppText.secondary,
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final selectedId = ref.watch(selectedExerciseProvider);
        final selected = records.where((r) => r.exerciseId == selectedId).firstOrNull ?? records.first;
        final progress = ref.watch(exerciseProgressProvider(selected.exerciseId));

        final title = InkWell(
          onTap: () => _pickExercise(context, ref, records),
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    capitalize(selected.name),
                    style: AppText.bodyStrong,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.expand_more_rounded, color: AppColors.accent),
              ],
            ),
          ),
        );

        return progress.when(
          loading: () => SizedBox(height: 240, child: Align(alignment: Alignment.topLeft, child: title)),
          error: (error, _) => Text(errorMessage(error), style: AppText.secondary),
          data: (progress) {
            final trend = _strengthPoints(progress);
            final best = progress.records.bestEstimated1Rm;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Headline(
                  title: Row(
                    children: [
                      Flexible(child: title),
                      const SizedBox(width: AppSpacing.sm),
                      Text(trend.label, style: AppText.caption),
                    ],
                  ),
                  value: trend.points.last.value,
                  unit: trend.unit,
                  delta: trend.points.length < 2 ? null : trend.points.last.value - trend.points.first.value,
                  caption: best == null
                      ? 'From your last ${trend.points.length} ${trend.points.length == 1 ? 'workout' : 'workouts'}'
                      // the headline is the latest workout; the caption names the all-time best
                      : 'Latest workout · best ${formatKg(best.value)} kg from ${best.reps} × ${formatKg(best.weightKg!)} kg',
                ),
                TrendChart(points: trend.points, unit: trend.unit),
              ],
            );
          },
        );
      },
    );
  }
}

/// The estimated 1RM when there is one; else the top set weight; for bodyweight moves, the reps.
({String label, String unit, List<TrendPoint> points}) _strengthPoints(ExerciseProgress progress) {
  final sessions = progress.sessions.length > 12
      ? progress.sessions.sublist(progress.sessions.length - 12)
      : progress.sessions;

  if (sessions.any((s) => s.estimated1Rm != null)) {
    return (
      label: 'estimated 1RM',
      unit: 'kg',
      points: [
        for (final s in sessions)
          if (s.estimated1Rm != null) (date: s.performedAt, value: s.estimated1Rm!),
      ],
    );
  }
  if (sessions.any((s) => s.topSetWeightKg != null)) {
    return (
      label: 'top set',
      unit: 'kg',
      points: [
        for (final s in sessions)
          if (s.topSetWeightKg != null) (date: s.performedAt, value: s.topSetWeightKg!),
      ],
    );
  }
  return (
    label: 'best reps',
    unit: 'reps',
    points: [for (final s in sessions) (date: s.performedAt, value: s.topSetReps.toDouble())],
  );
}

class _BodyTrend extends ConsumerWidget {
  const _BodyTrend();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(bodyWeightHistoryProvider);

    return history.when(
      loading: () => const SizedBox(height: 240, child: Center(child: CircularProgressIndicator())),
      error: (error, _) => Text(errorMessage(error), style: AppText.secondary),
      data: (entries) {
        if (entries.isEmpty) {
          return SizedBox(
            height: 200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Log your weight to see its trend.', style: AppText.secondary),
                const SizedBox(height: AppSpacing.md),
                FilledButton(
                  onPressed: () => showWeightSheet(context),
                  style: FilledButton.styleFrom(minimumSize: const Size(160, 48)),
                  child: const Text('Log weight'),
                ),
              ],
            ),
          );
        }

        final recent = entries.take(20).toList().reversed.toList(); // oldest first
        final latest = recent.last;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Headline(
              title: const Text('Body weight', style: AppText.bodyStrong),
              value: latest.weightKg,
              unit: 'kg',
              delta: recent.length < 2 ? null : latest.weightKg - recent.first.weightKg,
              caption: 'Latest weigh-in, ${formatDaysAgo(latest.recordedAt)}',
            ),
            TrendChart(
              points: [for (final e in recent) (date: e.recordedAt, value: e.weightKg)],
              unit: 'kg',
            ),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------- records

class _RecentRecords extends ConsumerWidget {
  const _RecentRecords();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(recordsProvider).value ?? const [];
    if (records.isEmpty) return const SizedBox.shrink();

    // per exercise, the record set most recently (on a tie: heaviest, 1RM, reps, volume), newest first
    RecordSet latest(ExerciseRecords r) => [r.heaviestWeight, r.bestEstimated1Rm, r.mostReps, r.bestSetVolume]
        .whereType<RecordSet>()
        .reduce((a, b) => b.achievedAt.isAfter(a.achievedAt) ? b : a);

    final best = [for (final r in records) (exercise: r, set: latest(r))]
      ..sort((a, b) => b.set.achievedAt.compareTo(a.set.achievedAt));

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(child: Text('Recent records', style: AppText.heading)),
              if (records.length > 5)
                TextButton(onPressed: () => showAllRecordsSheet(context, records), child: const Text('All')),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final item in best.take(5))
            _RecordRow(
              records: item.exercise,
              set: item.set,
              onTap: () => showRecordsSheet(context, item.exercise),
            ),
        ],
      ),
    );
  }
}

class _RecordRow extends StatelessWidget {
  const _RecordRow({required this.records, required this.set, required this.onTap});

  final ExerciseRecords records;
  final RecordSet set;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.14), shape: BoxShape.circle),
              child: const Icon(Icons.emoji_events_rounded, color: AppColors.success, size: 22),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(capitalize(records.name), style: AppText.bodyStrong, maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(capitalize(formatDaysAgo(set.achievedAt)), style: AppText.caption),
                ],
              ),
            ),
            Text(
              set.weightKg == null ? '${set.reps} reps' : '${set.reps} × ${formatKg(set.weightKg!)}',
              style: AppText.bodyStrong.copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- weekly volume

class _WeeklyVolume extends StatelessWidget {
  const _WeeklyVolume({required this.overview});

  final StatsOverview overview;

  @override
  Widget build(BuildContext context) {
    final tonnes = NumberFormat('0.0');

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Expanded(child: Text('Weekly volume', style: AppText.heading)),
              Text('tonnes lifted', style: AppText.caption),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          WeeklyBars(
            weeks: [for (final w in overview.weeks) w.weekStart],
            values: [for (final w in overview.weeks) w.volumeKg / 1000],
            format: (t) => '${tonnes.format(t)} t',
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- weigh-ins

class _WeighIns extends ConsumerWidget {
  const _WeighIns();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(bodyWeightHistoryProvider).value ?? const [];
    final date = DateFormat('EEE, d MMM');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Weigh-ins', style: AppText.heading),
        const SizedBox(height: AppSpacing.sm),
        for (var i = 0; i < entries.length && i < 4; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Row(
              children: [
                Expanded(child: Text(date.format(entries[i].recordedAt.toLocal()), style: AppText.secondary)),
                if (i + 1 < entries.length)
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.md),
                    child: Text(_change(entries[i].weightKg - entries[i + 1].weightKg), style: AppText.caption),
                  ),
                Text('${formatKg(entries[i].weightKg)} kg', style: AppText.bodyStrong),
              ],
            ),
          ),
        const SizedBox(height: AppSpacing.sm),
        OutlinedButton.icon(
          onPressed: () => showWeightSheet(context, current: entries.firstOrNull?.weightKg),
          icon: const Icon(Icons.add_rounded),
          label: const Text("Log today's weight"),
        ),
      ],
    );
  }

  static String _change(double diff) {
    if (diff.abs() < 0.05) return 'same';
    final value = formatKg(double.parse(diff.abs().toStringAsFixed(1)));
    return diff > 0 ? '+$value' : '−$value';
  }
}
