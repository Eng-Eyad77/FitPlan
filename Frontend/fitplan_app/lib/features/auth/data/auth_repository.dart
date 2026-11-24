import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../domain/auth_session.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.watch(authDioProvider)),
);

/// Talks to /api/auth. Throws ApiException on failure.
class AuthRepository {
  AuthRepository(this._dio);

  final Dio _dio;

  /// [login] is the email or the username (D18).
  Future<AuthSession> login({required String login, required String password}) =>
      _authenticate('/api/auth/login', {'login': login.trim(), 'password': password});

  /// Sign-up step 1. The server answers the same for a registered email, which gets a notice instead.
  Future<void> sendSignUpCode(String email) =>
      apiCall(() => _dio.post<void>('/api/auth/register/code', data: {'email': email.trim()}));

  /// Sign-up step 2. Throws ApiException "InvalidEmailCode" when the code is wrong or expired.
  Future<AuthSession> register({
    required String email,
    required String code,
    required String username,
    required String password,
  }) =>
      _authenticate('/api/auth/register', {
        'email': email.trim(),
        'code': code.trim(),
        'username': username.trim(),
        'password': password,
      });

  /// A forgotten password, step 1. An unknown email gets no email, but the same answer.
  Future<void> sendPasswordResetCode(String email) =>
      apiCall(() => _dio.post<void>('/api/auth/password-reset/code', data: {'email': email.trim()}));

  /// Step 2: is the code right? Throws ApiException (InvalidEmailCode) if not; nothing is used up.
  Future<void> checkPasswordResetCode({required String email, required String code}) => apiCall(() => _dio
      .post<void>('/api/auth/password-reset/check', data: {'email': email.trim(), 'code': code.trim()}));

  /// Step 3: signs in with the new password; every other login ends.
  Future<AuthSession> resetPassword({required String email, required String code, required String newPassword}) =>
      _authenticate('/api/auth/reset-password', {
        'email': email.trim(),
        'code': code.trim(),
        'newPassword': newPassword,
      });

  /// Swaps the refresh token for a new session. A 401 means the session has ended.
  Future<AuthSession> refresh(String refreshToken) =>
      _authenticate('/api/auth/refresh', {'refreshToken': refreshToken});

  /// Ends the login on the server too, so the refresh token can't be used again.
  Future<void> logout(String refreshToken) =>
      apiCall(() => _dio.post<void>('/api/auth/logout', data: {'refreshToken': refreshToken}));

  Future<AuthSession> _authenticate(String path, Map<String, String> body) async {
    final response = await apiCall(() => _dio.post<Map<String, dynamic>>(path, data: body));
    return AuthSession.fromJson(response.data!);
  }
}
