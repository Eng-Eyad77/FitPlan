import 'package:flutter_riverpod/flutter_riverpod.dart';

/// What the user typed into sets not logged yet, and the extra rows they asked for.
/// Kept outside the cards, so closing a card (or leaving the screen) keeps the values.
/// Only in memory: it lasts while the app is open.
class SessionDrafts {
  final _values = <String, ({String kg, String reps})>{};
  final _extraRows = <String, int>{};

  static String _key(String sessionExerciseId, int setNumber) => '$sessionExerciseId#$setNumber';

  ({String kg, String reps})? value(String sessionExerciseId, int setNumber) =>
      _values[_key(sessionExerciseId, setNumber)];

  void setValue(String sessionExerciseId, int setNumber, {required String kg, required String reps}) =>
      _values[_key(sessionExerciseId, setNumber)] = (kg: kg, reps: reps);

  /// After the set was logged, its typed values are no longer needed.
  void clearValue(String sessionExerciseId, int setNumber) => _values.remove(_key(sessionExerciseId, setNumber));

  int extraRows(String sessionExerciseId) => _extraRows[sessionExerciseId] ?? 0;

  void setExtraRows(String sessionExerciseId, int rows) =>
      rows <= 0 ? _extraRows.remove(sessionExerciseId) : _extraRows[sessionExerciseId] = rows;

  /// When the workout is finished or discarded.
  void clear() {
    _values.clear();
    _extraRows.clear();
  }
}

final sessionDraftsProvider = Provider<SessionDrafts>((ref) => SessionDrafts());
