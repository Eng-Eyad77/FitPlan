import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text.dart';
import '../../../shared/format.dart';
import '../../progress/presentation/widgets/comparison_section.dart';
import '../domain/workout_session.dart';

/// Shown right after finishing a workout.
class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key, required this.summary});

  final SessionSummary summary;

  @override
  Widget build(BuildContext context) {
    final volume = NumberFormat.decimalPattern().format(summary.totalVolumeKg.round());

    final tiles = [
      _Stat(label: 'Duration', value: formatDuration(summary.durationSeconds)),
      _Stat(label: 'Volume', value: '$volume kg'),
      _Stat(label: 'Exercises', value: '${summary.exerciseCount}'),
      _Stat(label: 'Sets', value: '${summary.setCount}'),
      if (summary.cardioDurationSeconds > 0) ...[
        _Stat(label: 'Cardio', value: formatDuration(summary.cardioDurationSeconds)),
        _Stat(label: 'Calories (estimated)', value: '≈ ${summary.estimatedCalories} kcal'),
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
            const Text('Workout complete', style: AppText.title, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.xs),
            Text(summary.name, style: AppText.secondary, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.xxxl),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: AppSpacing.md,
              crossAxisSpacing: AppSpacing.md,
              childAspectRatio: 1.55,
              children: tiles.animate(interval: 60.ms).fadeIn(duration: 260.ms).slideY(begin: 0.1, end: 0),
            ),
            ComparisonSection(sessionId: summary.id, sessionName: summary.name),
            const SizedBox(height: AppSpacing.xxxl),
            FilledButton(onPressed: () => context.go(Routes.home), child: const Text('Done')),
          ],
        ),
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
            alignment: Alignment.centerLeft,
            child: Text(value, style: AppText.number),
          ),
        ],
      ),
    );
  }
}
