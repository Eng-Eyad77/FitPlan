import 'package:fitplan_shared/fitplan_shared.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/admin_api.dart';
import 'widgets.dart';

/// 12A: who the admins are, and the audit log of every admin action.
class AdminsScreen extends StatefulWidget {
  const AdminsScreen({super.key, required this.api});

  final AdminApi api;

  @override
  State<AdminsScreen> createState() => _AdminsScreenState();
}

class _AdminsScreenState extends State<AdminsScreen> {
  late Future<AuditPage> _audit = widget.api.audit();

  void _open(int page) => setState(() { _audit = widget.api.audit(page: page); });

  @override
  Widget build(BuildContext context) {
    final me = widget.api.session.value;
    final wide = MediaQuery.sizeOf(context).width >= 1100;
    final admins = Panel(
      title: 'Admins',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (me != null)
            Row(
              children: [
                Expanded(child: Text('${me.username} (you)', style: AppText.body)),
                Pill(me.role),
              ],
            ),
          const SizedBox(height: AppSpacing.lg),
          const Text(
            "You're the only admin, so only the Owner role exists for now. Admins are added with "
            'make-owner, never from a sign-up.',
            style: AppText.caption,
          ),
        ],
      ),
    );
    final audit = Panel(
      title: 'Audit log',
      trailing: const Text('Every admin action, newest first', style: AppText.caption),
      child: FutureBuilder(
        future: _audit,
        builder: (context, snapshot) {
          if (snapshot.hasError) return ErrorRetry(error: snapshot.error!, onRetry: () => _open(1));
          final page = snapshot.data;
          if (page == null) {
            return const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator()));
          }
          if (page.items.isEmpty) return const Text('No admin actions yet.', style: AppText.secondary);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Table(
                columnWidths: const {0: FixedColumnWidth(150), 1: FixedColumnWidth(130), 2: FlexColumnWidth()},
                children: [
                  _row(['When', 'Who', 'Action'], header: true),
                  for (final e in page.items)
                    _row([
                      DateFormat('MMM d, HH:mm').format(e.createdAt),
                      e.adminName,
                      e.target == null ? e.action : '${e.action}: ${e.target}',
                    ]),
                ],
              ),
              if (page.totalPages > 1)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: page.page > 1 ? () => _open(page.page - 1) : null, child: const Text('Newer')),
                    Text('Page ${page.page} of ${page.totalPages}', style: AppText.caption),
                    TextButton(
                        onPressed: page.page < page.totalPages ? () => _open(page.page + 1) : null, child: const Text('Older')),
                  ],
                ),
            ],
          );
        },
      ),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
      child: wide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Expanded(child: admins), const SizedBox(width: AppSpacing.lg), Expanded(flex: 2, child: audit)],
            )
          : Column(children: [admins, const SizedBox(height: AppSpacing.lg), audit]),
    );
  }

  TableRow _row(List<String> cells, {bool header = false}) => TableRow(
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
        children: [
          for (final cell in cells)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Text(cell, style: header ? AppText.caption : AppText.secondary.copyWith(color: AppColors.textPrimary)),
            ),
        ],
      );
}
