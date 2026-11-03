import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text.dart';
import '../../auth/application/auth_controller.dart';

/// Home. For now: greeting + account menu.
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
                _ProfileButton(
                  initial: username.isEmpty ? '?' : username[0].toUpperCase(),
                  onPressed: () => _showAccountSheet(context, ref, username),
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

  void _showAccountSheet(BuildContext context, WidgetRef ref, String username) {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: AppSpacing.screen.copyWith(bottom: AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(username, style: AppText.heading),
              const SizedBox(height: AppSpacing.xl),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  ref.read(authControllerProvider.notifier).logout();
                },
                icon: const Icon(Icons.logout_rounded, color: AppColors.danger),
                label: const Text('Log out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileButton extends StatelessWidget {
  const _ProfileButton({required this.initial, required this.onPressed});

  final String initial;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Account',
      child: Material(
        color: AppColors.surface,
        shape: const CircleBorder(side: BorderSide(color: AppColors.border)),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox.square(
            dimension: AppSpacing.minTouch,
            child: Center(child: Text(initial, style: AppText.bodyStrong)),
          ),
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
