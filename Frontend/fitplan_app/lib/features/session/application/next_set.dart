import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../shared/format.dart';
import '../domain/workout_session.dart';

/// The set that comes after the running rest, with the values the app would pre-fill,
/// so it can be logged from the notification without opening the app (9E).
class NextSet {
  const NextSet({
    required this.sessionId,
    required this.sessionExerciseId,
    required this.name,
    required this.setNumber,
    required this.reps,
    this.weightKg,
    this.targetSets,
    required this.restSeconds,
  });

  final String sessionId;
  final String sessionExerciseId;

  /// Already capitalized, ready to show.
  final String name;
  final int setNumber;
  final int reps;
  final double? weightKg;
  final int? targetSets;

  /// The rest to start after this set is logged.
  final int restSeconds;

  /// "Squat · set 3"
  String get label => '$name · set $setNumber';

  /// "60 kg × 12", or "12 reps" without a weight.
  String get values => weightKg == null ? '$reps reps' : '${formatKg(weightKg!)} kg × $reps';

  /// The set after this one, once this one is logged with the same values. Null after the last
  /// target set (the next exercise comes then) or at the most sets allowed.
  NextSet? get following {
    if (targetSets != null && setNumber >= targetSets!) return null;
    if (setNumber >= SessionLimits.maxSetsPerExercise) return null;
    return withValues(setNumber: setNumber + 1);
  }

  NextSet withValues({int? setNumber, int? reps, double? weightKg}) => NextSet(
        sessionId: sessionId,
        sessionExerciseId: sessionExerciseId,
        name: name,
        setNumber: setNumber ?? this.setNumber,
        reps: reps ?? this.reps,
        weightKg: weightKg ?? this.weightKg,
        targetSets: targetSets,
        restSeconds: restSeconds,
      );

  /// With what the user typed into this set's row, read the way the row reads it (an empty kg is
  /// no weight). Null when the typed values couldn't be logged in the app either.
  NextSet? withTyped({required String kg, required String reps}) {
    final count = int.tryParse(reps.trim());
    final kgText = kg.trim().replaceAll(',', '.');
    final weight = kgText.isEmpty ? null : double.tryParse(kgText);
    if (count == null || count < 1 || count > SessionLimits.maxReps) return null;
    if (kgText.isNotEmpty && (weight == null || weight < 0 || weight > SessionLimits.maxWeightKg)) return null;
    return NextSet(
      sessionId: sessionId,
      sessionExerciseId: sessionExerciseId,
      name: name,
      setNumber: setNumber,
      reps: count,
      weightKg: weight,
      targetSets: targetSets,
      restSeconds: restSeconds,
    );
  }

  Map<String, dynamic> toJson() => {
        'sessionId': sessionId,
        'sessionExerciseId': sessionExerciseId,
        'name': name,
        'setNumber': setNumber,
        'reps': reps,
        'weightKg': ?weightKg,
        'targetSets': ?targetSets,
        'restSeconds': restSeconds,
      };

  static NextSet? fromJson(Object? json) {
    if (json is! Map) return null;
    final sessionId = json['sessionId'];
    final exerciseId = json['sessionExerciseId'];
    final name = json['name'];
    final setNumber = json['setNumber'];
    final reps = json['reps'];
    final weight = json['weightKg'];
    final target = json['targetSets'];
    final rest = json['restSeconds'];
    if (sessionId is! String || exerciseId is! String || name is! String) return null;
    if (setNumber is! int || reps is! int || rest is! int) return null;
    // the same limits as the app's own set rows, so a damaged value is never sent
    if (setNumber < 1 || setNumber > SessionLimits.maxSetsPerExercise) return null;
    if (reps < 1 || reps > SessionLimits.maxReps) return null;
    if (weight != null && (weight is! num || weight < 0 || weight > SessionLimits.maxWeightKg)) return null;
    return NextSet(
      sessionId: sessionId,
      sessionExerciseId: exerciseId,
      name: name,
      setNumber: setNumber,
      reps: reps,
      weightKg: (weight as num?)?.toDouble(),
      targetSets: target is int ? target : null,
      restSeconds: rest,
    );
  }

  static NextSet? decode(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      return fromJson(jsonDecode(raw));
    } catch (_) {
      return null;
    }
  }

  String encode() => jsonEncode(toJson());
}

/// Sets logged from a notification, waiting to be sent by the app. The notification never calls
/// the server itself: the app sends them the next time it runs (right away when it is still
/// running in the background), and keeps them while there is no connection.
class PendingSetsStore {
  PendingSetsStore(this._storage);

  final FlutterSecureStorage _storage;

  static const _key = 'pending_sets';

  Future<List<NextSet>> read() async {
    try {
      final raw = await _storage.read(key: _key).timeout(const Duration(seconds: 2));
      if (raw == null) return const [];
      final list = jsonDecode(raw);
      if (list is! List) return const [];
      return [for (final item in list) ?NextSet.fromJson(item)];
    } catch (_) {
      return const [];
    }
  }

  Future<void> write(List<NextSet> sets) async {
    try {
      if (sets.isEmpty) {
        await _storage.delete(key: _key);
      } else {
        await _storage.write(key: _key, value: jsonEncode([for (final s in sets) s.toJson()]));
      }
    } catch (_) {}
  }

  /// A second tap on the same set is ignored.
  Future<void> add(NextSet set) async {
    final sets = await read();
    final duplicate = sets.any((s) => s.sessionExerciseId == set.sessionExerciseId && s.setNumber == set.setNumber);
    if (!duplicate) await write([...sets, set]);
  }
}
