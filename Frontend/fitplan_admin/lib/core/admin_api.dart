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

class ExerciseRow {
  const ExerciseRow(
      {required this.id, required this.name, required this.arabicName, required this.bodyPart, required this.hidden, required this.gifStatus});

  factory ExerciseRow.fromJson(Map<String, dynamic> json) => ExerciseRow(
        id: json['id'] as String,
        name: json['name'] as String,
        arabicName: json['arabicName'] as String?,
        bodyPart: json['bodyPart'] as String,
        hidden: json['hidden'] as bool,
        gifStatus: json['gifStatus'] as String?,
      );

  final String id;
  final String name;
  final String? arabicName;
  final String bodyPart;
  final bool hidden;

  /// null until checked
  final String? gifStatus;
}

class ExercisePage {
  const ExercisePage({required this.items, required this.page, required this.totalPages, required this.counts});

  final List<ExerciseRow> items;
  final int page;
  final int totalPages;

  /// all, noDemo, notChecked, hidden
  final Map<String, int> counts;
}

class ExerciseDetail {
  const ExerciseDetail({
    required this.id,
    required this.bodyPart,
    required this.gifUrl,
    required this.gifStatus,
    required this.hidden,
    required this.englishName,
    required this.englishSteps,
    required this.arabicName,
    required this.arabicSteps,
    required this.plans,
    required this.workouts,
  });

  factory ExerciseDetail.fromJson(Map<String, dynamic> json) => ExerciseDetail(
        id: json['id'] as String,
        bodyPart: json['bodyPart'] as String,
        gifUrl: json['gifUrl'] as String,
        gifStatus: json['gifStatus'] as String?,
        hidden: json['hidden'] as bool,
        englishName: json['englishName'] as String,
        englishSteps: [for (final s in json['englishInstructions'] as List) s as String],
        arabicName: json['arabicName'] as String?,
        arabicSteps: [for (final s in (json['arabicInstructions'] as List?) ?? const []) s as String],
        plans: json['plans'] as int,
        workouts: json['workouts'] as int,
      );

  final String id;
  final String bodyPart;
  final String gifUrl;
  final String? gifStatus;
  final bool hidden;
  final String englishName;
  final List<String> englishSteps;
  final String? arabicName;
  final List<String> arabicSteps;
  final int plans;
  final int workouts;
}

/// One exercise of a plan, as the admin sees it (the user's own note is left out).
typedef PlanExercise = ({String name, int sets, int reps, int? restSeconds});

typedef UserPlan = ({String name, DateTime createdAt, List<PlanExercise> exercises});

/// A cardio machine, the details the app records for it, and its entries this month.
typedef CardioMachineRow = ({String machine, List<String> fields, int usesThisMonth});

/// 12E: totals only. "Last 7 days" is rolling and counted in UTC on the server.
class Overview {
  const Overview({
    required this.countedAt,
    required this.users,
    required this.newUsers,
    required this.activeUsers,
    required this.workouts,
    required this.workoutsBefore,
    required this.volumeKg,
    required this.volumeKgBefore,
    required this.cardioThisMonth,
    required this.topCardio,
    required this.openReports,
    required this.noDemo,
    required this.emailsToday,
    required this.emailLimit,
    required this.workoutsPerDay,
    required this.signUpsPerWeek,
    required this.topExercises,
  });

  factory Overview.fromJson(Map<String, dynamic> json) => Overview(
        countedAt: _date(json['countedAt'])!,
        users: json['users'] as int,
        newUsers: json['newUsersLast7Days'] as int,
        activeUsers: json['activeUsersLast7Days'] as int,
        workouts: json['workoutsLast7Days'] as int,
        workoutsBefore: json['workoutsPrevious7Days'] as int,
        volumeKg: (json['volumeKgLast7Days'] as num).toDouble(),
        volumeKgBefore: (json['volumeKgPrevious7Days'] as num).toDouble(),
        cardioThisMonth: json['cardioEntriesThisMonth'] as int,
        topCardio: json['mostUsedCardioMachine'] as String?,
        openReports: json['openReports'] as int,
        noDemo: json['exercisesWithoutDemo'] as int,
        emailsToday: json['emailsToday'] as int,
        emailLimit: json['emailsPerDayLimit'] as int,
        workoutsPerDay: [for (final n in json['workoutsPerDay'] as List) n as int],
        signUpsPerWeek: [for (final n in json['signUpsPerWeek'] as List) n as int],
        topExercises: [
          for (final e in json['mostUsedExercises'] as List) (name: e['name'] as String, workouts: e['workouts'] as int),
        ],
      );

  final DateTime countedAt;
  final int users;
  final int newUsers;
  final int activeUsers;
  final int workouts;
  final int workoutsBefore;
  final double volumeKg;
  final double volumeKgBefore;
  final int cardioThisMonth;
  final String? topCardio;
  final int openReports;
  final int noDemo;
  final int emailsToday;
  final int emailLimit;
  final List<int> workoutsPerDay;
  final List<int> signUpsPerWeek;
  final List<({String name, int workouts})> topExercises;
}

/// 12F: a report from the app. Users are named by username only.
typedef Report = ({
  int id,
  String username,
  String message,
  bool isSuggestion,
  String? platform,
  String? appVersion,
  String language,
  bool sentToTelegram,
  DateTime createdAt,
  DateTime? doneAt,
});

typedef ReportPage = ({List<Report> items, int page, int totalPages, int open, int suggestions, int done});

typedef ApiError = ({DateTime createdAt, String endpoint, String error, String? requestId});

typedef FailedSignIn = ({String account, String reason, int attempts, DateTime lastAt});

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

  // 12C: exercises
  Future<ExercisePage> exercises({String search = '', String filter = 'all', int page = 1}) async {
    final json = await _call(() => _dio.get<Map<String, dynamic>>(
          '/api/admin/exercises',
          queryParameters: {if (search.isNotEmpty) 'search': search, 'filter': filter, 'page': page},
        ));
    final counts = json['counts'] as Map<String, dynamic>;
    return ExercisePage(
      items: [for (final item in json['items'] as List) ExerciseRow.fromJson(item as Map<String, dynamic>)],
      page: json['page'] as int,
      totalPages: json['totalPages'] as int,
      counts: {for (final e in counts.entries) e.key: e.value as int},
    );
  }

  Future<ExerciseDetail> exercise(String id) async =>
      ExerciseDetail.fromJson(await _call(() => _dio.get<Map<String, dynamic>>('/api/admin/exercises/${Uri.encodeComponent(id)}')));

  Future<void> saveExerciseText(String id,
          {required String englishName,
          required List<String> englishSteps,
          required String arabicName,
          required List<String> arabicSteps}) =>
      _send(() => _dio.put<void>('/api/admin/exercises/${Uri.encodeComponent(id)}/text', data: {
            'englishName': englishName,
            'englishInstructions': englishSteps,
            'arabicName': arabicName,
            'arabicInstructions': arabicSteps,
          }));

  Future<void> setExerciseHidden(String id, bool hidden) =>
      _send(() => _dio.post<void>('/api/admin/exercises/${Uri.encodeComponent(id)}/${hidden ? 'hide' : 'show'}'));

  /// The new status: Works, Missing, NotAGif or Unreachable.
  Future<String> checkGif(String id) async =>
      (await _call(() => _dio.post<Map<String, dynamic>>('/api/admin/exercises/${Uri.encodeComponent(id)}/check-gif')))['gifStatus']
          as String;

  /// Checks one batch of links; call again with nextOffset until it reaches total.
  Future<({int nextOffset, int total, int broken})> checkGifBatch(int offset) async {
    final json = await _call(() => _dio.post<Map<String, dynamic>>('/api/admin/exercises/check-gifs', data: {'offset': offset}));
    return (nextOffset: json['nextOffset'] as int, total: json['total'] as int, broken: json['broken'] as int);
  }

  /// Read only. The server writes "Viewed plans" to the audit log.
  Future<({String username, List<UserPlan> plans})> viewPlans(String userId) async {
    final json = await _call(() => _dio.post<Map<String, dynamic>>('/api/admin/users/$userId/view-plans'));
    return (
      username: json['username'] as String,
      plans: [
        for (final p in json['plans'] as List)
          (
            name: p['name'] as String,
            createdAt: _date(p['createdAt'])!,
            exercises: [
              for (final e in p['exercises'] as List)
                (name: e['name'] as String, sets: e['sets'] as int, reps: e['reps'] as int, restSeconds: e['restSeconds'] as int?),
            ],
          ),
      ],
    );
  }

  Future<List<CardioMachineRow>> cardioMachines() async {
    try {
      final rows = (await _dio.get<List<dynamic>>('/api/admin/cardio')).data!;
      return [
        for (final m in rows)
          (machine: m['machine'] as String, fields: [for (final f in m['fields'] as List) f as String], usesThisMonth: m['usesThisMonth'] as int),
      ];
    } on DioException catch (error) {
      throw describe(error.response?.statusCode, error.response?.data);
    }
  }

  /// Kept by the server for 10 minutes; [refresh] counts again.
  Future<Overview> overview({bool refresh = false}) async => Overview.fromJson(
      await _call(() => _dio.get<Map<String, dynamic>>('/api/admin/overview', queryParameters: {'refresh': refresh})));

  /// filter: open, suggestions or done
  Future<ReportPage> reports({String filter = 'open', int page = 1}) async {
    final json = await _call(() => _dio.get<Map<String, dynamic>>('/api/admin/reports', queryParameters: {'filter': filter, 'page': page}));
    final counts = json['counts'] as Map<String, dynamic>;
    return (
      items: [
        for (final r in json['items'] as List)
          (
            id: r['id'] as int,
            username: r['username'] as String,
            message: r['message'] as String,
            isSuggestion: r['isSuggestion'] as bool,
            platform: r['platform'] as String?,
            appVersion: r['appVersion'] as String?,
            language: r['language'] as String,
            sentToTelegram: r['sentToTelegram'] as bool,
            createdAt: _date(r['createdAt'])!,
            doneAt: _date(r['doneAt']),
          ),
      ],
      page: json['page'] as int,
      totalPages: json['totalPages'] as int,
      open: counts['open'] as int,
      suggestions: counts['suggestions'] as int,
      done: counts['done'] as int,
    );
  }

  Future<void> setReportDone(int id, bool done) => _send(() => _dio.post<void>('/api/admin/reports/$id/${done ? 'done' : 'reopen'}'));

  /// The CSV file of every report (no emails). Logged by the server.
  Future<List<int>> exportReports() async {
    try {
      return (await _dio.get<List<int>>('/api/admin/reports/export', options: Options(responseType: ResponseType.bytes))).data!;
    } on DioException catch (error) {
      throw describe(error.response?.statusCode, null);
    }
  }

  /// API errors and failed sign-ins of the last 24 hours.
  Future<({List<ApiError> apiErrors, List<FailedSignIn> failedSignIns})> errors() async {
    final json = await _call(() => _dio.get<Map<String, dynamic>>('/api/admin/errors'));
    return (
      apiErrors: [
        for (final e in json['apiErrors'] as List)
          (createdAt: _date(e['createdAt'])!, endpoint: e['endpoint'] as String, error: e['error'] as String, requestId: e['requestId'] as String?),
      ],
      failedSignIns: [
        for (final f in json['failedSignIns'] as List)
          (account: f['account'] as String, reason: f['reason'] as String, attempts: f['attempts'] as int, lastAt: _date(f['lastAt'])!),
      ],
    );
  }

  /// Outside Production: makes the server fail once, so the error list can be checked. Returns its request ID.
  Future<String?> throwTestError() async {
    try {
      await _dio.post<void>('/api/admin/errors/test');
      return null;
    } on DioException catch (error) {
      final body = error.response?.data;
      if (error.response?.statusCode == 500 && body is Map) return body['traceId'] as String?;
      throw describe(error.response?.statusCode, body);
    }
  }

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
