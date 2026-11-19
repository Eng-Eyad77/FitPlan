import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../domain/exercise.dart';

final exercisesRepositoryProvider = Provider<ExercisesRepository>(
  (ref) => ExercisesRepository(ref.watch(dioProvider)),
);

/// /api/exercises (the library). Throws ApiException on failure.
class ExercisesRepository {
  ExercisesRepository(this._dio);

  final Dio _dio;

  static const pageSize = 30;

  Future<ExercisePage> getPage({int page = 1, String? bodyPart, String? search}) async {
    final response = await apiCall(
      () => _dio.get<Map<String, dynamic>>(
        '/api/exercises',
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
          'bodyPart': ?bodyPart,
          if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        },
      ),
    );
    return ExercisePage.fromJson(response.data!);
  }

  /// The body parts for the filter chips, in order. The API leaves out hidden ones (cardio).
  Future<List<String>> getBodyParts() async {
    final response = await apiCall(() => _dio.get<List<dynamic>>('/api/exercises/body-parts'));
    return response.data!.cast<String>();
  }

  Future<Exercise> getExercise(String id) async {
    final response = await apiCall(() => _dio.get<Map<String, dynamic>>('/api/exercises/$id'));
    return Exercise.fromJson(response.data!);
  }
}

/// The filter chips. Loaded once while the app runs; on an error only "All" shows.
final bodyPartsProvider = FutureProvider<List<String>>(
  (ref) => ref.watch(exercisesRepositoryProvider).getBodyParts(),
);

/// One exercise by id (cached while the app runs: the library does not change).
final exerciseProvider = FutureProvider.family<Exercise, String>(
  (ref, id) => ref.watch(exercisesRepositoryProvider).getExercise(id),
);
