import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../domain/workout_session.dart';

final sessionsRepositoryProvider = Provider<SessionsRepository>(
  (ref) => SessionsRepository(ref.watch(dioProvider)),
);

/// /api/sessions with its exercises, sets and cardio. Throws ApiException on failure.
class SessionsRepository {
  SessionsRepository(this._dio);

  final Dio _dio;

  static const _base = '/api/sessions';

  /// The session in progress, or null when there is none.
  Future<WorkoutSession?> getActive() async {
    try {
      final response = await apiCall(() => _dio.get<Map<String, dynamic>>('$_base/active'));
      return WorkoutSession.fromJson(response.data!);
    } on ApiException catch (error) {
      if (error.code == 'NoActiveSession') return null;
      rethrow;
    }
  }

  /// [planId] null = quick workout (empty session).
  Future<WorkoutSession> start({String? planId}) async {
    final response = await apiCall(
      () => _dio.post<Map<String, dynamic>>(_base, data: {'workoutPlanId': planId}),
    );
    return WorkoutSession.fromJson(response.data!);
  }

  Future<WorkoutSession> getSession(String id) async {
    final response = await apiCall(() => _dio.get<Map<String, dynamic>>('$_base/$id'));
    return WorkoutSession.fromJson(response.data!);
  }

  /// Completed sessions, newest first; with [since], only the ones finished from then on.
  Future<HistoryPage> getHistory({int page = 1, int pageSize = 20, DateTime? since}) async {
    final response = await apiCall(
      () => _dio.get<Map<String, dynamic>>(
        _base,
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
          if (since != null) 'since': since.toUtc().toIso8601String(),
        },
      ),
    );
    final data = response.data!;
    return HistoryPage(
      items: [
        for (final json in data['items'] as List<dynamic>)
          SessionSummary.fromJson(json as Map<String, dynamic>),
      ],
      page: data['page'] as int,
      totalPages: data['totalPages'] as int,
    );
  }

  Future<SessionSummary> complete(String id, {String? notes}) async {
    final response = await apiCall(
      () => _dio.post<Map<String, dynamic>>('$_base/$id/complete', data: {'notes': notes}),
    );
    return SessionSummary.fromJson(response.data!);
  }

  /// Cancels a session in progress (or deletes a completed one).
  Future<void> delete(String id) async {
    await apiCall(() => _dio.delete<void>('$_base/$id'));
  }

  // ---- exercises ----

  Future<SessionExercise> addExercise(String sessionId, String exerciseId) async {
    final response = await apiCall(
      () => _dio.post<Map<String, dynamic>>(
        '$_base/$sessionId/exercises',
        data: {'exerciseId': exerciseId},
      ),
    );
    return SessionExercise.fromJson(response.data!);
  }

  Future<void> removeExercise(String sessionId, String sessionExerciseId) async {
    await apiCall(() => _dio.delete<void>('$_base/$sessionId/exercises/$sessionExerciseId'));
  }

  /// Changes the rest for this session only; the plan keeps its own.
  /// The exercise's note for this workout; it goes back to the plan when the workout is finished.
  Future<void> updateNote(String sessionId, String sessionExerciseId, String? note) async {
    await apiCall(() => _dio.put<void>('$_base/$sessionId/exercises/$sessionExerciseId/note', data: {'note': note}));
  }

  Future<void> updateRest(String sessionId, String sessionExerciseId, int? restSeconds) async {
    await apiCall(() => _dio.patch<void>(
          '$_base/$sessionId/exercises/$sessionExerciseId',
          data: {'restSeconds': restSeconds},
        ));
  }

  // ---- sets ----

  Future<SessionSet> addSet(
    String sessionId,
    String sessionExerciseId, {
    required int reps,
    double? weightKg,
  }) async {
    final response = await apiCall(
      () => _dio.post<Map<String, dynamic>>(
        '$_base/$sessionId/exercises/$sessionExerciseId/sets',
        data: {'reps': reps, 'weightKg': weightKg},
      ),
    );
    return SessionSet.fromJson(response.data!);
  }

  Future<SessionSet> updateSet(
    String sessionId,
    String sessionExerciseId,
    String setId, {
    required int reps,
    double? weightKg,
  }) async {
    final response = await apiCall(
      () => _dio.put<Map<String, dynamic>>(
        '$_base/$sessionId/exercises/$sessionExerciseId/sets/$setId',
        data: {'reps': reps, 'weightKg': weightKg},
      ),
    );
    return SessionSet.fromJson(response.data!);
  }

  Future<void> deleteSet(String sessionId, String sessionExerciseId, String setId) async {
    await apiCall(
      () => _dio.delete<void>('$_base/$sessionId/exercises/$sessionExerciseId/sets/$setId'),
    );
  }

  // ---- cardio ----

  Future<CardioEntry> addCardio(String sessionId, CardioInput input) async {
    final response = await apiCall(
      () => _dio.post<Map<String, dynamic>>('$_base/$sessionId/cardio', data: input.toJson()),
    );
    return CardioEntry.fromJson(response.data!);
  }

  Future<void> deleteCardio(String sessionId, String id) async {
    await apiCall(() => _dio.delete<void>('$_base/$sessionId/cardio/$id'));
  }
}

class HistoryPage {
  const HistoryPage({required this.items, required this.page, required this.totalPages});

  final List<SessionSummary> items;
  final int page;
  final int totalPages;

  bool get hasMore => page < totalPages;
}

/// What the cardio sheet sends. Only machine and duration are required.
/// A cardio entry to save. Only the details of [machine] are sent; the API refuses the others.
class CardioInput {
  const CardioInput({required this.machine, required this.durationSeconds, this.values = const {}});

  final CardioMachine machine;
  final int durationSeconds;
  final Map<CardioField, num> values;

  Map<String, dynamic> toJson() => {
        'machine': machine.apiValue,
        'durationSeconds': durationSeconds,
        for (final field in machine.fields)
          if (values[field] case final value?) field.jsonKey: field.decimal ? value.toDouble() : value.toInt(),
      };
}
