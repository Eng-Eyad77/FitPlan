import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text.dart';
import '../../../shared/format.dart';
import '../../../shared/widgets/feedback.dart';
import '../../session/domain/workout_session.dart';
import '../application/history_controller.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.extentAfter < 500) {
        ref.read(historyControllerProvider.notifier).loadMore().catchError((Object error) {
          if (mounted) showError(context, error);
        });
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(historyControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: history.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => LoadError(
            message: errorMessage(error, 'Could not load your history.'),
            onRetry: () => ref.invalidate(historyControllerProvider),
          ),
          data: (state) => RefreshIndicator(
            onRefresh: () => ref.refresh(historyControllerProvider.future),
            child: ListView(
              controller: _scroll,
              // so pull-to-refresh works even when the list is short
              physics: const AlwaysScrollableScrollPhysics(),
              padding: AppSpacing.screen.copyWith(top: 28, bottom: 24),
              children: [
                const Text('History', style: AppText.title),
                const SizedBox(height: AppSpacing.xs),
                const Text('Every workout you finished.', style: AppText.secondary),
                const SizedBox(height: AppSpacing.xl),
                if (state.items.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 64),
                    child: EmptyState(
                      icon: Icons.history_rounded,
                      title: 'No workouts yet',
                      message: 'Finish your first workout and it will show up here.',
                    ),
                  )
                else
                  ..._groupedByMonth(state.items),
                if (state.hasMore)
                  const Padding(
                    padding: EdgeInsets.all(AppSpacing.lg),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _groupedByMonth(List<SessionSummary> items) {
    final monthFormat = DateFormat('MMMM y');
    final widgets = <Widget>[];
    String? currentMonth;

    for (final session in items) {
      final month = monthFormat.format(session.completedAt.toLocal());
      if (month != currentMonth) {
        widgets.add(Padding(
          padding: EdgeInsets.only(top: currentMonth == null ? 0 : AppSpacing.lg, bottom: AppSpacing.md),
          child: Text(month.toUpperCase(), style: AppText.overline),
        ));
        currentMonth = month;
      }
      widgets
        ..add(SessionSummaryCard(
          summary: session,
          onTap: () => context.push(Routes.historyDetail(session.id)),
        ))
        ..add(const SizedBox(height: AppSpacing.md));
    }
    return widgets;
  }
}

/// A finished workout in short: name, day, and the main numbers. Used by History and Home.
class SessionSummaryCard extends StatelessWidget {
  const SessionSummaryCard({super.key, required this.summary, required this.onTap, this.title});

  final SessionSummary summary;
  final VoidCallback onTap;

  /// Replaces the date line (Home shows "Last session").
  final String? title;

  @override
  Widget build(BuildContext context) {
    final local = summary.completedAt.toLocal();
    final date = '${DateFormat('EEE, d MMM').format(local)} · ${DateFormat.jm().format(local)}';

    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.cardBorder,
        side: const BorderSide(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (title != null) ...[
                          Text(title!.toUpperCase(), style: AppText.overline),
                          const SizedBox(height: AppSpacing.xs),
                        ],
                        Text(summary.name, style: AppText.heading, maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text(
                          title == null ? date : '${formatDaysAgo(summary.completedAt)} · $date',
                          style: AppText.caption,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  _Figure(value: formatDuration(summary.durationSeconds), label: 'Time'),
                  _Figure(value: formatVolume(summary.totalVolumeKg), label: 'Volume'),
                  _Figure(value: '${summary.setCount}', label: 'Sets'),
                  // always 4 columns, so the numbers line up from card to card
                  if (summary.estimatedCalories > 0)
                    _Figure(value: '≈ ${summary.estimatedCalories}', label: 'kcal')
                  else if (summary.cardioDurationSeconds > 0)
                    _Figure(value: formatDuration(summary.cardioDurationSeconds), label: 'Cardio')
                  else
                    const Spacer(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Figure extends StatelessWidget {
  const _Figure({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: AppText.bodyStrong.copyWith(fontSize: 16, fontFeatures: const [FontFeature.tabularFigures()])),
          ),
          Text(label, style: AppText.caption),
        ],
      ),
    );
  }
}
