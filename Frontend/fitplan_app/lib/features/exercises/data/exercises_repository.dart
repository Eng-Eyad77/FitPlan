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
}
