import 'package:fitplan_shared/fitplan_shared.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../core/admin_api.dart';
import '../core/env.dart';

/// The six areas, in the order of the side menu, with the part of Phase 12 that builds each.
enum AdminArea {
  overview('/overview', 'Overview', '12E'),
  users('/users', 'Users', '12B'),
  exercises('/exercises', 'Exercises', '12C'),
  plans('/plans', 'Plans and cardio', '12D'),
  reports('/reports', 'Reports and errors', '12F'),
  admins('/admins', 'Admins', '12A');

  const AdminArea(this.path, this.label, this.part);

  final String path;
  final String label;
  final String part;
}

const _railColor = Color(0xFF0D1416);
const _wide = 900.0;

/// Side menu and top bar around every signed-in screen. Narrow windows get the menu as a drawer.
class AdminShell extends StatelessWidget {
  const AdminShell({super.key, required this.api, required this.location, required this.child});

  final AdminApi api;
  final String location;
  final Widget child;

  AdminArea get _current => AdminArea.values.firstWhere((a) => location.startsWith(a.path), orElse: () => AdminArea.admins);

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= _wide;
    final rail = _Rail(current: _current);
    final top = _TopBar(api: api, title: _current.label, showMenu: !wide);

    return Scaffold(
      drawer: wide ? null : Drawer(backgroundColor: _railColor, child: rail),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (wide) SizedBox(width: 236, child: rail),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [top, const Divider(height: 1), Expanded(child: child)],
            ),
          ),
        ],
      ),
    );
  }
}

class _Rail extends StatelessWidget {
  const _Rail({required this.current});

  final AdminArea current;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: _railColor,
        border: BorderDirectional(end: BorderSide(color: AppColors.border)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 20, 14, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 18),
              child: Row(
                children: [
                  const BrandMark(size: 28),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text.rich(
                      TextSpan(
                        text: 'FitPlan  ',
                        style: AppText.bodyStrong.copyWith(fontSize: 16),
                        children: const [TextSpan(text: 'Admin', style: AppText.caption)],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            for (final area in AdminArea.values) _RailItem(area: area, selected: area == current),
          ],
        ),
      ),
    );
  }
}

class _RailItem extends StatelessWidget {
  const _RailItem({required this.area, required this.selected});

  final AdminArea area;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: selected ? AppColors.surface2 : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            Scaffold.maybeOf(context)?.closeDrawer();
            context.go(area.path);
          },
          child: Container(
            decoration: selected
                ? const BoxDecoration(border: BorderDirectional(start: BorderSide(color: AppColors.accent, width: 3)))
                : null,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Text(
              area.label,
              style: AppText.secondary.copyWith(color: selected ? AppColors.textPrimary : AppColors.textSecondary),
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.api, required this.title, required this.showMenu});

  final AdminApi api;
  final String title;
  final bool showMenu;

  @override
  Widget build(BuildContext context) {
    final session = api.session.value;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Row(
        children: [
          if (showMenu)
            IconButton(
              tooltip: 'Menu',
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          Expanded(child: Text(title, style: AppText.heading.copyWith(fontSize: 19))),
          const EnvChip(),
          const SizedBox(width: AppSpacing.md),
          if (session != null)
            PopupMenuButton<void>(
              tooltip: 'Account',
              color: AppColors.surface2,
              itemBuilder: (context) => [
                PopupMenuItem(
                  enabled: false,
                  child: Text(
                    '${session.username}, ${session.role}\nSession ends at ${DateFormat.Hm().format(session.expiresAt)}',
                    style: AppText.secondary,
                  ),
                ),
                PopupMenuItem(onTap: api.signOut, child: const Text('Sign out')),
              ],
              child: CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.surface2,
                child: Text(session.username.characters.first.toUpperCase(), style: AppText.bodyStrong.copyWith(color: AppColors.textSecondary)),
              ),
            ),
        ],
      ),
    );
  }
}

/// Which environment this admin talks to. Production is red so it's never mistaken for Dev.
class EnvChip extends StatelessWidget {
  const EnvChip({super.key});

  @override
  Widget build(BuildContext context) {
    final color = switch (Env.name) {
      'Production' => AppColors.danger,
      'Dev' => AppColors.success,
      _ => AppColors.textSecondary,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(Env.name, style: AppText.caption.copyWith(color: color, fontWeight: FontWeight.w600)),
    );
  }
}
