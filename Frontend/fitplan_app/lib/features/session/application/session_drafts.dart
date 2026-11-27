import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../domain/workout_session.dart';

/// Keeps the typed values on the phone, so force-closing the app mid-workout keeps them.
/// Failures are ignored: typing still works, it just won't survive a restart.
class SessionDraftsStore {
  SessionDraftsStore(this._storage);

  final FlutterSecureStorage _storage;

  static const _key = 'session_drafts';

  Future<Map<String, dynamic>?> read() async {
    try {
      // never hold up opening the workout for long
      final raw = await _storage.read(key: _key).timeout(const Duration(seconds: 2));
      return raw == null ? null : jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> write(Map<String, dynamic>? data) async {
    try {
      if (data == null) {
        await _storage.delete(key: _key);
      } else {
        await _storage.write(key: _key, value: jsonEncode(data));
      }
    } catch (_) {
      // not saved; the values on screen are unaffected
    }
  }
}

final sessionDraftsStoreProvider =
    Provider<SessionDraftsStore>((ref) => SessionDraftsStore(const FlutterSecureStorage()));

/// What the user typed into sets not logged yet, and the extra rows they asked for.
/// Kept outside the cards, so closing a card (or leaving the screen) keeps the values,
/// and saved on the phone, so closing the app keeps them too.
class SessionDrafts {
  SessionDrafts(this._store);

  final SessionDraftsStore _store;
  final _values = <String, ({String kg, String reps})>{};
  final _extraRows = <String, int>{};

  /// Read back from the phone once per app run; after that, memory is the source.
  bool _restored = false;

  /// Saves never overlap: a change during a save is written right after it.
  bool _saving = false;
  bool _dirty = false;

  static String _key(String sessionExerciseId, int setNumber) => '$sessionExerciseId#$setNumber';

  static String _exerciseOf(String key) => key.substring(0, key.lastIndexOf('#'));

  ({String kg, String reps})? value(String sessionExerciseId, int setNumber) =>
      _values[_key(sessionExerciseId, setNumber)];

  void setValue(String sessionExerciseId, int setNumber, {required String kg, required String reps}) {
    _values[_key(sessionExerciseId, setNumber)] = (kg: kg, reps: reps);
    _save();
  }

  /// After the set was logged, its typed values are no longer needed.
  void clearValue(String sessionExerciseId, int setNumber) {
    if (_values.remove(_key(sessionExerciseId, setNumber)) != null) _save();
  }

  int extraRows(String sessionExerciseId) => _extraRows[sessionExerciseId] ?? 0;

  void setExtraRows(String sessionExerciseId, int rows) {
    rows <= 0 ? _extraRows.remove(sessionExerciseId) : _extraRows[sessionExerciseId] = rows;
    _save();
  }

  /// When the workout is finished or discarded.
  void clear() {
    _values.clear();
    _extraRows.clear();
    _save();
  }

  /// Loads what was saved for [session]'s exercises. Anything from another workout is dropped.
  Future<void> restore(WorkoutSession session) async {
    if (_restored) return;
    _restored = true;
    final saved = await _store.read();
    if (saved == null) return;

    final ids = {for (final e in session.exercises) e.id};
    try {
      final values = saved['values'] as Map<String, dynamic>? ?? const {};
      for (final MapEntry(:key, :value) in values.entries) {
        if (!ids.contains(_exerciseOf(key)) || _values.containsKey(key)) continue;
        final v = value as Map<String, dynamic>;
        _values[key] = (kg: v['kg'] as String? ?? '', reps: v['reps'] as String? ?? '');
      }
      final rows = saved['extraRows'] as Map<String, dynamic>? ?? const {};
      for (final MapEntry(:key, :value) in rows.entries) {
        if (ids.contains(key) && value is int && value > 0) _extraRows.putIfAbsent(key, () => value);
      }
    } catch (_) {
      // an unreadable save is ignored
    }
  }

  Map<String, dynamic>? _toJson() => _values.isEmpty && _extraRows.isEmpty
      ? null
      : {
          'values': {
            for (final MapEntry(:key, :value) in _values.entries) key: {'kg': value.kg, 'reps': value.reps},
          },
          'extraRows': {..._extraRows},
        };

  Future<void> _save() async {
    if (_saving) {
      _dirty = true;
      return;
    }
    _saving = true;
    do {
      _dirty = false;
      await _store.write(_toJson());
    } while (_dirty);
    _saving = false;
  }
}

final sessionDraftsProvider = Provider<SessionDrafts>((ref) => SessionDrafts(ref.read(sessionDraftsStoreProvider)));
