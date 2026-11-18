import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fitplan_app/core/network/api_client.dart';
import 'package:fitplan_app/core/network/api_exception.dart';
import 'package:fitplan_app/core/storage/session_storage.dart';
import 'package:fitplan_app/features/auth/application/auth_controller.dart';
import 'package:fitplan_app/features/auth/data/auth_repository.dart';
import 'package:fitplan_app/features/auth/domain/auth_session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

/// A JWT the app can read the expiry of. The signature is never checked on the device.
String _jwt(Duration fromNow, {String tag = ''}) {
  String part(Map<String, dynamic> json) => base64Url.encode(utf8.encode(jsonEncode(json))).replaceAll('=', '');
  final exp = DateTime.now().add(fromNow).millisecondsSinceEpoch ~/ 1000;
  return '${part({'alg': 'HS512'})}.${part({'exp': exp, 'tag': tag})}.sig';
}

AuthSession _session(String tag, {Duration life = const Duration(minutes: 30), String? refresh = 'refresh'}) =>
    AuthSession(id: '1', username: 'eyad1234', accessToken: _jwt(life, tag: tag), refreshToken: refresh);

const _ended = ApiException(code: 'InvalidRefreshToken', message: 'ended', statusCode: 401);
const _offline = ApiException(code: ApiException.networkError, message: 'offline');

class _FakeRepository extends AuthRepository {
  _FakeRepository() : super(Dio());

  /// What /refresh answers: an [AuthSession], an [ApiException], or a [Completer] to answer later.
  Object refreshResult = _ended;
  int refreshCalls = 0;
  final loggedOut = <String>[];

  @override
  Future<AuthSession> refresh(String refreshToken) async {
    refreshCalls++;
    final result = refreshResult;
    if (result is Completer<AuthSession>) return result.future;
    return result is AuthSession ? result : throw result;
  }

  @override
  Future<void> logout(String refreshToken) async => loggedOut.add(refreshToken);
}

class _MemoryStorage extends SessionStorage {
  _MemoryStorage(this.saved) : super(const FlutterSecureStorage());

  AuthSession? saved;

  @override
  Future<AuthSession?> read() async => saved;

  @override
  Future<void> save(AuthSession session) async => saved = session;

  @override
  Future<void> clear() async => saved = null;
}

/// Answers 401 to any token except [validToken], and 200 to that one. Records each Authorization.
class _FakeServer implements HttpClientAdapter {
  String validToken = '';
  final seen = <String?>[];

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<List<int>>? requestStream, Future<void>? cancelFuture) async {
    final header = options.headers['Authorization'] as String?;
    seen.add(header);
    final ok = header == 'Bearer $validToken';
    return ResponseBody.fromString(
      ok ? '{"ok":true}' : '{"status":401,"errorCode":"Unauthorized","title":"Unauthorized"}',
      ok ? 200 : 401,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Future<(ProviderContainer, _FakeRepository, _MemoryStorage)> _start(AuthSession? saved, {Object? refreshAtStart}) async {
  final repository = _FakeRepository();
  if (refreshAtStart != null) repository.refreshResult = refreshAtStart;
  final storage = _MemoryStorage(saved);
  final container = ProviderContainer(overrides: [
    authRepositoryProvider.overrideWithValue(repository),
    sessionStorageProvider.overrideWithValue(storage),
  ]);
  addTearDown(container.dispose);
  await container.read(authControllerProvider.future);
  return (container, repository, storage);
}

void main() {
  group('on app start', () {
    test('a session that is still valid is used without renewing', () async {
      final saved = _session('a');
      final (container, repository, _) = await _start(saved);

      expect(container.read(authControllerProvider).value, saved);
      expect(repository.refreshCalls, 0);
    });

    test('an expired session is renewed instead of logging out', () async {
      final renewed = _session('b');
      final (container, _, storage) = await _start(_session('a', life: const Duration(minutes: -1)), refreshAtStart: renewed);

      expect(container.read(authControllerProvider).value, renewed);
      expect(storage.saved, renewed);
    });

    test('a refused renewal logs out', () async {
      final (container, _, storage) = await _start(_session('a', life: const Duration(minutes: -1)), refreshAtStart: _ended);

      expect(container.read(authControllerProvider).value, isNull);
      expect(storage.saved, isNull);
    });

    test('no connection keeps the user logged in', () async {
      final saved = _session('a', life: const Duration(minutes: -1));
      final (container, _, storage) = await _start(saved, refreshAtStart: _offline);

      expect(container.read(authControllerProvider).value, saved);
      expect(storage.saved, saved);
    });

    test('an expired session from an older app version, without a refresh token, logs out', () async {
      final (container, repository, _) = await _start(_session('a', life: const Duration(minutes: -1), refresh: null));

      expect(container.read(authControllerProvider).value, isNull);
      expect(repository.refreshCalls, 0);
    });
  });

  group('after a 401', () {
    test('requests that fail together share one renewal', () async {
      final first = _session('a');
      final (container, repository, _) = await _start(first);
      final pending = Completer<AuthSession>();
      repository.refreshResult = pending;
      final auth = container.read(authControllerProvider.notifier);

      final calls = List.generate(3, (_) => auth.renewAfterUnauthorized(first.accessToken));
      final renewed = _session('b');
      pending.complete(renewed);

      expect(await Future.wait(calls), [renewed, renewed, renewed]);
      expect(repository.refreshCalls, 1);
    });

    test('a request sent with an older token uses the new one without renewing again', () async {
      final current = _session('b');
      final (container, repository, _) = await _start(current);

      final result = await container.read(authControllerProvider.notifier).renewAfterUnauthorized(_jwt(Duration.zero, tag: 'old'));

      expect(result, current);
      expect(repository.refreshCalls, 0);
    });

    test('no connection while renewing keeps the user logged in and says why', () async {
      final first = _session('a');
      final (container, repository, _) = await _start(first);
      repository.refreshResult = _offline;

      await expectLater(
        container.read(authControllerProvider.notifier).renewAfterUnauthorized(first.accessToken),
        throwsA(isA<ApiException>().having((e) => e.code, 'code', ApiException.networkError)),
      );
      expect(container.read(authControllerProvider).value, first);
    });

    test('the client renews once and repeats each failed request once', () async {
      final first = _session('a');
      final renewed = _session('b');
      final (container, repository, _) = await _start(first);
      repository.refreshResult = renewed;
      final server = _FakeServer()..validToken = renewed.accessToken;
      final dio = container.read(dioProvider)..httpClientAdapter = server;

      final responses = await Future.wait([dio.get<dynamic>('/a'), dio.get<dynamic>('/b'), dio.get<dynamic>('/c')]);

      expect(responses.map((r) => r.statusCode), [200, 200, 200]);
      expect(repository.refreshCalls, 1);
      expect(server.seen.where((h) => h == 'Bearer ${first.accessToken}'), hasLength(3));
      expect(server.seen.where((h) => h == 'Bearer ${renewed.accessToken}'), hasLength(3));
      expect(container.read(authControllerProvider).value, renewed);
    });

    test('when even the new token is refused, the user is logged out and nothing loops', () async {
      final first = _session('a');
      final (container, repository, _) = await _start(first);
      repository.refreshResult = _session('b');
      final server = _FakeServer()..validToken = 'never';
      final dio = container.read(dioProvider)..httpClientAdapter = server;

      await expectLater(dio.get<dynamic>('/a'), throwsA(isA<DioException>()));

      expect(server.seen, hasLength(2));
      expect(container.read(authControllerProvider).value, isNull);
    });
  });

  test('logout ends the session here at once and tells the server', () async {
    final (container, repository, storage) = await _start(_session('a', refresh: 'r-1'));

    await container.read(authControllerProvider.notifier).logout();

    expect(container.read(authControllerProvider).value, isNull);
    expect(storage.saved, isNull);
    await Future<void>.delayed(Duration.zero);
    expect(repository.loggedOut, ['r-1']);
  });
}
