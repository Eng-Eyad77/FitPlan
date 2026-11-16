import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fitplan_app/core/network/api_exception.dart';
import 'package:fitplan_app/features/auth/domain/auth_session.dart';
import 'package:flutter_test/flutter_test.dart';

DioException _dioError({int? status, Object? data}) {
  final options = RequestOptions(path: '/test');
  return DioException(
    requestOptions: options,
    response: status == null ? null : Response(requestOptions: options, statusCode: status, data: data),
  );
}

String _jwtExpiringAt(DateTime time) {
  String part(Map<String, dynamic> json) =>
      base64Url.encode(utf8.encode(jsonEncode(json))).replaceAll('=', '');
  return '${part({'alg': 'HS512'})}.${part({'exp': time.millisecondsSinceEpoch ~/ 1000})}.signature';
}

void main() {
  group('ApiException.fromDio', () {
    test('reads errorCode and title from a ProblemDetails body', () {
      final error = ApiException.fromDio(_dioError(status: 401, data: {
        'status': 401,
        'title': 'Invalid username or password.',
        'errorCode': 'InvalidCredentials',
      }));

      expect(error.code, 'InvalidCredentials');
      expect(error.message, 'Invalid username or password.');
      expect(error.statusCode, 401);
    });

    test('reads validation errors with lower camel case field names', () {
      final error = ApiException.fromDio(_dioError(status: 400, data: {
        'title': 'One or more validation errors occurred.',
        'errorCode': 'ValidationFailed',
        'errors': {
          'Password': ['The field Password must be a string with a minimum length of 8.'],
        },
      }));

      expect(error.code, 'ValidationFailed');
      expect(error.fieldError('password'), contains('minimum length of 8'));
    });

    test('no response means a network error', () {
      final error = ApiException.fromDio(_dioError());
      expect(error.code, ApiException.networkError);
      expect(error.isTemporary, isTrue);
    });

    for (final type in [
      DioExceptionType.connectionTimeout,
      DioExceptionType.sendTimeout,
      DioExceptionType.receiveTimeout,
    ]) {
      test('$type is a timeout, not a network error', () {
        final error = ApiException.fromDio(
          DioException(requestOptions: RequestOptions(path: '/test'), type: type),
        );
        expect(error.code, ApiException.timeout);
        expect(error.isTemporary, isTrue);
      });
    }

    test("the API's 503 keeps its DatabaseUnavailable code and message", () {
      final error = ApiException.fromDio(_dioError(status: 503, data: {
        'status': 503,
        'title': 'The server is starting up. Try again in a moment.',
        'errorCode': 'DatabaseUnavailable',
      }));
      expect(error.code, ApiException.databaseUnavailable);
      expect(error.message, 'The server is starting up. Try again in a moment.');
      expect(error.isTemporary, isTrue);
    });

    for (final status in [502, 503, 504]) {
      test('$status without ProblemDetails means the server is starting', () {
        final error = ApiException.fromDio(_dioError(status: status, data: '<html>Service Unavailable</html>'));
        expect(error.code, ApiException.serverUnavailable);
        expect(error.statusCode, status);
      });
    }

    test('a validation error is not temporary', () {
      final error = ApiException.fromDio(_dioError(status: 400, data: {'errorCode': 'ValidationFailed'}));
      expect(error.isTemporary, isFalse);
    });
  });

  group('AuthSession.isExpired', () {
    test('false for a token that expires in the future', () {
      final session = AuthSession(
        id: '1',
        username: 'eyad',
        accessToken: _jwtExpiringAt(DateTime.now().add(const Duration(minutes: 30))),
      );
      expect(session.isExpired, isFalse);
    });

    test('true for an expired token', () {
      final session = AuthSession(
        id: '1',
        username: 'eyad',
        accessToken: _jwtExpiringAt(DateTime.now().subtract(const Duration(minutes: 1))),
      );
      expect(session.isExpired, isTrue);
    });

    test('true for a token that cannot be read', () {
      const session = AuthSession(id: '1', username: 'eyad', accessToken: 'not-a-jwt');
      expect(session.isExpired, isTrue);
    });
  });
}
