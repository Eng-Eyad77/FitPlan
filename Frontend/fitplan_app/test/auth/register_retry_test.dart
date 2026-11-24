import 'package:dio/dio.dart';
import 'package:fitplan_app/core/network/api_exception.dart';
import 'package:fitplan_app/core/storage/session_storage.dart';
import 'package:fitplan_app/features/auth/application/auth_controller.dart';
import 'package:fitplan_app/features/auth/data/auth_repository.dart';
import 'package:fitplan_app/features/auth/domain/auth_session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

const _session = AuthSession(id: '1', username: 'eyad1234', accessToken: 'token');

const _timeout = ApiException(code: ApiException.timeout, message: 'took too long');
const _taken = ApiException(code: ApiException.usernameAlreadyExists, message: 'taken', statusCode: 409);
const _wrongPassword = ApiException(code: 'InvalidCredentials', message: 'wrong', statusCode: 401);
const _invalid = ApiException(code: 'ValidationFailed', message: 'invalid', statusCode: 400);

/// Answers from a list, and counts the calls, so no test can repeat a sign-up unseen.
class _FakeRepository extends AuthRepository {
  _FakeRepository({required this.registerResult, required this.loginResult}) : super(Dio());

  final Object registerResult;
  final Object loginResult;
  int registerCalls = 0;
  int loginCalls = 0;

  @override
  Future<AuthSession> register({
    required String email,
    required String code,
    required String username,
    required String password,
  }) async {
    registerCalls++;
    return _answer(registerResult);
  }

  @override
  Future<AuthSession> login({required String login, required String password}) async {
    loginCalls++;
    return _answer(loginResult);
  }

  static AuthSession _answer(Object result) => result is AuthSession ? result : throw result;
}

class _MemoryStorage extends SessionStorage {
  _MemoryStorage() : super(const FlutterSecureStorage());

  AuthSession? saved;

  @override
  Future<AuthSession?> read() async => saved;

  @override
  Future<void> save(AuthSession session) async => saved = session;

  @override
  Future<void> clear() async => saved = null;
}

Future<(ProviderContainer, _FakeRepository)> _setUp({
  required Object registerResult,
  Object loginResult = _wrongPassword,
}) async {
  final repository = _FakeRepository(registerResult: registerResult, loginResult: loginResult);
  final container = ProviderContainer(overrides: [
    authRepositoryProvider.overrideWithValue(repository),
    sessionStorageProvider.overrideWithValue(_MemoryStorage()),
  ]);
  addTearDown(container.dispose);
  await container.read(authControllerProvider.future);
  return (container, repository);
}

Future<void> _register(ProviderContainer container) =>
    container.read(authControllerProvider.notifier)
        .register(email: 'eyad@example.test', code: '123456', username: 'eyad1234', password: 'eyad1234');

void main() {
  test('a normal sign-up logs in once, without an extra login', () async {
    final (container, repository) = await _setUp(registerResult: _session);

    await _register(container);

    expect(container.read(authControllerProvider).value, _session);
    expect((repository.registerCalls, repository.loginCalls), (1, 0));
  });

  test('a sign-up that timed out but was created logs in instead of failing', () async {
    final (container, repository) = await _setUp(registerResult: _timeout, loginResult: _session);

    await _register(container);

    expect(container.read(authControllerProvider).value, _session);
    expect((repository.registerCalls, repository.loginCalls), (1, 1));
  });

  test('"username taken" for our own earlier sign-up logs in', () async {
    final (container, repository) = await _setUp(registerResult: _taken, loginResult: _session);

    await _register(container);

    expect(container.read(authControllerProvider).value, _session);
    expect(repository.registerCalls, 1);
  });

  test("a name taken by someone else still says it's taken", () async {
    final (container, repository) = await _setUp(registerResult: _taken);

    await expectLater(_register(container), throwsA(_taken));
    expect(container.read(authControllerProvider).value, isNull);
    expect((repository.registerCalls, repository.loginCalls), (1, 1));
  });

  test('a timeout with no account created reports the timeout', () async {
    final (container, repository) = await _setUp(registerResult: _timeout);

    await expectLater(_register(container), throwsA(_timeout));
    expect(repository.registerCalls, 1);
  });

  test('other errors fail straight away, without trying to log in', () async {
    final (container, repository) = await _setUp(registerResult: _invalid, loginResult: _session);

    await expectLater(_register(container), throwsA(_invalid));
    expect((repository.registerCalls, repository.loginCalls), (1, 0));
  });
}
