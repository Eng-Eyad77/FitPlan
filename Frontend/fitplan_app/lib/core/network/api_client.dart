import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/application/auth_controller.dart';
import '../config/env.dart';
import 'api_exception.dart';
import 'slow_requests.dart';

/// The HTTP client for everything except /api/auth.
///
/// - adds the `Authorization: Bearer <token>` header to every request when logged in
/// - turns every error into an [ApiException]
/// - on 401, renews the session once with the refresh token and repeats the request once.
///   Requests that fail together share one renewal. Only a refused renewal logs the user out;
///   no connection keeps them logged in.
final dioProvider = Provider<Dio>((ref) => _createDio(ref, withSession: true));

/// The HTTP client for /api/auth: no session header, and a 401 there (wrong password, ended
/// session) is an answer for the caller, never a reason to renew or log out by itself.
final authDioProvider = Provider<Dio>((ref) => _createDio(ref, withSession: false));

Dio _createDio(Ref ref, {required bool withSession}) {
  late final Dio dio;
  dio = Dio(
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
        final token = withSession ? ref.read(authControllerProvider).value?.accessToken : null;
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
          options.extra[_sentToken] = token;
        }
        options.extra[_endTracking] = ref.read(slowRequestsProvider.notifier).track();
        handler.next(options);
      },
      onResponse: (response, handler) {
        _stopTracking(response.requestOptions);
        handler.next(response);
      },
      onError: (error, handler) async {
        final options = error.requestOptions;
        _stopTracking(options);
        final sentToken = options.extra[_sentToken];

        if (error.response?.statusCode == 401 && sentToken is String) {
          final auth = ref.read(authControllerProvider.notifier);
          if (options.extra[_retried] == true) {
            // a brand-new token was refused too: nothing more to try
            await auth.logout();
          } else {
            try {
              if (await auth.renewAfterUnauthorized(sentToken) != null) {
                options.extra[_retried] = true;
                return handler.resolve(await dio.fetch<dynamic>(options));
              }
            } on DioException catch (retryError) {
              return handler.reject(retryError);
            } on ApiException catch (renewError) {
              // couldn't reach the server to renew: still logged in, and the screen says why
              return handler.reject(_wrap(error, renewError));
            }
          }
        }

        handler.reject(_wrap(error, ApiException.fromDio(error)));
      },
    ),
  );

  return dio;
}

DioException _wrap(DioException error, ApiException apiError) => DioException(
      requestOptions: error.requestOptions,
      response: error.response,
      type: error.type,
      error: apiError,
    );

const connectTimeout = Duration(seconds: 15);
const receiveTimeout = Duration(seconds: 90);

const _endTracking = 'fitplan.endSlowTracking';
const _sentToken = 'fitplan.sentToken';
const _retried = 'fitplan.retriedAfterRenewal';

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
