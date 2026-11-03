import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../domain/auth_session.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.watch(dioProvider)),
);

/// Talks to /api/auth. Throws ApiException on failure.
class AuthRepository {
  AuthRepository(this._dio);

  final Dio _dio;

  Future<AuthSession> login({required String username, required String password}) =>
      _authenticate('/api/auth/login', username, password);

  Future<AuthSession> register({required String username, required String password}) =>
      _authenticate('/api/auth/register', username, password);

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
