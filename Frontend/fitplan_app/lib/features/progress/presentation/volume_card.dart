import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text.dart';
import '../application/progress_providers.dart';
import '../domain/volume.dart';
import 'widgets/milestone_icon.dart';
import '../../../l10n/l10n.dart';

/// Progress: the lifetime volume, what it compares to, and the way to the next milestone.
/// Shows nothing while loading or when it can't load, so the rest of the screen isn't held up.
class VolumeCard extends ConsumerWidget {
  const VolumeCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final volume = ref.watch(volumeProvider).value;
    if (volume == null) return const SizedBox.shrink();

    final next = volume.next?.milestone;
    final biggest = Milestone.biggestWithin(volume.totalVolumeKg);
    final (number, unit) = volumeParts(volume.totalVolumeKg);
    final comparison =
        Milestone.compare(volume.totalVolumeKg) ??
        (volume.totalVolumeKg == 0 ? l10n.finishWithWeights : l10n.keepGoing);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Material(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.cardBorder,
          side: const BorderSide(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => showMilestonesSheet(context),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(l10n.lifetimeVolume, style: AppText.overline)),
                    const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    MilestoneIcon(art: (biggest ?? Milestone.all.first).art, reached: biggest != null),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(text: number, style: AppText.display.copyWith(fontSize: 30)),
                                TextSpan(text: ' $unit', style: AppText.secondary),
                              ],
                            ),
                          ),
                          Text(comparison, style: AppText.secondary),
                        ],
                      ),
                    ),
                  ],
                ),
                if (next != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  _Bar(value: volume.progressToNext),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(child: Text(l10n.nextMilestone(next.name), style: AppText.caption)),
                      Text(l10n.toGo(formatVolumeAmount(next.weightKg - volume.totalVolumeKg)), style: AppText.caption),
                    ],
                  ),
                ] else ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(l10n.allMilestones, style: AppText.caption),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: SizedBox(
        height: 8,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const ColoredBox(color: AppColors.surface2),
            FractionallySizedBox(
              alignment: AlignmentDirectional.centerStart,
              widthFactor: value.clamp(0, 1),
              child: const DecoratedBox(
                decoration: BoxDecoration(gradient: LinearGradient(
                  begin: AlignmentDirectional.centerStart,
                  end: AlignmentDirectional.centerEnd,
                  colors: [AppColors.accentDeep, AppColors.accent],
                )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Every milestone: the reached ones with their date, the next one with its bar, later ones dimmed.
Future<void> showMilestonesSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (context) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      builder: (context, scroll) => _MilestonesList(scroll: scroll),
    ),
  );
}

class _MilestonesList extends ConsumerWidget {
  const _MilestonesList({required this.scroll});

  final ScrollController scroll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final volume = ref.watch(volumeProvider).value;
    if (volume == null) return const Center(child: CircularProgressIndicator());
    final next = volume.next;

    return ListView(
      controller: scroll,
      padding: AppSpacing.screen.copyWith(bottom: AppSpacing.xl),
      children: [
        Text(l10n.milestones, style: AppText.title),
        const SizedBox(height: AppSpacing.xs),
        Text(l10n.liftedSoFar(formatVolumeAmount(volume.totalVolumeKg)), style: AppText.secondary),
        const SizedBox(height: AppSpacing.lg),
        for (final item in volume.milestones)
          _MilestoneRow(item: item, isNext: identical(item, next), progress: volume.progressToNext),
        const SizedBox(height: AppSpacing.lg),
        Text(
          l10n.milestonesNote,
          style: AppText.caption,
        ),
      ],
    );
  }
}

class _MilestoneRow extends StatelessWidget {
  const _MilestoneRow({required this.item, required this.isNext, required this.progress});

  final ReachedMilestone item;
  final bool isNext;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final reachedAt = item.reachedAt;
    final milestone = item.milestone;
    final locked = reachedAt == null && !isNext;

    return Opacity(
      opacity: locked ? 0.45 : 1,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            MilestoneIcon(art: milestone.art, size: 44, reached: reachedAt != null),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(milestone.title, style: AppText.bodyStrong),
                  if (reachedAt != null)
                    Text(
                      l10n.reachedOn(DateFormat.yMMMd().format(reachedAt.toLocal())),
                      style: AppText.caption.copyWith(color: AppColors.accent),
                    )
                  else if (isNext) ...[
                    const SizedBox(height: AppSpacing.sm),
                    _Bar(value: progress),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(formatVolumeAmount(milestone.weightKg), style: AppText.secondary),
            if (reachedAt != null) ...[
              const SizedBox(width: AppSpacing.xs),
              const Icon(Icons.check_rounded, size: 18, color: AppColors.accent),
            ],
          ],
        ),
      ),
    );
  }
}
