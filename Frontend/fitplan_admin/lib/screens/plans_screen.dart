import 'dart:async';

import 'package:fitplan_shared/fitplan_shared.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/admin_api.dart';
import 'widgets.dart';

final _day = DateFormat('MMM d');

const _machineLabels = {
  'Treadmill': 'Treadmill',
  'StationaryBike': 'Stationary bike',
  'Elliptical': 'Elliptical',
  'StairClimber': 'Stair climber',
  'Rower': 'Rower',
  'Swimming': 'Swimming',
  'Other': 'Other (retired)',
};

const _fieldLabels = {
  'speedKmh': 'speed',
  'inclinePercent': 'incline',
  'distanceKm': 'distance',
  'distanceMeters': 'distance (m)',
  'level': 'level',
  'floors': 'floors',
  'cadenceRpm': 'cadence',
  'strokeRate': 'stroke rate',
  'poolLengthMeters': 'pool length',
  'laps': 'laps',
};

/// 12D: a user's plans, read only and logged, and the cardio machines with their use this month.
/// [userId] opens that user's plans straight away (from the Users screen).
class PlansScreen extends StatefulWidget {
  const PlansScreen({super.key, required this.api, this.userId});

  final AdminApi api;
  final String? userId;

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  final _search = TextEditingController();
  Timer? _debounce;
  Future<UserPage>? _matches;
  Future<({String username, List<UserPlan> plans})>? _plans;
  String? _viewing;
  late Future<List<CardioMachineRow>> _cardio = widget.api.cardioMachines();

  @override
  void initState() {
    super.initState();
    if (widget.userId != null) _open(widget.userId!);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _open(String userId) {
    _viewing = userId;
    _plans = widget.api.viewPlans(userId);
  }

  void _find() {
    final text = _search.text.trim();
    setState(() {
      _matches = text.isEmpty ? null : widget.api.users(search: text);
    });
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 1200;
    final left = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Panel(
          title: "A user's plans",
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _search,
                decoration: const InputDecoration(hintText: 'Search by username', prefixIcon: Icon(Icons.search), isDense: true),
                onChanged: (_) {
                  _debounce?.cancel();
                  _debounce = Timer(const Duration(milliseconds: 400), _find);
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text('Opening plans is written to the audit log with your name and the time.', style: AppText.caption),
              if (_matches != null) ...[const SizedBox(height: AppSpacing.md), _matchList()],
            ],
          ),
        ),
        if (_plans != null) ...[const SizedBox(height: AppSpacing.lg), _planView()],
      ],
    );
    final cardio = _cardioPanel();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
      child: wide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Expanded(flex: 3, child: left), const SizedBox(width: AppSpacing.lg), Expanded(flex: 2, child: cardio)],
            )
          : Column(children: [left, const SizedBox(height: AppSpacing.lg), cardio]),
    );
  }

  Widget _matchList() => FutureBuilder(
        future: _matches,
        builder: (context, snapshot) {
          if (snapshot.hasError) return ErrorRetry(error: snapshot.error!, onRetry: _find);
          final page = snapshot.data;
          if (page == null) return const LinearProgressIndicator();
          if (page.items.isEmpty) return const Text('No users match.', style: AppText.secondary);
          return Column(
            children: [
              for (final user in page.items.take(8))
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(user.username, style: AppText.body),
                  trailing: OutlinedButton(
                    onPressed: () => setState(() => _open(user.id)),
                    child: const Text('View plans'),
                  ),
                ),
            ],
          );
        },
      );

  Widget _planView() => FutureBuilder(
        future: _plans,
        builder: (context, snapshot) {
          if (snapshot.hasError) return Panel(title: 'Plans', child: ErrorRetry(error: snapshot.error!, onRetry: () => setState(() => _open(_viewing!))));
          final shown = snapshot.data;
          if (shown == null) return const Center(child: CircularProgressIndicator());
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text.rich(TextSpan(children: [
                  const TextSpan(text: 'This view is logged. ', style: TextStyle(fontWeight: FontWeight.w600)),
                  TextSpan(text: "You're looking at ${shown.username}'s plans. Opening them was saved to the audit log."),
                ]), style: AppText.secondary),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (shown.plans.isEmpty)
                Panel(title: shown.username, child: const Text('This user has no plans.', style: AppText.secondary)),
              for (final plan in shown.plans) ...[
                Panel(
                  title: plan.name,
                  trailing: Text('Read only. Created ${_day.format(plan.createdAt)}', style: AppText.caption),
                  child: plan.exercises.isEmpty
                      ? const Text('No exercises yet.', style: AppText.secondary)
                      : Table(
                          columnWidths: const {0: FlexColumnWidth(3), 1: FlexColumnWidth(), 2: FlexColumnWidth(), 3: FlexColumnWidth()},
                          children: [
                            _row(const ['Exercise', 'Sets', 'Reps', 'Rest'], header: true),
                            for (final e in plan.exercises) _row([e.name, '${e.sets}', '${e.reps}', _rest(e.restSeconds)]),
                          ],
                        ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            ],
          );
        },
      );

  Widget _cardioPanel() => Panel(
        title: 'Cardio machines',
        trailing: const Text('Entries this month', style: AppText.caption),
        child: FutureBuilder(
          future: _cardio,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return ErrorRetry(error: snapshot.error!, onRetry: () => setState(() => _cardio = widget.api.cardioMachines()));
            }
            final machines = snapshot.data;
            if (machines == null) return const LinearProgressIndicator();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Table(
                  columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(3), 2: FlexColumnWidth()},
                  children: [
                    _row(const ['Machine', 'Fields', 'Uses'], header: true),
                    for (final m in machines)
                      _row([
                        _machineLabels[m.machine] ?? m.machine,
                        _sentence([for (final f in m.fields) _fieldLabels[f] ?? f]),
                        '${m.usesThisMonth}',
                      ]),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                const Text('The machines and their fields are set in the code, so old entries stay valid.', style: AppText.caption),
              ],
            );
          },
        ),
      );
}

TableRow _row(List<String> cells, {bool header = false}) => TableRow(
      children: [
        for (final cell in cells)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text(cell, style: header ? AppText.caption : AppText.body),
          ),
      ],
    );

String _rest(int? seconds) {
  final s = seconds ?? 90; // the app's default rest
  return '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
}

String _sentence(List<String> words) {
  if (words.isEmpty) return '';
  final text = words.join(', ');
  return text[0].toUpperCase() + text.substring(1);
}
