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

class UserRow {
  const UserRow({
    required this.id,
    required this.username,
    required this.email,
    required this.createdAt,
    required this.lastWorkoutAt,
    required this.disabled,
    required this.isAdmin,
  });

  factory UserRow.fromJson(Map<String, dynamic> json) => UserRow(
        id: json['id'] as String,
        username: json['username'] as String,
        email: json['email'] as String,
        createdAt: _date(json['createdAt'])!,
        lastWorkoutAt: _date(json['lastWorkoutAt']),
        disabled: json['disabled'] as bool,
        isAdmin: json['isAdmin'] as bool,
      );

  final String id;
  final String username;

  /// masked, such as s***@gmail.com
  final String email;
  final DateTime createdAt;
  final DateTime? lastWorkoutAt;
  final bool disabled;
  final bool isAdmin;
}

class UserPage {
  const UserPage({required this.items, required this.page, required this.totalPages, required this.totalCount});

  final List<UserRow> items;
  final int page;
  final int totalPages;
  final int totalCount;
}

class UserDetail {
  const UserDetail({
    required this.id,
    required this.username,
    required this.email,
    required this.createdAt,
    required this.disabledAt,
    required this.isAdmin,
    required this.workouts,
    required this.plans,
    required this.signedInDevices,
    required this.reports,
    required this.lastWorkoutAt,
  });

  factory UserDetail.fromJson(Map<String, dynamic> json) => UserDetail(
        id: json['id'] as String,
        username: json['username'] as String,
        email: json['email'] as String,
        createdAt: _date(json['createdAt'])!,
        disabledAt: _date(json['disabledAt']),
        isAdmin: json['isAdmin'] as bool,
        workouts: json['workouts'] as int,
        plans: json['plans'] as int,
        signedInDevices: json['signedInDevices'] as int,
        reports: json['reports'] as int,
        lastWorkoutAt: _date(json['lastWorkoutAt']),
      );

  final String id;
  final String username;
  final String email;
  final DateTime createdAt;
  final DateTime? disabledAt;
  final bool isAdmin;
  final int workouts;
  final int plans;
  final int signedInDevices;
  final int reports;
  final DateTime? lastWorkoutAt;
}

DateTime? _date(Object? value) => value == null ? null : DateTime.parse(value as String).toLocal();

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

  // 12B: users and accounts
  Future<UserPage> users({String search = '', String status = 'all', int page = 1}) async {
    final json = await _call(() => _dio.get<Map<String, dynamic>>(
          '/api/admin/users',
          queryParameters: {if (search.isNotEmpty) 'search': search, 'status': status, 'page': page},
        ));
    return UserPage(
      items: [for (final item in json['items'] as List) UserRow.fromJson(item as Map<String, dynamic>)],
      page: json['page'] as int,
      totalPages: json['totalPages'] as int,
      totalCount: json['totalCount'] as int,
    );
  }

  Future<UserDetail> user(String id) async =>
      UserDetail.fromJson(await _call(() => _dio.get<Map<String, dynamic>>('/api/admin/users/$id')));

  /// The full address. The server writes it to the audit log.
  Future<String> revealEmail(String id) async =>
      (await _call(() => _dio.post<Map<String, dynamic>>('/api/admin/users/$id/reveal-email')))['email'] as String;

  /// disable, enable or end-sessions
  Future<void> userAction(String id, String action) => _send(() => _dio.post<void>('/api/admin/users/$id/$action'));

  Future<void> deleteUser(String id, String typedUsername) =>
      _send(() => _dio.post<void>('/api/admin/users/$id/delete', data: {'username': typedUsername}));

  Future<void> _send(Future<Response<void>> Function() request) async {
    try {
      await request();
    } on DioException catch (error) {
      throw describe(error.response?.statusCode, error.response?.data);
    }
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
