import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../domain/stats.dart';

final statsRepositoryProvider = Provider<StatsRepository>(
  (ref) => StatsRepository(ref.watch(dioProvider)),
);

/// /api/stats and the body weight history. Throws ApiException on failure.
class StatsRepository {
  StatsRepository(this._dio);

  final Dio _dio;

  /// The weeks are counted in the phone's time zone, starting on [weekStartsOn]
  /// (DateTime.weekday numbers: 1 = Monday ... 7 = Sunday).
  Future<StatsOverview> getOverview({required int weekStartsOn, int weeks = 8}) async {
    final response = await apiCall(
      () => _dio.get<Map<String, dynamic>>(
        '/api/stats/overview',
        queryParameters: {
          'weeks': weeks,
          'utcOffsetMinutes': DateTime.now().timeZoneOffset.inMinutes,
          // the API uses .NET DayOfWeek: Sunday = 0 ... Saturday = 6
          'weekStartsOn': weekStartsOn % 7,
        },
      ),
    );
    return StatsOverview.fromJson(response.data!);
  }

  Future<List<ExerciseRecords>> getRecords() async {
    final response = await apiCall(() => _dio.get<List<dynamic>>('/api/stats/records'));
    return [
      for (final json in response.data!) ExerciseRecords.fromJson(json as Map<String, dynamic>),
    ];
  }

  Future<ExerciseProgress> getExerciseProgress(String exerciseId) async {
    final response =
        await apiCall(() => _dio.get<Map<String, dynamic>>('/api/stats/exercises/$exerciseId'));
    return ExerciseProgress.fromJson(response.data!);
  }

  Future<SessionComparison> getComparison(String sessionId) async {
    final response = await apiCall(
      () => _dio.get<Map<String, dynamic>>('/api/stats/sessions/$sessionId/comparison'),
    );
    return SessionComparison.fromJson(response.data!);
  }

  Future<List<BodyWeightEntry>> getBodyWeightHistory() async {
    final response = await apiCall(() => _dio.get<List<dynamic>>('/api/body-weight'));
    return [
      for (final json in response.data!) BodyWeightEntry.fromJson(json as Map<String, dynamic>),
    ];
  }
}
