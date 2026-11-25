import 'package:fitplan_shared/fitplan_shared.dart';
import 'package:flutter/material.dart';

import '../../features/plans/domain/workout_plan.dart' show PlanLimits;
import '../../l10n/l10n.dart';

/// An exercise's note ("seat on 4") under its card in a plan or a workout. Tapping it edits it; with
/// no note it is a small "Add note" link, so cards without notes keep their old look.
class ExerciseNoteLine extends StatelessWidget {
  const ExerciseNoteLine({super.key, required this.note, required this.onEdit});

  final String? note;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final text = note;
    if (text == null) {
      return Align(
        alignment: AlignmentDirectional.centerStart,
        child: TextButton.icon(
          onPressed: onEdit,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textTertiary,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            minimumSize: const Size(0, 36),
            visualDensity: VisualDensity.compact,
          ),
          icon: const Icon(Icons.sticky_note_2_outlined, size: 18),
          label: Text(l10n.addNote, style: AppText.caption.copyWith(color: AppColors.textTertiary)),
        ),
      );
    }
    return Material(
      color: AppColors.accentTint(0.08),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(Icons.sticky_note_2_rounded, size: 16, color: AppColors.accent),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  text,
                  style: AppText.secondary.copyWith(color: AppColors.textPrimary),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Icon(Icons.edit_outlined, size: 16, color: AppColors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}

/// Edits a note. Returns the new text ('' removes it), or null when nothing should change.
Future<String?> showNoteSheet(BuildContext context, {String? initial}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => _NoteSheet(initial: initial ?? ''),
  );
}

class _NoteSheet extends StatefulWidget {
  const _NoteSheet({required this.initial});

  final String initial;

  @override
  State<_NoteSheet> createState() => _NoteSheetState();
}

class _NoteSheetState extends State<_NoteSheet> {
  late final _text = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // stays above the keyboard
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: Padding(
          padding: AppSpacing.screen.copyWith(bottom: AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.exerciseNote, style: AppText.heading),
              const SizedBox(height: AppSpacing.xs),
              Text(l10n.exerciseNoteBody, style: AppText.secondary),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: _text,
                autofocus: true,
                minLines: 2,
                maxLines: 5,
                maxLength: PlanLimits.noteLength,
                textCapitalization: TextCapitalization.sentences,
                style: AppText.body,
                decoration: InputDecoration(hintText: l10n.exerciseNoteHint),
              ),
              const SizedBox(height: AppSpacing.md),
              // the theme makes FilledButton full width, so the two stack
              FilledButton(
                onPressed: () => Navigator.pop(context, _text.text),
                child: Text(l10n.save),
              ),
              if (widget.initial.isNotEmpty)
                TextButton(
                  onPressed: () => Navigator.pop(context, ''),
                  style: TextButton.styleFrom(foregroundColor: AppColors.danger),
                  child: Text(l10n.removeNote),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
