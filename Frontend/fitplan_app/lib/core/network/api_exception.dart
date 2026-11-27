import 'package:dio/dio.dart';

import '../../l10n/l10n.dart';

/// Every failed API call becomes an [ApiException].
///
/// The backend always answers errors as ProblemDetails:
/// { "status": 404, "title": "Workout plan not found.", "errorCode": "WorkoutPlanNotFound",
///   "errors": { "Password": ["..."] } }   <- "errors" only for validation failures
class ApiException implements Exception {
  const ApiException({
    required this.code,
    required String message,
    this.statusCode,
    this.fieldErrors = const {},
  }) : serverMessage = message;

  /// Stable identifier to switch on, e.g. "InvalidCredentials", "NetworkError".
  final String code;

  /// The server's own English title (or ours for network problems).
  final String serverMessage;

  /// The sentence to show, in the app's language. Known codes have the app's own text, so the
  /// server's English never shows in Arabic (Phase 11).
  String get message => switch (code) {
        'UsernameAlreadyExists' => l10n.errUsernameAlreadyExists,
        'InvalidCredentials' => l10n.errInvalidCredentials,
        'AccountDisabled' => l10n.errAccountDisabled,
        'InvalidRefreshToken' || 'Unauthorized' => l10n.errInvalidRefreshToken,
        'InvalidEmailCode' => l10n.errInvalidEmailCode,
        'EmailAlreadyExists' => l10n.errEmailAlreadyExists,
        'EmailNotRegistered' => l10n.errEmailNotRegistered,
        'TooManyEmails' => l10n.errTooManyEmails,
        'EmailNotSent' => l10n.errEmailNotSent,
        'WrongPassword' => l10n.errWrongPassword,
        'UserNotFound' => l10n.errUserNotFound,
        'InvalidFile' => l10n.errInvalidFile,
        'PictureNotFound' => l10n.errPictureNotFound,
        'FileTooLarge' => l10n.errFileTooLarge,
        'ExerciseNotFound' => l10n.errExerciseNotFound,
        'WorkoutPlanNotFound' => l10n.errWorkoutPlanNotFound,
        'ExerciseAlreadyExists' => l10n.errExerciseAlreadyExists,
        'WorkoutPlanExerciseNotFound' => l10n.errWorkoutPlanExerciseNotFound,
        'WorkoutSessionNotFound' => l10n.errWorkoutSessionNotFound,
        'NoActiveSession' => l10n.errNoActiveSession,
        'ActiveSessionExists' => l10n.errActiveSessionExists,
        'SessionNotActive' => l10n.errSessionNotActive,
        'EmptySession' => l10n.errEmptySession,
        'SessionExerciseNotFound' => l10n.errSessionExerciseNotFound,
        'ExerciseAlreadyInSession' => l10n.errExerciseAlreadyInSession,
        'SetLimitReached' => l10n.errSetLimitReached,
        'SessionSetNotFound' => l10n.errSessionSetNotFound,
        'CardioEntryNotFound' => l10n.errCardioEntryNotFound,
        'CardioMachineRetired' => l10n.errCardioMachineRetired,
        'CardioDistanceTooLong' => l10n.errCardioDistanceTooLong,
        'SessionNotCompleted' => l10n.errSessionNotCompleted,
        'NoExerciseHistory' => l10n.errNoExerciseHistory,
        'BodyWeightEntryNotFound' => l10n.errBodyWeightEntryNotFound,
        'TooManyRequests' => l10n.errTooManyRequests,
        timeout => l10n.errTimeout,
        networkError => l10n.errNetwork,
        serverUnavailable || databaseUnavailable => l10n.errServerStarting,
        // the server's validation text is English; Arabic gets one plain sentence
        'ValidationFailed' when isArabic => l10n.errValidation,
        _ => isArabic ? l10n.errGeneric : serverMessage,
      };

  final int? statusCode;

  /// Validation errors per field, keys in lower camel case ("password", "username").
  final Map<String, List<String>> fieldErrors;

  /// No answer at all: no internet, or the server can't be reached.
  static const networkError = 'NetworkError';

  /// The request left, but no answer came in time. A POST may still have been done by the server.
  static const timeout = 'Timeout';

  /// The server answered that it can't handle requests right now, e.g. while it starts up.
  static const serverUnavailable = 'ServerUnavailable';

  /// The API's own 503: the database is still waking up. Nothing was saved.
  static const databaseUnavailable = 'DatabaseUnavailable';

  static const unknownError = 'UnknownError';

  static const usernameAlreadyExists = 'UsernameAlreadyExists';

  /// True when trying again in a moment is likely to work.
  bool get isTemporary =>
      code == networkError || code == timeout || code == serverUnavailable || code == databaseUnavailable;

  factory ApiException.fromDio(DioException error) {
    final response = error.response;

    if (response == null) {
      return switch (error.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.sendTimeout ||
        DioExceptionType.receiveTimeout =>
          const ApiException(
            code: timeout,
            message: 'The server took too long to answer. Try again in a moment.',
          ),
        _ => const ApiException(
            code: networkError,
            message: "Can't reach the server. Check your connection and try again.",
          ),
      };
    }

    final data = response.data;
    final status = response.statusCode;

    // 502, 503 and 504 without our ProblemDetails come from Azure while the API starts.
    if (status != null && status >= 502 && status <= 504 && data is! Map<String, dynamic>) {
      return ApiException(
        code: serverUnavailable,
        message: 'The server is starting up. Try again in a moment.',
        statusCode: status,
      );
    }

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

  /// The first validation message for a field, if any. The server writes these in English,
  /// so Arabic gets the general sentence instead.
  String? fieldError(String field) {
    final first = fieldErrors[field]?.first;
    return first == null || !isArabic ? first : l10n.errValidation;
  }

  @override
  String toString() => 'ApiException($code, $statusCode): $serverMessage';
}
