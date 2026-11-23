import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text.dart';
import '../../../shared/format.dart';
import '../../progress/domain/volume.dart';
import '../../progress/presentation/widgets/comparison_section.dart';
import '../../progress/presentation/widgets/milestone_icon.dart';
import '../domain/workout_session.dart';
import '../../../l10n/l10n.dart';

/// Shown right after finishing a workout.
class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key, required this.summary});

  final SessionSummary summary;

  @override
  Widget build(BuildContext context) {
    final tiles = [
      _Stat(label: l10n.duration, value: formatDuration(summary.durationSeconds)),
      _Stat(label: l10n.volume, value: formatVolume(summary.totalVolumeKg)),
      _Stat(label: l10n.exercises, value: '${summary.exerciseCount}'),
      _Stat(label: l10n.sets, value: '${summary.setCount}'),
      if (summary.cardioDurationSeconds > 0) ...[
        _Stat(label: l10n.cardio, value: formatDuration(summary.cardioDurationSeconds)),
        // 0 = no body weight on the profile, so nothing to estimate from
        summary.estimatedCalories > 0
            ? _Stat(label: l10n.caloriesEstimated, value: l10n.kcalAmount(summary.estimatedCalories))
            : _Stat(label: l10n.calories, value: l10n.addWeightInProfile),
      ],
    ];

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: AppSpacing.screen.copyWith(top: 48, bottom: AppSpacing.xxl),
          children: [
            Center(
              child: Container(
                width: 96,
                height: 96,
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(shape: BoxShape.circle, gradient: AppColors.signatureGradient),
                child: const DecoratedBox(
                  decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.background),
                  child: Icon(Icons.check_rounded, color: AppColors.accent, size: 48),
                ),
              ),
            )
                .animate()
                .scale(begin: const Offset(0.6, 0.6), duration: 420.ms, curve: Curves.easeOutBack)
                .fadeIn(duration: 200.ms),
            const SizedBox(height: AppSpacing.xl),
            Text(l10n.workoutComplete, style: AppText.title, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.xs),
            Text(summary.name, style: AppText.secondary, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.xxxl),
            if (_celebrated(summary) case final milestones?) ...[
              _MilestoneCelebration(milestones: milestones)
                  .animate(delay: 300.ms)
                  .fadeIn(duration: 300.ms)
                  .scale(begin: const Offset(0.94, 0.94), curve: Curves.easeOutBack),
              const SizedBox(height: AppSpacing.md),
            ],
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: AppSpacing.md,
              crossAxisSpacing: AppSpacing.md,
              childAspectRatio: 1.55,
              children: tiles.animate(interval: 60.ms).fadeIn(duration: 260.ms).slideY(begin: 0.1, end: 0),
            ),
            if (Milestone.compare(summary.totalVolumeKg) case final comparison?) ...[
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  MilestoneIcon(art: Milestone.biggestWithin(summary.totalVolumeKg)!.art, size: 36),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: Text(l10n.thisWorkoutCompare(isArabic ? comparison : '${comparison[0].toLowerCase()}${comparison.substring(1)}'), style: AppText.secondary)),
                ],
              ),
            ],
            ComparisonSection(sessionId: summary.id, sessionName: summary.name),
            const SizedBox(height: AppSpacing.xxxl),
            FilledButton(onPressed: () => context.go(Routes.home), child: Text(l10n.done)),
          ],
        ),
      ),
    );
  }
}

/// The milestones this workout crossed, biggest first. Null when none (the usual case).
List<Milestone>? _celebrated(SessionSummary summary) {
  final crossed = [for (final key in summary.newMilestones) ?Milestone.byKey(key)]
    ..sort((a, b) => b.weightKg.compareTo(a.weightKg));
  return crossed.isEmpty ? null : crossed;
}

/// Shown once: the server sends the new milestones only in the answer to finishing.
class _MilestoneCelebration extends StatelessWidget {
  const _MilestoneCelebration({required this.milestones});

  final List<Milestone> milestones;

  @override
  Widget build(BuildContext context) {
    final top = milestones.first;
    final others = milestones.skip(1).map((m) => m.name).toList();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: AppRadius.cardBorder,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1F3A35), AppColors.surface],
        ),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          MilestoneIcon(art: top.art, gold: true),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.newMilestone, style: AppText.overline.copyWith(color: AppColors.success)),
                const SizedBox(height: 2),
                Text(l10n.youLifted(top.name), style: AppText.heading),
                const SizedBox(height: 2),
                Text(
                  others.isEmpty
                      ? l10n.totalPassed(formatVolumeAmount(top.weightKg), top.name)
                      : l10n.passedOnTheWay(others.join(l10n.and)),
                  style: AppText.secondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.cardBorder,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppText.caption),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text(value, style: AppText.number),
          ),
        ],
      ),
    );
  }
}
