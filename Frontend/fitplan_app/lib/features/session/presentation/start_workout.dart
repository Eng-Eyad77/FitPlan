import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/adaptive.dart';
import '../../../app/router.dart';
import '../../../core/network/api_exception.dart';
import '../../../shared/widgets/feedback.dart';
import '../application/active_session_controller.dart';
import '../../../l10n/l10n.dart';

/// Starts a workout (from a plan, or empty when [planId] is null) and opens it.
/// If one is already in progress, offers to resume it instead.
Future<void> startWorkout(BuildContext context, WidgetRef ref, {String? planId}) async {
  final controller = ref.read(activeSessionControllerProvider.notifier);

  final current = ref.read(activeSessionControllerProvider).value;
  if (current != null) {
    final resume = await _askResume(context, current.name);
    if (resume == true && context.mounted) context.push(Routes.session);
    return;
  }

  try {
    await controller.start(planId: planId);
    if (context.mounted) context.push(Routes.session);
  } on ApiException catch (error) {
    if (!context.mounted) return;
    if (error.code == 'ActiveSessionExists') {
      // started on another device, or the app did not know yet
      await controller.refresh();
      if (context.mounted) context.push(Routes.session);
      return;
    }
    showError(context, error);
  }
}

Future<bool?> _askResume(BuildContext context, String name) {
  return confirmAction(
    context,
    title: l10n.workoutInProgressTitle,
    body: l10n.workoutInProgressBody(name),
    confirmLabel: l10n.resume,
    cancelLabel: l10n.notNow,
    destructive: false,
  );
}
