import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text.dart';
import '../../auth/application/auth_controller.dart';
import '../../history/application/history_controller.dart';
import '../../history/presentation/history_screen.dart';
import '../../progress/application/progress_providers.dart';
import '../../plans/application/plans_controller.dart';
import '../../profile/application/profile_controller.dart';
import '../../profile/presentation/widgets/profile_avatar.dart';
import '../../session/application/active_session_controller.dart';
import '../../session/presentation/start_workout.dart';
import '../../session/presentation/widgets/elapsed_clock.dart';
import '../../../l10n/l10n.dart';

/// Home: greeting, this week, what to do next and the last workout.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static String _greeting(DateTime now) => switch (now.hour) {
        < 12 => l10n.goodMorning,
        < 18 => l10n.goodAfternoon,
        _ => l10n.goodEvening,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final username = ref.watch(authControllerProvider).value?.username ?? '';
    final profile = ref.watch(profileControllerProvider).value;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: AppSpacing.screen.copyWith(top: 28, bottom: 24),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.greeting(_greeting(DateTime.now()), username), style: AppText.secondary),
                      const SizedBox(height: AppSpacing.xs),
                      Text(l10n.readyToTrain, style: AppText.title),
                    ],
                  ),
                ),
                const _LanguageToggle(),
                const SizedBox(width: AppSpacing.sm),
                Tooltip(
                  message: l10n.profile,
                  child: Semantics(
                    button: true,
                    label: l10n.openProfile,
                    child: GestureDetector(
                      onTap: () => context.push(Routes.profile),
                      child: ProfileAvatar(
                        initial: username.isEmpty ? '?' : username[0].toUpperCase(),
                        pictureUrl: profile?.profilePictureUrl,
                        size: AppSpacing.minTouch,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),
            const _WeekCard(),
            const SizedBox(height: AppSpacing.lg),
            const _UpNextCard(),
            const _LastSession(),
          ].animate(interval: 50.ms).fadeIn(duration: 280.ms).slideY(begin: 0.06, end: 0),
        ),
      ),
    );
  }
}

/// The main action of the day: resume the running workout, start a plan, or make the first plan.
class _UpNextCard extends ConsumerWidget {
  const _UpNextCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(activeSessionControllerProvider).value;
    final plans = ref.watch(plansControllerProvider);
    final plan = plans.value?.where((p) => p.exerciseCount > 0).firstOrNull;

    final Widget content;
    if (active != null) {
      final sets = active.setCount;
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(l10n.inProgress, style: AppText.overline),
              const Spacer(),
              ElapsedClock(
                since: active.startedAt,
                style: AppText.bodyStrong.copyWith(
                  color: AppColors.accent,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(active.name, style: AppText.title),
          const SizedBox(height: AppSpacing.sm),
          Text(l10n.setsLoggedSoFar(sets), style: AppText.secondary),
          const SizedBox(height: AppSpacing.xl),
          FilledButton.icon(
            onPressed: () => context.push(Routes.session),
            icon: const Icon(Icons.play_arrow_rounded),
            label: Text(l10n.resumeWorkout),
          ),
        ],
      );
    } else if (plan != null) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.upNext, style: AppText.overline),
          const SizedBox(height: AppSpacing.md),
          Text(plan.name, style: AppText.title),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${l10n.exerciseCount(plan.exerciseCount)}'
            '${plan.description == null ? '' : ' · ${plan.description}'}',
            style: AppText.secondary,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xl),
          FilledButton.icon(
            onPressed: () => startWorkout(context, ref, planId: plan.id),
            icon: const Icon(Icons.play_arrow_rounded),
            label: Text(l10n.startWorkout),
          ),
          const SizedBox(height: AppSpacing.xs),
          Center(
            child: TextButton(
              onPressed: () => context.go(Routes.plans),
              child: Text(l10n.chooseAnotherPlan),
            ),
          ),
        ],
      );
    } else {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.getStarted, style: AppText.overline),
          const SizedBox(height: AppSpacing.md),
          Text(l10n.makeFirstPlan, style: AppText.title),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.makeFirstPlanBody,
            style: AppText.secondary,
          ),
          const SizedBox(height: AppSpacing.xl),
          FilledButton(onPressed: () => context.go(Routes.plans), child: Text(l10n.goToPlans)),
          const SizedBox(height: AppSpacing.xs),
          Center(
            child: TextButton.icon(
              onPressed: () => startWorkout(context, ref),
              icon: const Icon(Icons.bolt_rounded),
              label: Text(l10n.quickWorkout),
            ),
          ),
        ],
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.hero),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.accentTint(),
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.25)),
          borderRadius: BorderRadius.circular(AppRadius.hero),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: KeyedSubtree(key: ValueKey(active?.id ?? plan?.id), child: content),
              ),
            ),
            // the signature gradient strip along the bottom edge
            const SizedBox(
              height: 6,
              child: DecoratedBox(decoration: BoxDecoration(gradient: AppColors.signatureGradient)),
            ),
          ],
        ),
      ),
    );
  }
}

/// "This week": one circle per day, filled on the days a workout was finished.
class _WeekCard extends ConsumerWidget {
  const _WeekCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(historyControllerProvider(HistoryRange.all)).value?.items ?? const [];
    final localizations = MaterialLocalizations.of(context);
    final firstDay = weekStartOf(context);

    final now = DateTime.now();
    final counts = sessionsPerDay(sessions, now, firstDayOfWeek: firstDay);
    final todayIndex = (now.weekday - firstDay) % 7;
    final total = counts.fold(0, (a, b) => a + b);
    final trainedDays = counts.where((c) => c > 0).length;
    final goal = ref.watch(profileControllerProvider).value?.weeklyGoal;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.cardBorder,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(l10n.thisWeek, style: AppText.heading),
              const Spacer(),
              Text(
                goal != null
                    ? total >= goal
                        ? l10n.weekGoalMet(total)
                        : l10n.weekOfGoal(total, goal)
                    : total == 0
                        ? l10n.noWorkoutsYet
                        : l10n.workoutCount(total),
                style: AppText.secondary.copyWith(
                  color: total == 0 && goal == null ? AppColors.textTertiary : AppColors.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Semantics(
            label: l10n.trainedDaysSemantics(trainedDays),
            excludeSemantics: true,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (var i = 0; i < 7; i++)
                  _DayDot(
                    // narrowWeekdays starts at Sunday
                    label: localizations.narrowWeekdays[(firstDay + i) % 7],
                    trained: counts[i] > 0,
                    today: i == todayIndex,
                    future: i > todayIndex,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DayDot extends StatelessWidget {
  const _DayDot({required this.label, required this.trained, required this.today, required this.future});

  final String label;
  final bool trained;
  final bool today;
  final bool future;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: trained ? AppColors.signatureGradient : null,
            color: trained ? null : AppColors.surface2,
            border: today && !trained ? Border.all(color: AppColors.accent, width: 1.5) : null,
          ),
          child: trained ? const Icon(Icons.check_rounded, size: 20, color: AppColors.onAccent) : null,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: AppText.caption.copyWith(
            color: today ? AppColors.accent : (future ? AppColors.textTertiary : AppColors.textSecondary),
            fontWeight: today ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

/// The most recent finished workout, tap for the details.
class _LastSession extends ConsumerWidget {
  const _LastSession();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final last = ref.watch(historyControllerProvider(HistoryRange.all)).value?.items.firstOrNull;
    if (last == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg),
      child: SessionSummaryCard(
        summary: last,
        title: l10n.lastSession,
        onTap: () => context.push(Routes.historyDetail(last.id)),
      ),
    );
  }
}

/// EN | AR beside the profile picture: one tap switches the whole app to the other language.
/// Profile still has the full choice, including following the phone.
class _LanguageToggle extends ConsumerWidget {
  const _LanguageToggle();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(languageProvider);
    final arabic = isArabic;

    Widget side(String text, bool active) => AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: active ? AppColors.accent : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Text(
            text,
            style: AppText.caption.copyWith(
              fontWeight: FontWeight.w700,
              color: active ? AppColors.onAccent : AppColors.textSecondary,
            ),
          ),
        );

    return Semantics(
      button: true,
      label: l10n.switchLanguage,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: () => ref.read(languageProvider.notifier).choose(arabic ? AppLanguage.english : AppLanguage.arabic),
        child: Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(color: AppColors.border),
          ),
          // always EN on the left, AR on the right, in both languages
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Row(mainAxisSize: MainAxisSize.min, children: [side('EN', !arabic), side('AR', arabic)]),
          ),
        ),
      ),
    );
  }
}
