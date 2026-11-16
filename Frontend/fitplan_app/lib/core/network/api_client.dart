import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/application/auth_controller.dart';
import '../config/env.dart';
import 'api_exception.dart';
import 'slow_requests.dart';

/// The one HTTP client of the app.
///
/// - adds the `Authorization: Bearer <token>` header to every request when logged in
/// - turns every error into an [ApiException]
/// - logs the user out when the server says the token is no longer valid (401)
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: Env.apiBaseUrl,
      connectTimeout: connectTimeout,
      // longer than the API waits for a waking database (up to 60 s, then about 20 s of retries), so it
      // ends in an answer instead of a timeout
      receiveTimeout: receiveTimeout,
      headers: {'Accept': 'application/json'},
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        // read at request time, so it always uses the current session
        final token = ref.read(authControllerProvider).value?.accessToken;
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        options.extra[_endTracking] = ref.read(slowRequestsProvider.notifier).track();
        handler.next(options);
      },
      onResponse: (response, handler) {
        _stopTracking(response.requestOptions);
        handler.next(response);
      },
      onError: (error, handler) {
        _stopTracking(error.requestOptions);
        final hadToken = error.requestOptions.headers.containsKey('Authorization');
        if (error.response?.statusCode == 401 && hadToken) {
          // expired or invalid token -> back to the login screen
          ref.read(authControllerProvider.notifier).logout();
        }

        handler.reject(
          DioException(
            requestOptions: error.requestOptions,
            response: error.response,
            type: error.type,
            error: ApiException.fromDio(error),
          ),
        );
      },
    ),
  );

  return dio;
});

const connectTimeout = Duration(seconds: 15);
const receiveTimeout = Duration(seconds: 90);

const _endTracking = 'fitplan.endSlowTracking';

void _stopTracking(RequestOptions options) {
  final end = options.extra.remove(_endTracking);
  if (end is void Function()) end();
}

/// Small helper so repositories can write:  `await apiCall(() => dio.get(...))`
/// and get an [ApiException] instead of a raw DioException.
Future<T> apiCall<T>(Future<T> Function() request) async {
  try {
    return await request();
  } on DioException catch (error) {
    final inner = error.error;
    throw inner is ApiException ? inner : ApiException.fromDio(error);
  }
}
