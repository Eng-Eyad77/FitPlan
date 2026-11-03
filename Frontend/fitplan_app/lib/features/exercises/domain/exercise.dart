import 'package:freezed_annotation/freezed_annotation.dart';

part 'exercise.freezed.dart';
part 'exercise.g.dart';

/// One exercise from the library (GET /api/exercises).
@freezed
abstract class Exercise with _$Exercise {
  const factory Exercise({
    required String id,
    required String name,
    required String gifUrl,
    required String bodyPart,
    @Default([]) List<String> instructions,
  }) = _Exercise;

  factory Exercise.fromJson(Map<String, dynamic> json) => _$ExerciseFromJson(json);
}

/// One page of the exercise library.
@freezed
abstract class ExercisePage with _$ExercisePage {
  const ExercisePage._();

  const factory ExercisePage({
    required List<Exercise> items,
    required int page,
    required int totalPages,
    required int totalCount,
  }) = _ExercisePage;

  factory ExercisePage.fromJson(Map<String, dynamic> json) => _$ExercisePageFromJson(json);

  bool get hasMore => page < totalPages;
}

/// The body parts the library uses, in the order the filter chips show them.
const bodyParts = [
  'chest',
  'back',
  'shoulders',
  'upper arms',
  'lower arms',
  'upper legs',
  'lower legs',
  'waist',
  'neck',
  'cardio',
];
