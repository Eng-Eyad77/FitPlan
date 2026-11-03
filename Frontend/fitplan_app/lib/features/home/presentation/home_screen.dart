import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text.dart';
import '../../auth/application/auth_controller.dart';
import '../../plans/application/plans_controller.dart';
import '../../profile/application/profile_controller.dart';
import '../../profile/presentation/widgets/profile_avatar.dart';
import '../../session/application/active_session_controller.dart';
import '../../session/presentation/start_workout.dart';
import '../../session/presentation/widgets/elapsed_clock.dart';

/// Home: greeting, profile shortcut and the "Up next" card.
/// The week strip and last session come with the history step.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static String _greeting(DateTime now) => switch (now.hour) {
        < 12 => 'Good morning',
        < 18 => 'Good afternoon',
        _ => 'Good evening',
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
                      Text('${_greeting(DateTime.now())}, $username', style: AppText.secondary),
                      const SizedBox(height: AppSpacing.xs),
                      const Text('Ready to train?', style: AppText.title),
                    ],
                  ),
                ),
                Tooltip(
                  message: 'Profile',
                  child: Semantics(
                    button: true,
                    label: 'Open profile',
                    child: GestureDetector(
                      onTap: () => context.push(Routes.profile),
                      child: ProfileAvatar(
                        initial: username.isEmpty ? '?' : username[0].toUpperCase(),
                        imageUrl: profile?.pictureFullUrl,
                        size: AppSpacing.minTouch,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),
            const _UpNextCard(),
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
              const Text('IN PROGRESS', style: AppText.overline),
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
          Text('$sets ${sets == 1 ? 'set' : 'sets'} logged so far', style: AppText.secondary),
          const SizedBox(height: AppSpacing.xl),
          FilledButton.icon(
            onPressed: () => context.push(Routes.session),
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Resume workout'),
          ),
        ],
      );
    } else if (plan != null) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('UP NEXT', style: AppText.overline),
          const SizedBox(height: AppSpacing.md),
          Text(plan.name, style: AppText.title),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${plan.exerciseCount} ${plan.exerciseCount == 1 ? 'exercise' : 'exercises'}'
            '${plan.description == null ? '' : ' · ${plan.description}'}',
            style: AppText.secondary,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xl),
          FilledButton.icon(
            onPressed: () => startWorkout(context, ref, planId: plan.id),
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Start workout'),
          ),
          const SizedBox(height: AppSpacing.xs),
          Center(
            child: TextButton(
              onPressed: () => context.go(Routes.plans),
              child: const Text('Choose another plan'),
            ),
          ),
        ],
      );
    } else {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('GET STARTED', style: AppText.overline),
          const SizedBox(height: AppSpacing.md),
          const Text('Make your first plan', style: AppText.title),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Pick your exercises once, then start it with one tap every time you train.',
            style: AppText.secondary,
          ),
          const SizedBox(height: AppSpacing.xl),
          FilledButton(onPressed: () => context.go(Routes.plans), child: const Text('Go to plans')),
          const SizedBox(height: AppSpacing.xs),
          Center(
            child: TextButton.icon(
              onPressed: () => startWorkout(context, ref),
              icon: const Icon(Icons.bolt_rounded),
              label: const Text('Quick workout'),
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
