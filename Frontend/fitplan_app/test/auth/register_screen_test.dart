import 'package:dio/dio.dart';
import 'package:fitplan_app/core/network/api_exception.dart';
import 'package:fitplan_app/core/storage/session_storage.dart';
import 'package:fitplan_app/features/auth/data/auth_repository.dart';
import 'package:fitplan_app/features/auth/domain/auth_session.dart';
import 'package:fitplan_app/features/auth/presentation/register_screen.dart';
import 'package:fitplan_app/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

const _session = AuthSession(id: '1', username: 'eyad1234', accessToken: 'token');

class _FakeRepository extends AuthRepository {
  _FakeRepository() : super(Dio());

  final codesSentTo = <String>[];
  Map<String, String>? registered;
  Object? registerError;

  @override
  Future<void> sendSignUpCode(String email) async => codesSentTo.add(email);

  // after "username taken" the controller tries to log in, in case the account is the user's own
  @override
  Future<AuthSession> login({required String login, required String password}) async =>
      throw const ApiException(code: 'InvalidCredentials', message: 'wrong', statusCode: 401);

  @override
  Future<AuthSession> register({
    required String email,
    required String code,
    required String username,
    required String password,
  }) async {
    if (registerError != null) throw registerError!;
    registered = {'email': email, 'code': code, 'username': username};
    return _session;
  }
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

Future<_FakeRepository> _pump(WidgetTester tester) async {
  final repository = _FakeRepository();
  await tester.pumpWidget(ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(repository),
      sessionStorageProvider.overrideWithValue(_MemoryStorage()),
    ],
    child: const MaterialApp(home: RegisterScreen()),
  ));
  return repository;
}

Future<void> _tapText(WidgetTester tester, String text) async {
  await tester.ensureVisible(find.text(text));
  await tester.tap(find.text(text));
  await tester.pumpAndSettle();
}

Future<void> _fillDetails(WidgetTester tester, {String email = 'eyad@example.test', String username = 'eyad1234'}) async {
  final fields = find.byType(TextFormField);
  await tester.enterText(fields.at(0), email);
  await tester.enterText(fields.at(1), username);
  await tester.enterText(fields.at(2), 'password123');
  await tester.enterText(fields.at(3), 'password123');
  await _tapText(tester, l10n.createAccount);
}

Future<void> _enterCode(WidgetTester tester, String code) async {
  await tester.enterText(find.byType(TextFormField), code);
  await _tapText(tester, l10n.confirm);
}

void main() {
  testWidgets('step 1 checks every field before any email is sent', (tester) async {
    final repository = await _pump(tester);

    await _fillDetails(tester, email: 'not-an-email', username: 'me@home');

    expect(find.text(l10n.enterValidEmail), findsOneWidget);
    expect(find.text(l10n.usernameNoAt), findsOneWidget);
    expect(repository.codesSentTo, isEmpty);
  });

  testWidgets('details first, then the code creates the account', (tester) async {
    final repository = await _pump(tester);

    await _fillDetails(tester, email: ' eyad@example.test ');

    expect(repository.codesSentTo, ['eyad@example.test']);
    expect(find.text(l10n.codeSentTo('eyad@example.test')), findsOneWidget);

    await _enterCode(tester, '123456');

    expect(repository.registered, {'email': 'eyad@example.test', 'code': '123456', 'username': 'eyad1234'});
  });

  testWidgets('a wrong code shows its message and stays on the code step', (tester) async {
    final repository = await _pump(tester)
      ..registerError = const ApiException(code: 'InvalidEmailCode', message: 'wrong', statusCode: 400);

    await _fillDetails(tester);
    await _enterCode(tester, '000000');

    expect(find.text(l10n.errInvalidEmailCode), findsOneWidget);
    expect(find.text(l10n.codeSentTo('eyad@example.test')), findsOneWidget);
    expect(repository.registered, isNull);
  });

  testWidgets('a taken username goes back to the details, and the same code is used again', (tester) async {
    final repository = await _pump(tester)
      ..registerError = const ApiException(code: ApiException.usernameAlreadyExists, message: 'taken', statusCode: 409);

    await _fillDetails(tester);
    await _enterCode(tester, '123456');

    expect(find.text(l10n.authUsernameTaken), findsOneWidget);
    expect(find.text(l10n.createAccount), findsOneWidget);

    repository.registerError = null;
    await _fillDetails(tester, username: 'eyad5678');
    await _enterCode(tester, '123456');

    expect(repository.codesSentTo, ['eyad@example.test']);
    expect(repository.registered?['username'], 'eyad5678');
  });
}
