import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/slow_requests.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text.dart';

/// A small banner over every screen while a request takes longer than usual,
/// so a sleeping server looks like a wait, not a frozen app.
class WakingServerBanner extends ConsumerWidget {
  const WakingServerBanner({super.key, required this.child});

  final Widget child;

  static const text = 'Waking the server, this can take up to a minute…';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final waiting = ref.watch(slowRequestsProvider) > 0;

    return Stack(
      children: [
        child,
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          child: SafeArea(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: waiting ? const _Banner() : const SizedBox.shrink(),
            ),
          ),
        ),
      ],
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Semantics(
        liveRegion: true,
        child: Material(
          color: AppColors.surface2,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
            child: Row(
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: Text(WakingServerBanner.text, style: AppText.secondary)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
