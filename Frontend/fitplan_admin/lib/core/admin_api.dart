import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'env.dart';

class AdminSession {
  const AdminSession({required this.username, required this.role, required this.accessToken, required this.expiresAt});

  final String username;
  final String role;
  final String accessToken;
  final DateTime expiresAt;
}

class AuditEntry {
  const AuditEntry({required this.adminName, required this.action, required this.target, required this.createdAt});

  factory AuditEntry.fromJson(Map<String, dynamic> json) => AuditEntry(
        adminName: json['adminName'] as String,
        action: json['action'] as String,
        target: json['target'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
      );

  final String adminName;
  final String action;
  final String? target;
  final DateTime createdAt;
}

class AuditPage {
  const AuditPage({required this.items, required this.page, required this.totalPages});

  final List<AuditEntry> items;
  final int page;
  final int totalPages;
}

/// A failed call, with a sentence to show.
class AdminApiException implements Exception {
  const AdminApiException(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => message;
}

/// Every call the admin makes. The session lives only in memory: reloading the page or closing the
/// tab signs out, and the server ends it after an hour anyway.
// shortcut: a reload asks for a new code; keep the token in sessionStorage (package:web) if that gets annoying
class AdminApi {
  AdminApi({Dio? dio}) : _dio = dio ?? Dio(BaseOptions(baseUrl: Env.apiBaseUrl)) {
    _dio.options
      ..connectTimeout = const Duration(seconds: 15)
      // the free database can take up to a minute to wake
      ..receiveTimeout = const Duration(seconds: 90)
      ..headers['Accept'] = 'application/json';
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = session.value?.accessToken;
        if (token != null) options.headers['Authorization'] = 'Bearer $token';
        handler.next(options);
      },
      onError: (error, handler) {
        // the hour is up, or the admin was removed: back to sign-in
        if (error.response?.statusCode == 401 && session.value != null) session.value = null;
        handler.next(error);
      },
    ));
  }

  final Dio _dio;

  /// null when signed out. The router listens to it.
  final session = ValueNotifier<AdminSession?>(null);

  Future<void> signIn({required String login, required String password, required String code}) async {
    final json = await _call(() => _dio.post<Map<String, dynamic>>(
          '/api/admin/auth/login',
          data: {'login': login, 'password': password, 'code': code},
        ));
    session.value = AdminSession(
      username: json['username'] as String,
      role: json['role'] as String,
      accessToken: json['accessToken'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String).toLocal(),
    );
  }

  void signOut() => session.value = null;

  Future<AuditPage> audit({int page = 1}) async {
    final json = await _call(() => _dio.get<Map<String, dynamic>>('/api/admin/audit', queryParameters: {'page': page}));
    return AuditPage(
      items: [for (final item in json['items'] as List) AuditEntry.fromJson(item as Map<String, dynamic>)],
      page: json['page'] as int,
      totalPages: json['totalPages'] as int,
    );
  }

  Future<Map<String, dynamic>> _call(Future<Response<Map<String, dynamic>>> Function() request) async {
    try {
      return (await request()).data!;
    } on DioException catch (error) {
      throw describe(error.response?.statusCode, error.response?.data);
    }
  }

  @visibleForTesting
  static AdminApiException describe(int? status, Object? body) {
    final code = body is Map && body['errorCode'] is String ? body['errorCode'] as String : 'Http$status';
    return switch ((code, status)) {
      ('InvalidAdminSignIn', _) => const AdminApiException('InvalidAdminSignIn', 'The sign-in details or the code are wrong.'),
      (_, 429) => const AdminApiException('TooManyRequests', 'Too many tries. Wait a minute and try again.'),
      (_, 401) => const AdminApiException('SignedOut', 'Your admin session ended. Sign in again.'),
      (_, 403) => const AdminApiException('Forbidden', "This account can't do that."),
      (_, null) => const AdminApiException('NetworkError', "Can't reach the server. Check the connection and try again."),
      _ => AdminApiException(
          code, body is Map && body['title'] is String ? body['title'] as String : 'Something went wrong ($status).'),
    };
  }
}
