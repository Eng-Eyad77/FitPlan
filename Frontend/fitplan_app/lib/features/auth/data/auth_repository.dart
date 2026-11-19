import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../domain/auth_session.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.watch(authDioProvider)),
);

/// A new session, and a recovery code to show when the server sent one.
typedef AuthResult = ({AuthSession session, String? recoveryCode});

/// Talks to /api/auth. Throws ApiException on failure.
class AuthRepository {
  AuthRepository(this._dio);

  final Dio _dio;

  Future<AuthSession> login({required String username, required String password}) async =>
      (await _authenticate('/api/auth/login', {'username': username.trim(), 'password': password})).session;

  /// Also returns the account's first recovery code, shown to the user once.
  Future<AuthResult> register({required String username, required String password}) =>
      _authenticate('/api/auth/register', {'username': username.trim(), 'password': password});

  /// A forgotten password, proved with the recovery code. Returns the new session and a new code;
  /// the used code stops working. Throws ApiException "InvalidRecoveryCode" when it doesn't match.
  Future<AuthResult> resetPassword({
    required String username,
    required String recoveryCode,
    required String newPassword,
  }) =>
      _authenticate('/api/auth/reset-password', {
        'username': username.trim(),
        'recoveryCode': recoveryCode,
        'newPassword': newPassword,
      });

  /// Swaps the refresh token for a new session. A 401 means the session has ended.
  Future<AuthSession> refresh(String refreshToken) async {
    final response = await apiCall(
      () => _dio.post<Map<String, dynamic>>('/api/auth/refresh', data: {'refreshToken': refreshToken}),
    );
    return AuthSession.fromJson(response.data!);
  }

  /// Ends the login on the server too, so the refresh token can't be used again.
  Future<void> logout(String refreshToken) =>
      apiCall(() => _dio.post<void>('/api/auth/logout', data: {'refreshToken': refreshToken}));

  Future<AuthResult> _authenticate(String path, Map<String, String> body) async {
    final response = await apiCall(() => _dio.post<Map<String, dynamic>>(path, data: body));
    final data = response.data!;
    // the recovery code is never part of the saved session
    return (session: AuthSession.fromJson(data), recoveryCode: data['recoveryCode'] as String?);
  }
}
