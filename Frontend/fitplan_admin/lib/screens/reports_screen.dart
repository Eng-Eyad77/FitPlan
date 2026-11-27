import 'package:fitplan_shared/fitplan_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../core/admin_api.dart';
import '../core/browser/download.dart';
import '../core/env.dart';
import 'widgets.dart';

final _time = DateFormat('MMM d, HH:mm');

/// 12F: reports from the app (the ones also sent to Telegram), and what went wrong on the server
/// in the last 24 hours.
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key, required this.api});

  final AdminApi api;

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _filter = 'open';
  int _page = 1;
  late Future<ReportPage> _reports = _load();
  late Future<({List<ApiError> apiErrors, List<FailedSignIn> failedSignIns})> _errors = widget.api.errors();
  bool _busy = false;

  Future<ReportPage> _load() => widget.api.reports(filter: _filter, page: _page);

  void _reload() => setState(() {
        _reports = _load();
      });

  void _say(String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  Future<void> _run(String done, Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
      if (mounted) _say(done);
    } on AdminApiException catch (e) {
      if (mounted) _say(e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 1200;
    final reports = _reportsPanel();
    final side = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [_errorsPanel(), const SizedBox(height: AppSpacing.lg), _signInsPanel()],
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
      child: wide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Expanded(flex: 3, child: reports), const SizedBox(width: AppSpacing.lg), Expanded(flex: 2, child: side)],
            )
          : Column(children: [reports, const SizedBox(height: AppSpacing.lg), side]),
    );
  }

  Widget _reportsPanel() => Panel(
        title: 'User reports',
        trailing: OutlinedButton(
          onPressed: _busy
              ? null
              : () => _run('Saved the reports as a CSV file.', () async {
                    final bytes = await widget.api.exportReports();
                    saveFile('fitplan-reports-${DateFormat('yyyy-MM-dd').format(DateTime.now())}.csv', bytes, 'text/csv');
                  }),
          child: const Text('Export CSV'),
        ),
        child: FutureBuilder(
          future: _reports,
          builder: (context, snapshot) {
            if (snapshot.hasError) return ErrorRetry(error: snapshot.error!, onRetry: _reload);
            final page = snapshot.data;
            if (page == null) return const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator()));
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Also sent to you on Telegram. The CSV has no emails.', style: AppText.caption),
                const SizedBox(height: AppSpacing.md),
                Wrap(spacing: AppSpacing.sm, children: [
                  for (final (value, label, count) in [
                    ('open', 'Open', page.open),
                    ('suggestions', 'Suggestions', page.suggestions),
                    ('done', 'Done', page.done),
                  ])
                    ChoiceChip(
                      label: Text('$label $count'),
                      selected: _filter == value,
                      onSelected: (_) {
                        _filter = value;
                        _page = 1;
                        _reload();
                      },
                    ),
                ]),
                const SizedBox(height: AppSpacing.md),
                if (page.items.isEmpty)
                  Text(
                    switch (_filter) {
                      'done' => 'Nothing marked done yet.',
                      'suggestions' => 'No suggestions waiting.',
                      _ => 'No open reports.',
                    },
                    style: AppText.secondary,
                  ),
                for (final r in page.items) _ReportCard(report: r, busy: _busy, onToggle: () => _toggle(r)),
                if (page.totalPages > 1)
                  Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    TextButton(onPressed: page.page > 1 ? () { _page--; _reload(); } : null, child: const Text('Previous')),
                    Text('Page ${page.page} of ${page.totalPages}', style: AppText.caption),
                    TextButton(onPressed: page.page < page.totalPages ? () { _page++; _reload(); } : null, child: const Text('Next')),
                  ]),
              ],
            );
          },
        ),
      );

  Future<void> _toggle(Report r) async {
    final done = r.doneAt == null;
    await _run(done ? 'Marked #${r.id} done.' : 'Reopened #${r.id}.', () => widget.api.setReportDone(r.id, done));
    _reload();
  }

  Widget _errorsPanel() => Panel(
        title: 'API errors',
        trailing: Env.name == 'Production'
            ? null
            : TextButton(
                onPressed: _busy
                    ? null
                    : () async {
                        setState(() => _busy = true);
                        try {
                          final id = await widget.api.throwTestError();
                          if (mounted) _say('Test error made${id == null ? '' : ' with request ID $id'}.');
                        } on AdminApiException catch (e) {
                          if (mounted) _say(e.message);
                        } finally {
                          if (mounted) {
                            setState(() {
                              _busy = false;
                              _errors = widget.api.errors();
                            });
                          }
                        }
                      },
                child: const Text('Make a test error'),
              ),
        child: FutureBuilder(
          future: _errors,
          builder: (context, snapshot) {
            if (snapshot.hasError) return ErrorRetry(error: snapshot.error!, onRetry: () => setState(() => _errors = widget.api.errors()));
            final errors = snapshot.data?.apiErrors;
            if (errors == null) return const LinearProgressIndicator();
            if (errors.isEmpty) return const Text('No errors in the last 24 hours.', style: AppText.secondary);
            return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const Text('Last 24 hours. Copy a request ID to find the error in the Azure logs.', style: AppText.caption),
              const SizedBox(height: AppSpacing.sm),
              for (final e in errors)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Expanded(child: Text(e.endpoint, style: AppText.body)),
                      Text(_time.format(e.createdAt), style: AppText.caption),
                    ]),
                    Row(children: [
                      Text(e.error, style: AppText.caption.copyWith(color: AppColors.danger)),
                      const SizedBox(width: AppSpacing.sm),
                      if (e.requestId != null)
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: e.requestId!));
                              _say('Copied the request ID.');
                            },
                            child: Text(e.requestId!, style: AppText.caption, overflow: TextOverflow.ellipsis),
                          ),
                        ),
                    ]),
                  ]),
                ),
            ]);
          },
        ),
      );

  Widget _signInsPanel() => Panel(
        title: 'Failed sign-ins',
        child: FutureBuilder(
          future: _errors,
          builder: (context, snapshot) {
            final signIns = snapshot.data?.failedSignIns;
            if (snapshot.hasError) return const Text("Couldn't load them.", style: AppText.secondary);
            if (signIns == null) return const LinearProgressIndicator();
            if (signIns.isEmpty) return const Text('None in the last 24 hours.', style: AppText.secondary);
            return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const Text('Last 24 hours. What was typed is never kept.', style: AppText.caption),
              const SizedBox(height: AppSpacing.sm),
              for (final s in signIns)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(children: [
                    Expanded(child: Text(s.account, style: AppText.body)),
                    Text('${s.attempts} ${s.attempts == 1 ? 'try' : 'tries'}', style: AppText.secondary),
                    const SizedBox(width: AppSpacing.sm),
                    Flexible(child: Pill(s.reason, color: AppColors.textTertiary)),
                  ]),
                ),
            ]);
          },
        ),
      );
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.report, required this.busy, required this.onToggle});

  final Report report;
  final bool busy;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final r = report;
    final arabic = r.language.startsWith('ar');
    final platform = switch (r.platform) { 'ios' => 'iOS', 'android' => 'Android', final other => other };
    final where = [?platform, ?r.appVersion, arabic ? 'Arabic' : 'English'].join(', ');
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(color: AppColors.surface2, borderRadius: BorderRadius.circular(AppRadius.sm)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Wrap(spacing: AppSpacing.md, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center, children: [
          Text('#${r.id}', style: AppText.bodyStrong),
          Text(r.username, style: AppText.secondary),
          Text(where, style: AppText.caption),
          Text(_time.format(r.createdAt), style: AppText.caption),
          if (!r.sentToTelegram) const Pill('Telegram failed', color: AppColors.danger),
          if (r.doneAt != null) Pill('Done ${_time.format(r.doneAt!)}'),
        ]),
        const SizedBox(height: AppSpacing.sm),
        Text(r.message, style: AppText.body, textDirection: arabic ? TextDirection.rtl : TextDirection.ltr),
        const SizedBox(height: AppSpacing.sm),
        Align(
          alignment: Alignment.centerRight,
          child: OutlinedButton(onPressed: busy ? null : onToggle, child: Text(r.doneAt == null ? 'Mark done' : 'Reopen')),
        ),
      ]),
    );
  }
}
