import 'package:fitplan_shared/fitplan_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/feedback.dart';
import '../../../shared/widgets/loading_button.dart';
import '../application/active_session_controller.dart';
import '../domain/workout_session.dart';
import '../../../l10n/l10n.dart';

/// Confirms finishing, with optional notes. Returns the summary when finished.
Future<SessionSummary?> showFinishSheet(BuildContext context, WorkoutSession session) {
  return showModalBottomSheet<SessionSummary>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _FinishSheet(session: session),
  );
}

class _FinishSheet extends ConsumerStatefulWidget {
  const _FinishSheet({required this.session});

  final WorkoutSession session;

  @override
  ConsumerState<_FinishSheet> createState() => _FinishSheetState();
}

class _FinishSheetState extends ConsumerState<_FinishSheet> {
  final _notes = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    setState(() => _saving = true);
    try {
      final notes = _notes.text.trim();
      final summary = await ref
          .read(activeSessionControllerProvider.notifier)
          .finish(notes: notes.isEmpty ? null : notes);
      if (mounted) Navigator.pop(context, summary);
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      showError(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.session;
    final unfinished = session.exercises.where((e) => !e.isDone).length;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: AppSpacing.screen.copyWith(bottom: AppSpacing.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.finishWorkoutTitle, style: AppText.heading),
            const SizedBox(height: AppSpacing.xs),
            Text(
              unfinished == 0
                  ? l10n.finishAllDone
                  : l10n.finishUnfinished(unfinished),
              style: AppText.secondary,
            ),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: _notes,
              maxLength: 1000,
              maxLines: 3,
              minLines: 1,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l10n.notesOptional,
                hintText: l10n.howDidItFeel,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            LoadingButton(label: l10n.finishWorkout, loading: _saving, onPressed: _finish),
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: _saving ? null : () => Navigator.pop(context),
              style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
              child: Text(l10n.keepTraining),
            ),
          ],
        ),
      ),
    );
  }
}
