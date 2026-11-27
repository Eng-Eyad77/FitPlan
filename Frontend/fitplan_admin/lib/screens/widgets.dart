import 'package:fitplan_shared/fitplan_shared.dart';
import 'package:flutter/material.dart';

/// A card section of an admin screen.
class Panel extends StatelessWidget {
  const Panel({super.key, required this.title, required this.child, this.trailing});

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Expanded(child: Text(title, style: AppText.bodyStrong)), ?trailing]),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}

/// A small status label. [color] defaults to the accent.
class Pill extends StatelessWidget {
  const Pill(this.text, {super.key, this.color = AppColors.accent});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.13), borderRadius: BorderRadius.circular(AppRadius.pill)),
      child: Text(text, style: AppText.caption.copyWith(color: color, fontWeight: FontWeight.w500)),
    );
  }
}

/// An error line with a way to try again.
class ErrorRetry extends StatelessWidget {
  const ErrorRetry({super.key, required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$error', style: AppText.secondary.copyWith(color: AppColors.danger)),
        const SizedBox(height: AppSpacing.sm),
        OutlinedButton(onPressed: onRetry, child: const Text('Try again')),
      ],
    );
  }
}
