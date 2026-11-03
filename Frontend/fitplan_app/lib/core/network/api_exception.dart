import 'package:dio/dio.dart';

/// Every failed API call becomes an [ApiException].
///
/// The backend always answers errors as ProblemDetails:
/// { "status": 404, "title": "Workout plan not found.", "errorCode": "WorkoutPlanNotFound",
///   "errors": { "Password": ["..."] } }   <- "errors" only for validation failures
class ApiException implements Exception {
  const ApiException({
    required this.code,
    required this.message,
    this.statusCode,
    this.fieldErrors = const {},
  });

  /// Stable identifier to switch on, e.g. "InvalidCredentials", "NetworkError".
  final String code;

  /// Human readable text from the server (or ours for network problems).
  final String message;

  final int? statusCode;

  /// Validation errors per field, keys in lower camel case ("password", "username").
  final Map<String, List<String>> fieldErrors;

  static const networkError = 'NetworkError';
  static const unknownError = 'UnknownError';

  factory ApiException.fromDio(DioException error) {
    final response = error.response;

    if (response == null) {
      return const ApiException(
        code: networkError,
        message: "Can't reach the server. Check your connection and try again.",
      );
    }

    final data = response.data;
    if (data is Map<String, dynamic>) {
      return ApiException(
        code: data['errorCode'] as String? ?? unknownError,
        message: data['title'] as String? ?? 'Something went wrong.',
        statusCode: response.statusCode,
        fieldErrors: _parseFieldErrors(data['errors']),
      );
    }

    return ApiException(
      code: unknownError,
      message: 'Something went wrong.',
      statusCode: response.statusCode,
    );
  }

  static Map<String, List<String>> _parseFieldErrors(Object? raw) {
    if (raw is! Map) return const {};
    return {
      for (final entry in raw.entries)
        _lowerFirst(entry.key.toString()):
            (entry.value as List).map((message) => message.toString()).toList(),
    };
  }

  static String _lowerFirst(String value) =>
      value.isEmpty ? value : value[0].toLowerCase() + value.substring(1);

  /// The first validation message for a field, if any.
  String? fieldError(String field) => fieldErrors[field]?.first;

  @override
  String toString() => 'ApiException($code, $statusCode): $message';
}
