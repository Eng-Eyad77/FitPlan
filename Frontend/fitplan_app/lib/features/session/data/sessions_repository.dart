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

/// What the cardio sheet sends. Only machine and duration are required.
class CardioInput {
  const CardioInput({
    required this.machine,
    required this.durationSeconds,
    this.speedKmh,
    this.inclinePercent,
    this.distanceKm,
  });

  final CardioMachine machine;
  final int durationSeconds;
  final double? speedKmh;
  final double? inclinePercent;
  final double? distanceKm;

  Map<String, dynamic> toJson() => {
        'machine': machine.apiValue,
        'durationSeconds': durationSeconds,
        'speedKmh': speedKmh,
        'inclinePercent': inclinePercent,
        'distanceKm': distanceKm,
      };
}
