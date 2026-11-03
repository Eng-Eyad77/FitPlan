import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text.dart';
import '../../auth/application/auth_controller.dart';
import '../../profile/application/profile_controller.dart';
import '../../profile/presentation/widgets/profile_avatar.dart';

/// Home. For now: greeting + profile shortcut.
/// The "Up next" card, week strip and last session come with the sessions step.
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
            const _NextStepCard(),
          ].animate(interval: 50.ms).fadeIn(duration: 280.ms).slideY(begin: 0.06, end: 0),
        ),
      ),
    );
  }
}

/// Temporary card until plans and sessions are connected.
class _NextStepCard extends StatelessWidget {
  const _NextStepCard();

  @override
  Widget build(BuildContext context) {
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('UP NEXT', style: AppText.overline),
                  const SizedBox(height: AppSpacing.md),
                  Text('You are all set', style: AppText.title.copyWith(color: AppColors.accent)),
                  const SizedBox(height: AppSpacing.sm),
                  const Text(
                    'Your plans and workout sessions will show up here in the next step.',
                    style: AppText.secondary,
                  ),
                ],
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
