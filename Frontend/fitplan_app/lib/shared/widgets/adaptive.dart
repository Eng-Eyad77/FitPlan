import 'package:fitplan_shared/fitplan_shared.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';

/// Menus and confirmations that look native: the iOS action sheet and alert on iPhone, Material on
/// Android (Eyad's iPhone test, 2026-11-25: the Material ones looked like the emulator's).
bool get _apple => defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS;

/// One row of an options menu.
class MenuAction {
  const MenuAction({required this.label, required this.onTap, this.icon, this.destructive = false});

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final bool destructive;
}

/// The "more" button of a screen or card. Opens [actions] as a sheet from the bottom, with room for
/// each row (the old popup menu felt cramped).
class ActionsButton extends StatelessWidget {
  const ActionsButton({super.key, required this.tooltip, required this.actions, this.color});

  final String tooltip;
  final List<MenuAction> Function() actions;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      icon: Icon(_apple ? Icons.more_horiz_rounded : Icons.more_vert_rounded, color: color),
      onPressed: () => showActions(context, actions: actions()),
    );
  }
}

/// Shows [actions]; the chosen one runs after the sheet has closed.
Future<void> showActions(BuildContext context, {required List<MenuAction> actions, String? title}) async {
  final chosen = _apple
      ? await showCupertinoModalPopup<MenuAction>(
          context: context,
          builder: (context) => CupertinoActionSheet(
            title: title == null ? null : Text(title),
            actions: [
              for (final action in actions)
                CupertinoActionSheetAction(
                  isDestructiveAction: action.destructive,
                  onPressed: () => Navigator.pop(context, action),
                  child: Text(action.label),
                ),
            ],
            cancelButton: CupertinoActionSheetAction(
              isDefaultAction: true,
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
          ),
        )
      : await showModalBottomSheet<MenuAction>(
          context: context,
          // over the tab bar too, like the iOS sheet
          useRootNavigator: true,
          showDragHandle: true,
          builder: (context) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (title != null)
                    Padding(
                      padding: AppSpacing.screen.copyWith(bottom: AppSpacing.sm),
                      child: Text(title, style: AppText.secondary),
                    ),
                  for (final action in actions)
                    ListTile(
                      minTileHeight: 56,
                      leading: action.icon == null
                          ? null
                          : Icon(action.icon, color: action.destructive ? AppColors.danger : AppColors.textSecondary),
                      title: Text(
                        action.label,
                        style: AppText.body.copyWith(color: action.destructive ? AppColors.danger : null),
                      ),
                      onTap: () => Navigator.pop(context, action),
                    ),
                ],
              ),
            ),
          ),
        );
  chosen?.onTap();
}

/// "Are you sure?" with two choices. True only when [confirmLabel] was chosen.
Future<bool> confirmAction(
  BuildContext context, {
  required String title,
  String? body,
  required String confirmLabel,
  required String cancelLabel,
  bool destructive = true,
}) async {
  Widget button(String label, bool value, {bool danger = false, bool main = false}) => _apple
      ? CupertinoDialogAction(
          isDestructiveAction: danger,
          isDefaultAction: main,
          onPressed: () => Navigator.pop(context, value),
          child: Text(label),
        )
      : TextButton(
          onPressed: () => Navigator.pop(context, value),
          style: danger ? TextButton.styleFrom(foregroundColor: AppColors.danger) : null,
          child: Text(label),
        );

  final result = await showAdaptiveDialog<bool>(
    context: context,
    builder: (context) => AlertDialog.adaptive(
      title: Text(title),
      content: body == null ? null : Text(body),
      actions: [
        button(cancelLabel, false, main: destructive),
        button(confirmLabel, true, danger: destructive, main: !destructive),
      ],
    ),
  );
  return result == true;
}
