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

  Future<AuthSession> login({required String username, required String password}) =>
      _authenticate('/api/auth/login', username, password);

  Future<AuthSession> register({required String username, required String password}) =>
      _authenticate('/api/auth/register', username, password);

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

  Future<AuthSession> _authenticate(String path, String username, String password) async {
    final response = await apiCall(
      () => _dio.post<Map<String, dynamic>>(
        path,
        data: {'username': username.trim(), 'password': password},
      ),
    );
    return AuthSession.fromJson(response.data!);
  }
}
