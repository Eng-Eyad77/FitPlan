import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../shared/format.dart';
import '../../application/rest_timer.dart';

/// The rest countdown pinned at the bottom of the session screen.
/// Hidden when no rest is running.
class RestTimerBar extends ConsumerWidget {
  const RestTimerBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timer = ref.watch(restTimerProvider);

    return AnimatedSize(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      alignment: Alignment.bottomCenter,
      child: timer == null ? const SizedBox(width: double.infinity) : _Countdown(timer: timer),
    );
  }
}

class _Countdown extends ConsumerStatefulWidget {
  const _Countdown({required this.timer});

  final RestTimer timer;

  @override
  ConsumerState<_Countdown> createState() => _CountdownState();
}

class _CountdownState extends ConsumerState<_Countdown> {
  late final Timer _ticker;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(milliseconds: 200), (_) => _tick());
  }

  @override
  void didUpdateWidget(_Countdown old) {
    super.didUpdateWidget(old);
    // +15s after it ended starts counting again
    if (widget.timer.secondsLeft(DateTime.now()) > 0) _finished = false;
  }

  @override
  void dispose() {
    _ticker.cancel();
    super.dispose();
  }

  void _tick() {
    if (!mounted) return;
    final left = widget.timer.secondsLeft(DateTime.now());
    if (left == 0 && !_finished) {
      _finished = true;
      HapticFeedback.heavyImpact();
      // keep "Go!" on screen for a moment, then hide the bar
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted && _finished) ref.read(restTimerProvider.notifier).skip();
      });
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final left = widget.timer.secondsLeft(now);
    final controller = ref.read(restTimerProvider.notifier);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // the gradient line shrinks as the rest runs out
            Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: widget.timer.progress(now),
                child: const SizedBox(
                  height: 3,
                  child: DecoratedBox(decoration: BoxDecoration(gradient: AppColors.signatureGradient)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.md, AppSpacing.md, AppSpacing.md),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(left == 0 ? 'REST DONE' : 'REST', style: AppText.overline),
                      Semantics(
                        liveRegion: left == 0,
                        child: Text(
                          left == 0 ? 'Go!' : formatClock(left),
                          style: AppText.number.copyWith(fontSize: 28),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  OutlinedButton(
                    onPressed: () => controller.addTime(const Duration(seconds: 15)),
                    style: OutlinedButton.styleFrom(minimumSize: const Size(72, 48)),
                    child: const Text('+15s'),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  TextButton(
                    onPressed: controller.skip,
                    style: TextButton.styleFrom(minimumSize: const Size(64, 48)),
                    child: Text(left == 0 ? 'Close' : 'Skip'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
