import 'package:fitplan_shared/fitplan_shared.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/admin_api.dart';

/// 12A: who the admins are, and the audit log of every admin action.
class AdminsScreen extends StatefulWidget {
  const AdminsScreen({super.key, required this.api});

  final AdminApi api;

  @override
  State<AdminsScreen> createState() => _AdminsScreenState();
}

class _AdminsScreenState extends State<AdminsScreen> {
  late Future<AuditPage> _audit = widget.api.audit();

  void _open(int page) => setState(() => _audit = widget.api.audit(page: page));

  @override
  Widget build(BuildContext context) {
    final me = widget.api.session.value;
    final wide = MediaQuery.sizeOf(context).width >= 1100;
    final admins = _Panel(
      title: 'Admins',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (me != null)
            Row(
              children: [
                Expanded(child: Text('${me.username} (you)', style: AppText.body)),
                _Pill(me.role),
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
    final audit = _Panel(
      title: 'Audit log',
      trailing: const Text('Every admin action, newest first', style: AppText.caption),
      child: FutureBuilder(
        future: _audit,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${snapshot.error}', style: AppText.secondary.copyWith(color: AppColors.danger)),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton(onPressed: () => _open(1), child: const Text('Try again')),
              ],
            );
          }
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

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.child, this.trailing});

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

class _Pill extends StatelessWidget {
  const _Pill(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
      decoration: BoxDecoration(color: AppColors.accentTint(0.12), borderRadius: BorderRadius.circular(AppRadius.pill)),
      child: Text(text, style: AppText.caption.copyWith(color: AppColors.accent, fontWeight: FontWeight.w500)),
    );
  }
}
