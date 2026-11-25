import 'package:fitplan_shared/fitplan_shared.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/admin_api.dart';
import 'widgets.dart';

final _dayLabel = DateFormat('MMM d');
final _number = NumberFormat.decimalPattern('en');

const _machineLabels = {
  'StationaryBike': 'stationary bike',
  'StairClimber': 'stair climber',
};

/// 12E: the first screen after sign-in. Totals only, no user names. The server keeps the figures for
/// 10 minutes so opening this page doesn't keep waking the free database.
class OverviewScreen extends StatefulWidget {
  const OverviewScreen({super.key, required this.api});

  final AdminApi api;

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  late Future<Overview> _overview = widget.api.overview();

  void _refresh() => setState(() {
        _overview = widget.api.overview(refresh: true);
      });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
      child: FutureBuilder(
        future: _overview,
        builder: (context, snapshot) {
          if (snapshot.hasError) return Panel(title: 'Overview', child: ErrorRetry(error: snapshot.error!, onRetry: _refresh));
          final o = snapshot.data;
          if (o == null) return const Padding(padding: EdgeInsets.all(48), child: Center(child: CircularProgressIndicator()));
          return _OverviewBody(overview: o, onRefresh: _refresh);
        },
      ),
    );
  }
}

class _OverviewBody extends StatelessWidget {
  const _OverviewBody({required this.overview, required this.onRefresh});

  final Overview overview;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final o = overview;
    final wide = MediaQuery.sizeOf(context).width >= 1200;
    final today = DateUtils.dateOnly(o.countedAt.toUtc());
    final minutes = DateTime.now().difference(o.countedAt).inMinutes;

    final tiles = [
      _Tile('Users', _number.format(o.users), '+${o.newUsers} in the last 7 days'),
      _Tile('Active, last 7 days', '${o.activeUsers}', o.users == 0 ? '' : '${(100 * o.activeUsers / o.users).round()}% of users'),
      _Tile('Workouts, last 7 days', '${o.workouts}', _change(o.workouts.toDouble(), o.workoutsBefore.toDouble(), 'the 7 before')),
      _Tile('Volume, last 7 days', _weight(o.volumeKg), _change(o.volumeKg, o.volumeKgBefore, 'the 7 before')),
      _Tile('Cardio this month', '${o.cardioThisMonth}',
          o.topCardio == null ? 'No entries yet' : 'Most used: ${_machineLabels[o.topCardio] ?? o.topCardio!.toLowerCase()}'),
      _Tile('Reports, last 7 days', '${o.reports}', 'Read them in Reports and errors'),
    ];

    final workoutsPanel = Panel(
      title: 'Workouts per day',
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(minutes < 1 ? 'Counted just now. ' : 'Counted $minutes min ago. ', style: AppText.caption),
        TextButton(onPressed: onRefresh, child: const Text('Refresh')),
      ]),
      child: _Bars(
        values: o.workoutsPerDay,
        labels: [for (var i = 0; i < 14; i++) '${today.subtract(Duration(days: 13 - i)).day}'],
        tooltips: [
          for (var i = 0; i < 14; i++)
            '${_dayLabel.format(today.subtract(Duration(days: 13 - i)))}: ${o.workoutsPerDay[i]} ${o.workoutsPerDay[i] == 1 ? 'workout' : 'workouts'}',
        ],
        caption: 'Last 14 days, finished workouts, UTC days',
      ),
    );

    final top = o.topExercises.isEmpty ? 1 : o.topExercises.first.workouts;
    final exercisesPanel = Panel(
      title: 'Most used exercises',
      trailing: const Text('This month, in how many workouts', style: AppText.caption),
      child: o.topExercises.isEmpty
          ? const Text('No finished workouts this month yet.', style: AppText.secondary)
          : Column(children: [
              for (final e in o.topExercises)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(children: [
                    SizedBox(width: 200, child: Text(e.name, style: AppText.body, overflow: TextOverflow.ellipsis)),
                    Expanded(
                      child: Tooltip(
                        message: '${e.name}: ${e.workouts} ${e.workouts == 1 ? 'workout' : 'workouts'}',
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: e.workouts / top,
                            child: Container(
                              height: 8,
                              decoration: BoxDecoration(
                                color: AppColors.accentMid,
                                borderRadius: const BorderRadius.horizontal(right: Radius.circular(4)),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 44, child: Text('${e.workouts}', style: AppText.secondary, textAlign: TextAlign.right)),
                  ]),
                ),
            ]),
    );

    final signUpsPanel = Panel(
      title: 'Sign-ups',
      child: _Bars(
        values: o.signUpsPerWeek,
        labels: [for (var i = 0; i < 8; i++) i == 7 ? 'This week' : '${7 - i}w ago'],
        tooltips: [
          for (var i = 0; i < 8; i++)
            'Week ending ${_dayLabel.format(today.subtract(Duration(days: 7 * (7 - i))))}: ${o.signUpsPerWeek[i]} sign-ups',
        ],
        caption: 'Last 8 weeks, 7-day blocks ending today',
        height: 110,
      ),
    );

    final attention = Panel(
      title: 'Needs attention',
      child: Column(children: [
        _AttentionRow(
          o.reports == 0 ? 'No reports in the last 7 days' : '${o.reports} ${o.reports == 1 ? 'report' : 'reports'} in the last 7 days',
          o.reports == 0 ? null : const Pill('Read', color: AppColors.danger),
        ),
        _AttentionRow(
          o.noDemo == 0 ? 'No exercises with a broken demo link' : '${o.noDemo} exercises have no working demo GIF',
          o.noDemo == 0 ? null : const Pill('Known', color: AppColors.textTertiary),
        ),
      ]),
    );

    final emailShare = o.emailLimit == 0 ? 0.0 : (o.emailsToday / o.emailLimit).clamp(0.0, 1.0);
    final usage = Panel(
      title: 'Free plan usage',
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          const Expanded(child: Text('Emails today', style: AppText.secondary)),
          Text('${o.emailsToday} / ${o.emailLimit}', style: AppText.bodyStrong),
        ]),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: emailShare,
            minHeight: 8,
            backgroundColor: AppColors.surface2,
            color: emailShare >= 0.8 ? AppColors.danger : AppColors.accentMid,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        const Text(
          "Database awake time and the API's CPU minutes are on the Azure portal, under the database and the App Service.",
          style: AppText.caption,
        ),
      ]),
    );

    Widget pair(Widget a, Widget b, {int flexA = 1, int flexB = 1}) => wide
        ? IntrinsicHeight(
            child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Expanded(flex: flexA, child: a),
              const SizedBox(width: AppSpacing.lg),
              Expanded(flex: flexB, child: b),
            ]),
          )
        : Column(children: [a, const SizedBox(height: AppSpacing.lg), b]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(builder: (context, box) {
          final perRow = box.maxWidth >= 1100 ? 6 : (box.maxWidth >= 640 ? 3 : 2);
          final width = (box.maxWidth - AppSpacing.md * (perRow - 1)) / perRow;
          return Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [for (final t in tiles) SizedBox(width: width, child: t)],
          );
        }),
        const SizedBox(height: AppSpacing.lg),
        pair(workoutsPanel, exercisesPanel),
        const SizedBox(height: AppSpacing.lg),
        pair(signUpsPanel, Column(children: [attention, const SizedBox(height: AppSpacing.lg), usage]), flexA: 3, flexB: 2),
      ],
    );
  }
}

String _weight(double kg) => kg >= 1000 ? '${(kg / 1000).toStringAsFixed(kg >= 10000 ? 0 : 1)} t' : '${kg.round()} kg';

String _change(double now, double before, String than) {
  if (before == 0) return now == 0 ? 'None in $than either' : 'None in $than';
  final percent = ((now - before) / before * 100).round();
  return percent == 0 ? 'Same as $than' : '${percent > 0 ? '+' : ''}$percent% on $than';
}

class _Tile extends StatelessWidget {
  const _Tile(this.label, this.value, this.detail);

  final String label;
  final String value;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: AppText.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 6),
        Text(value, style: AppText.heading),
        const SizedBox(height: 2),
        Text(detail, style: AppText.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
      ]),
    );
  }
}

/// One series of bars on a zero baseline. The last bar (today, this week) is brighter.
class _Bars extends StatelessWidget {
  const _Bars({required this.values, required this.labels, required this.tooltips, required this.caption, this.height = 150});

  final List<int> values;
  final List<String> labels;
  final List<String> tooltips;
  final String caption;
  final double height;

  @override
  Widget build(BuildContext context) {
    final most = values.fold(0, (a, b) => a > b ? a : b);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      SizedBox(
        height: height,
        child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          for (var i = 0; i < values.length; i++)
            Expanded(
              child: Tooltip(
                message: tooltips[i],
                // the whole column is the hover target, not just the bar
                child: Container(
                  color: Colors.transparent,
                  alignment: Alignment.bottomCenter,
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Container(
                    height: most == 0 || values[i] == 0 ? 2 : height * values[i] / most,
                    decoration: BoxDecoration(
                      color: values[i] == 0 ? AppColors.border : (i == values.length - 1 ? AppColors.accent : AppColors.accentMid),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                    ),
                  ),
                ),
              ),
            ),
        ]),
      ),
      const Divider(height: 1, color: AppColors.border),
      const SizedBox(height: 4),
      Row(children: [
        for (final l in labels) Expanded(child: Text(l, style: AppText.caption, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.clip)),
      ]),
      const SizedBox(height: AppSpacing.sm),
      Text('$caption. Most in one: $most.', style: AppText.caption),
    ]);
  }
}

class _AttentionRow extends StatelessWidget {
  const _AttentionRow(this.text, this.pill);

  final String text;
  final Widget? pill;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [Expanded(child: Text(text, style: AppText.body)), ?pill]),
    );
  }
}
