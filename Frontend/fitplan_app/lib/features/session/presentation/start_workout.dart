import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/network/api_exception.dart';
import '../../../shared/widgets/feedback.dart';
import '../application/active_session_controller.dart';

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
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Workout in progress'),
      content: Text('You have "$name" running. Finish or cancel it before starting a new one.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Not now')),
        TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Resume')),
      ],
    ),
  );
}
