import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../domain/workout_plan.dart';

final plansRepositoryProvider = Provider<PlansRepository>(
  (ref) => PlansRepository(ref.watch(dioProvider)),
);

/// /api/workout-plans and their exercises. Throws ApiException on failure.
class PlansRepository {
  PlansRepository(this._dio);

  final Dio _dio;

  Future<List<WorkoutPlan>> getPlans() async {
    final response = await apiCall(() => _dio.get<List<dynamic>>('/api/workout-plans'));
    return [
      for (final json in response.data!) WorkoutPlan.fromJson(json as Map<String, dynamic>),
    ];
  }

  Future<WorkoutPlan> getPlan(String id) async {
    final response =
        await apiCall(() => _dio.get<Map<String, dynamic>>('/api/workout-plans/$id'));
    return WorkoutPlan.fromJson(response.data!);
  }

  Future<WorkoutPlan> createPlan({required String name, String? description}) async {
    final response = await apiCall(
      () => _dio.post<Map<String, dynamic>>(
        '/api/workout-plans',
        data: {'name': name, 'description': description},
      ),
    );
    return WorkoutPlan.fromJson(response.data!);
  }

  Future<WorkoutPlan> updatePlan(String id, {required String name, String? description}) async {
    final response = await apiCall(
      () => _dio.put<Map<String, dynamic>>(
        '/api/workout-plans/$id',
        data: {'name': name, 'description': description},
      ),
    );
    return WorkoutPlan.fromJson(response.data!);
  }

  Future<void> deletePlan(String id) async {
    await apiCall(() => _dio.delete<void>('/api/workout-plans/$id'));
  }

  /// Sorted by order (the API already does it).
  Future<List<PlanExercise>> getExercises(String planId) async {
    final response =
        await apiCall(() => _dio.get<List<dynamic>>('/api/workout-plans/$planId/exercises'));
    return [
      for (final json in response.data!) PlanExercise.fromJson(json as Map<String, dynamic>),
    ];
  }

  Future<PlanExercise> addExercise(
    String planId, {
    required String exerciseId,
    required int sets,
    required int reps,
    required int order,
  }) async {
    final response = await apiCall(
      () => _dio.post<Map<String, dynamic>>(
        '/api/workout-plans/$planId/exercises',
        data: {'exerciseId': exerciseId, 'sets': sets, 'reps': reps, 'order': order},
      ),
    );
    return PlanExercise.fromJson(response.data!);
  }

  Future<PlanExercise> updateExercise(
    String planId,
    String id, {
    required int sets,
    required int reps,
    required int order,
  }) async {
    final response = await apiCall(
      () => _dio.put<Map<String, dynamic>>(
        '/api/workout-plans/$planId/exercises/$id',
        data: {'sets': sets, 'reps': reps, 'order': order},
      ),
    );
    return PlanExercise.fromJson(response.data!);
  }

  Future<void> removeExercise(String planId, String id) async {
    await apiCall(() => _dio.delete<void>('/api/workout-plans/$planId/exercises/$id'));
  }
}
