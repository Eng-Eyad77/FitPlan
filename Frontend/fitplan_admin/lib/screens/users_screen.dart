import 'dart:async';

import 'package:fitplan_shared/fitplan_shared.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../core/admin_api.dart';
import 'widgets.dart';

final _day = DateFormat('MMM d, y');

/// 12B: find a user, see their account, and act on it. Every action is logged by the server.
class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key, required this.api});

  final AdminApi api;

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final _search = TextEditingController();
  Timer? _debounce;
  String _status = 'all';
  int _page = 1;
  late Future<UserPage> _list = _load();
  String? _selected;

  Future<UserPage> _load() => widget.api.users(search: _search.text.trim(), status: _status, page: _page);

  void _reload({bool firstPage = false}) => setState(() {
        if (firstPage) _page = 1;
        _list = _load();
      });

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 1200;
    final list = Panel(
      title: 'Users',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _search,
            decoration: const InputDecoration(hintText: 'Search by username or email', prefixIcon: Icon(Icons.search), isDense: true),
            onChanged: (_) {
              _debounce?.cancel();
              _debounce = Timer(const Duration(milliseconds: 400), () => _reload(firstPage: true));
            },
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              for (final (value, label) in const [('all', 'All'), ('active', 'Active'), ('disabled', 'Disabled')])
                ChoiceChip(
                  label: Text(label),
                  selected: _status == value,
                  onSelected: (_) {
                    _status = value;
                    _reload(firstPage: true);
                  },
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          FutureBuilder(
            future: _list,
            builder: (context, snapshot) {
              if (snapshot.hasError) return ErrorRetry(error: snapshot.error!, onRetry: _reload);
              final page = snapshot.data;
              if (page == null) return const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator()));
              if (page.items.isEmpty) return const Text('No users match.', style: AppText.secondary);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final user in page.items) _UserTile(user: user, selected: user.id == _selected, onTap: () => setState(() => _selected = user.id)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('${page.totalCount} users', style: AppText.caption),
                      const Spacer(),
                      if (page.totalPages > 1) ...[
                        TextButton(onPressed: page.page > 1 ? () => setState(() { _page--; _list = _load(); }) : null, child: const Text('Previous')),
                        Text('Page ${page.page} of ${page.totalPages}', style: AppText.caption),
                        TextButton(
                            onPressed: page.page < page.totalPages ? () => setState(() { _page++; _list = _load(); }) : null,
                            child: const Text('Next')),
                      ],
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );

    final detail = _selected == null
        ? const Panel(title: 'Account', child: Text('Pick a user to see their account.', style: AppText.secondary))
        : _UserDetailPanel(key: ValueKey(_selected), api: widget.api, id: _selected!, onChanged: _reload, onDeleted: () {
            setState(() => _selected = null);
            _reload();
          });

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
      child: wide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Expanded(flex: 3, child: list), const SizedBox(width: AppSpacing.lg), Expanded(flex: 2, child: detail)],
            )
          : Column(children: [list, const SizedBox(height: AppSpacing.lg), detail]),
    );
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({required this.user, required this.selected, required this.onTap});

  final UserRow user;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final last = user.lastWorkoutAt;
    return Material(
      color: selected ? AppColors.surface2 : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.username, style: AppText.body, overflow: TextOverflow.ellipsis),
                    Text(user.email, style: AppText.caption, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Expanded(flex: 2, child: Text('Joined ${_day.format(user.createdAt)}', style: AppText.caption)),
              Expanded(
                flex: 2,
                child: Text(last == null ? 'No workouts yet' : 'Last workout ${_day.format(last)}', style: AppText.caption),
              ),
              _status(user.disabled, user.isAdmin),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _status(bool disabled, bool isAdmin) => disabled
    ? const Pill('Disabled', color: AppColors.danger)
    : isAdmin
        ? const Pill('Admin', color: AppColors.success)
        : const Pill('Active');

class _UserDetailPanel extends StatefulWidget {
  const _UserDetailPanel({super.key, required this.api, required this.id, required this.onChanged, required this.onDeleted});

  final AdminApi api;
  final String id;
  final VoidCallback onChanged;
  final VoidCallback onDeleted;

  @override
  State<_UserDetailPanel> createState() => _UserDetailPanelState();
}

class _UserDetailPanelState extends State<_UserDetailPanel> {
  late Future<UserDetail> _detail = widget.api.user(widget.id);
  String? _email;
  bool _busy = false;

  Future<void> _run(String done, Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(done)));
      setState(() { _detail = widget.api.user(widget.id); });
      widget.onChanged();
    } on AdminApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<bool> _confirm(String title, String body, String action, {bool danger = false}) async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text(title, style: AppText.heading),
          content: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 420), child: Text(body, style: AppText.secondary)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            FilledButton(
              style: danger ? FilledButton.styleFrom(backgroundColor: AppColors.danger, foregroundColor: AppColors.onAccent) : null,
              onPressed: () => Navigator.pop(context, true),
              child: Text(action),
            ),
          ],
        ),
      ) ??
      false;

  Future<void> _delete(UserDetail user) async {
    final typed = await showDialog<String>(context: context, builder: (context) => _DeleteDialog(username: user.username));
    if (typed == null) return;
    setState(() => _busy = true);
    try {
      await widget.api.deleteUser(user.id, typed);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Deleted ${user.username}.')));
      widget.onDeleted();
    } on AdminApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Panel(
      title: 'Account',
      child: FutureBuilder(
        future: _detail,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return ErrorRetry(error: snapshot.error!, onRetry: () => setState(() { _detail = widget.api.user(widget.id); }));
          }
          final user = snapshot.data;
          if (user == null) return const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator()));
          final disabled = user.disabledAt != null;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.surface2,
                    child: Text(user.username.characters.first.toUpperCase(), style: AppText.heading.copyWith(color: AppColors.textSecondary)),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.username, style: AppText.heading),
                        Text('Joined ${_day.format(user.createdAt)}', style: AppText.caption),
                      ],
                    ),
                  ),
                  _status(disabled, user.isAdmin),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              _Fact('Email', Row(
                children: [
                  Flexible(child: SelectableText(_email ?? user.email, style: AppText.body)),
                  if (_email == null)
                    TextButton(
                      onPressed: _busy
                          ? null
                          : () async {
                              try {
                                final email = await widget.api.revealEmail(user.id);
                                if (mounted) setState(() => _email = email);
                              } on AdminApiException catch (e) {
                                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
                              }
                            },
                      child: const Text('Show'),
                    ),
                ],
              )),
              _Fact('Workouts', Text('${user.workouts}', style: AppText.body)),
              _Fact('Plans', Row(
                children: [
                  Text('${user.plans}', style: AppText.body),
                  if (user.plans > 0)
                    TextButton(onPressed: () => context.go('/plans?user=${user.id}'), child: const Text('View')),
                ],
              )),
              _Fact('Signed in on', Text('${user.signedInDevices} ${user.signedInDevices == 1 ? 'device' : 'devices'}', style: AppText.body)),
              _Fact('Reports sent', Text('${user.reports}', style: AppText.body)),
              if (disabled) _Fact('Disabled on', Text(_day.format(user.disabledAt!), style: AppText.body)),
              const SizedBox(height: AppSpacing.lg),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  OutlinedButton(
                    onPressed: _busy || user.signedInDevices == 0
                        ? null
                        : () async {
                            if (await _confirm('End all sessions?', '${user.username} will be signed out on every device within 30 minutes.', 'End sessions')) {
                              await _run('Ended all sessions of ${user.username}.', () => widget.api.userAction(user.id, 'end-sessions'));
                            }
                          },
                    child: const Text('End all sessions'),
                  ),
                  if (!user.isAdmin && !disabled)
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger),
                      onPressed: _busy
                          ? null
                          : () async {
                              if (await _confirm('Disable ${user.username}?',
                                  "They're signed out at once and can't sign in, refresh or reset the password until you enable the account again. Their data stays.",
                                  'Disable', danger: true)) {
                                await _run('Disabled ${user.username}.', () => widget.api.userAction(user.id, 'disable'));
                              }
                            },
                      child: const Text('Disable account'),
                    ),
                  if (disabled)
                    OutlinedButton(
                      onPressed: _busy ? null : () => _run('Enabled ${user.username}.', () => widget.api.userAction(user.id, 'enable')),
                      child: const Text('Enable account'),
                    ),
                  if (!user.isAdmin)
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger),
                      onPressed: _busy ? null : () => _delete(user),
                      child: const Text('Delete account'),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                user.isAdmin
                    ? "Admin accounts can't be disabled or deleted here."
                    : 'Showing the email and every action here is written to the audit log. Passwords are never shown.',
                style: AppText.caption,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact(this.label, this.value);

  final String label;
  final Widget value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [SizedBox(width: 120, child: Text(label, style: AppText.caption)), Expanded(child: value)],
      ),
    );
  }
}

/// Delete needs the username typed out. Returns what was typed, or null on cancel.
class _DeleteDialog extends StatefulWidget {
  const _DeleteDialog({required this.username});

  final String username;

  @override
  State<_DeleteDialog> createState() => _DeleteDialogState();
}

class _DeleteDialogState extends State<_DeleteDialog> {
  final _typed = TextEditingController();

  @override
  void dispose() {
    _typed.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final matches = _typed.text.trim().toLowerCase() == widget.username.toLowerCase();
    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text('Delete ${widget.username}?', style: AppText.heading),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This removes the account and everything in it: plans, workouts, weights and the picture. '
              "It can't be undone. The audit log keeps a line saying you deleted it.",
              style: AppText.secondary,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Type ${widget.username} to confirm', style: AppText.caption),
            const SizedBox(height: AppSpacing.xs),
            TextField(controller: _typed, autofocus: true, onChanged: (_) => setState(() {})),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.danger, foregroundColor: AppColors.onAccent),
          onPressed: matches ? () => Navigator.pop(context, _typed.text.trim()) : null,
          child: const Text('Delete account'),
        ),
      ],
    );
  }
}
