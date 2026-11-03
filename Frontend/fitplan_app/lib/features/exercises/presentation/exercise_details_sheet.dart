import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text.dart';
import '../../../shared/format.dart';
import '../../../shared/widgets/feedback.dart';
import '../data/exercises_repository.dart';
import 'widgets/exercise_thumb.dart';

/// The exercise playing big, with its step-by-step instructions.
///
/// [actionLabel] adds a button at the bottom (e.g. "Add to plan");
/// the sheet then returns true when it is pressed.
Future<bool?> showExerciseDetails(
  BuildContext context, {
  required String exerciseId,
  required String name,
  required String gifUrl,
  required String bodyPart,
  String? actionLabel,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (_) => _ExerciseDetailsSheet(
      exerciseId: exerciseId,
      name: name,
      gifUrl: gifUrl,
      bodyPart: bodyPart,
      actionLabel: actionLabel,
    ),
  );
}

/// "Step:1 Position yourself..." -> "Position yourself..."
String _stripStep(String line) => line.replaceFirst(RegExp(r'^\s*Step\s*:?\s*\d+\s*[.:)-]?\s*'), '');

class _ExerciseDetailsSheet extends ConsumerWidget {
  const _ExerciseDetailsSheet({
    required this.exerciseId,
    required this.name,
    required this.gifUrl,
    required this.bodyPart,
    this.actionLabel,
  });

  final String exerciseId;
  final String name;
  final String gifUrl;
  final String bodyPart;
  final String? actionLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // the instructions come from the library (the session does not carry them)
    final exercise = ref.watch(exerciseProvider(exerciseId));

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scroll) => Column(
        children: [
          Expanded(
            child: ListView(
              controller: scroll,
              padding: AppSpacing.screen.copyWith(bottom: AppSpacing.xxl),
              children: [
                LayoutBuilder(
                  builder: (context, constraints) => Center(
                    child: ExerciseThumb(
                      url: gifUrl,
                      size: constraints.maxWidth.clamp(0, 320).toDouble(),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(capitalize(name), style: AppText.title.copyWith(fontSize: 24)),
                const SizedBox(height: AppSpacing.sm),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.accentTint(0.12),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(
                      capitalize(bodyPart),
                      style: AppText.secondary.copyWith(color: AppColors.accent),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                const Text('How to do it', style: AppText.heading),
                const SizedBox(height: AppSpacing.md),
                exercise.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(AppSpacing.xl),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, _) => Text(
                    errorMessage(error, 'Could not load the instructions.'),
                    style: AppText.secondary,
                  ),
                  data: (exercise) => exercise.instructions.isEmpty
                      ? const Text('No instructions for this exercise yet.', style: AppText.secondary)
                      : Column(
                          children: [
                            for (var i = 0; i < exercise.instructions.length; i++)
                              _Step(number: i + 1, text: _stripStep(exercise.instructions[i])),
                          ],
                        ),
                ),
              ],
            ),
          ),
          if (actionLabel != null)
            SafeArea(
              top: false,
              child: Padding(
                padding: AppSpacing.screen.copyWith(top: AppSpacing.sm, bottom: AppSpacing.md),
                child: FilledButton.icon(
                  onPressed: () => Navigator.pop(context, true),
                  icon: const Icon(Icons.add_rounded),
                  label: Text(actionLabel!),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.number, required this.text});

  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: AppColors.accentTint(0.14), shape: BoxShape.circle),
            child: Text('$number', style: AppText.caption.copyWith(color: AppColors.accent, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(text, style: AppText.body)),
        ],
      ),
    );
  }
}
