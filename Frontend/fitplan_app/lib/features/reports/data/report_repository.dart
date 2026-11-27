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

  /// [suggestion]: an idea for the app instead of a problem; same endpoint, titled differently on Telegram.
  Future<void> send(String message, {bool suggestion = false}) => apiCall(() => _dio.post<void>('/api/reports', data: {
        'message': message.trim(),
        'isSuggestion': suggestion,
        'appVersion': Env.appVersion,
        'platform': kIsWeb ? 'web' : defaultTargetPlatform.name,
      }));
}
