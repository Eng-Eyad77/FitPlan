import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/env.dart';
import '../../../core/network/api_client.dart';

final reportRepositoryProvider = Provider<ReportRepository>(
  (ref) => ReportRepository(ref.watch(dioProvider)),
);

/// POST /api/reports (D14). The app version and platform go with every report, so the user
/// doesn't have to type them. Throws ApiException on failure.
class ReportRepository {
  ReportRepository(this._dio);

  final Dio _dio;

  Future<void> send(String message) => apiCall(() => _dio.post<void>('/api/reports', data: {
        'message': message.trim(),
        'appVersion': Env.appVersion,
        'platform': kIsWeb ? 'web' : defaultTargetPlatform.name,
      }));
}
