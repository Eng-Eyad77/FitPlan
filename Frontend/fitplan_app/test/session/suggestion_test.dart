import 'package:fitplan_app/features/session/domain/workout_session.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reads the API suggestion, bodyweight without a weight', () {
    final weighted = Suggestion.fromJson({'weightKg': 62.5, 'reps': 10, 'reason': 'IncreaseWeight'});
    expect(weighted.weightKg, 62.5);
    expect(weighted.reason, SuggestionReason.increaseWeight);

    final bodyweight = Suggestion.fromJson({'weightKg': null, 'reps': 16, 'reason': 'MoreReps'});
    expect(bodyweight.weightKg, isNull);
    expect(bodyweight.why, contains('one more rep'));
  });

  test('a session exercise without history has no suggestion', () {
    final exercise = SessionExercise.fromJson({
      'id': 'a', 'exerciseId': 'b', 'name': 'squat', 'gifUrl': '', 'bodyPart': 'upper legs', 'order': 1,
    });
    expect(exercise.suggestion, isNull);
  });
}
