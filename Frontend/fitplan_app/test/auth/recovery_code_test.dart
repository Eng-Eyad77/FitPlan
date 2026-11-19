import 'package:dio/dio.dart';
import 'package:fitplan_app/core/storage/session_storage.dart';
import 'package:fitplan_app/features/auth/application/auth_controller.dart';
import 'package:fitplan_app/features/auth/application/recovery_code.dart';
import 'package:fitplan_app/features/auth/data/auth_repository.dart';
import 'package:fitplan_app/features/auth/domain/auth_session.dart';
import 'package:fitplan_app/features/auth/presentation/recovery_code_notice.dart';
import 'package:fitplan_app/features/profile/application/profile_controller.dart';
import 'package:fitplan_app/features/profile/data/profile_repository.dart';
import 'package:fitplan_app/features/profile/domain/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

const _session = AuthSession(id: '1', username: 'eyad1234', accessToken: 'token', refreshToken: 'refresh');
const _code = 'ABCD-EFGH-JKLM-NPQR';

class _FakeAuth extends AuthRepository {
  _FakeAuth() : super(Dio());

  final loggedOut = <String>[];

  @override
  Future<AuthResult> register({required String username, required String password}) async =>
      (session: _session, recoveryCode: _code);

  @override
  Future<AuthResult> resetPassword({
    required String username,
    required String recoveryCode,
    required String newPassword,
  }) async =>
      (session: _session, recoveryCode: 'NEWC-ODEN-EWCO-DE22');

  @override
  Future<void> logout(String refreshToken) async => loggedOut.add(refreshToken);
}

class _FakeProfile extends ProfileRepository {
  _FakeProfile() : super(Dio());

  int deleted = 0;

  @override
  Future<Profile> getProfile() async =>
      Profile(id: '1', username: 'eyad1234', createdAt: DateTime(2026), updatedAt: DateTime(2026));

  @override
  Future<void> deleteAccount(String password) async => deleted++;
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

Future<(ProviderContainer, _FakeAuth, _FakeProfile, _MemoryStorage)> _setUp() async {
  final auth = _FakeAuth();
  final profile = _FakeProfile();
  final storage = _MemoryStorage();
  final container = ProviderContainer(overrides: [
    authRepositoryProvider.overrideWithValue(auth),
    profileRepositoryProvider.overrideWithValue(profile),
    sessionStorageProvider.overrideWithValue(storage),
  ]);
  addTearDown(container.dispose);
  await container.read(authControllerProvider.future);
  return (container, auth, profile, storage);
}

void main() {
  test('after sign-up the recovery code is shown, and never saved with the session', () async {
    final (container, _, _, storage) = await _setUp();

    await container.read(authControllerProvider.notifier).register('eyad1234', 'password1');

    expect(container.read(recoveryCodeToShowProvider), _code);
    expect(storage.saved!.toJson().toString(), isNot(contains(_code)));
  });

  test('a password reset signs in and shows the new code', () async {
    final (container, _, _, _) = await _setUp();

    await container.read(authControllerProvider.notifier).resetPassword('eyad1234', _code, 'new-password');

    expect(container.read(authControllerProvider).value, _session);
    expect(container.read(recoveryCodeToShowProvider), 'NEWC-ODEN-EWCO-DE22');
  });

  test('logging out forgets a code that was not confirmed', () async {
    final (container, _, _, _) = await _setUp();
    await container.read(authControllerProvider.notifier).register('eyad1234', 'password1');

    await container.read(authControllerProvider.notifier).logout();

    expect(container.read(recoveryCodeToShowProvider), isNull);
  });

  test('deleting the account ends the session here without asking the server to log out', () async {
    final (container, auth, profile, storage) = await _setUp();
    await container.read(authControllerProvider.notifier).register('eyad1234', 'password1');
    await container.read(profileControllerProvider.future);

    await container.read(profileControllerProvider.notifier).deleteAccount('password1');

    expect(profile.deleted, 1);
    expect(container.read(authControllerProvider).value, isNull);
    expect(storage.saved, isNull);
    expect(auth.loggedOut, isEmpty);
  });

  testWidgets('the notice covers the app until the user confirms saving the code', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(recoveryCodeToShowProvider.notifier).show(_code);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: RecoveryCodeNotice(child: Text('home'))),
    ));

    expect(find.text('Save your recovery code'), findsOneWidget);
    expect(find.text(_code), findsOneWidget);

    await tester.tap(find.text("I've saved it"));
    await tester.pump();

    expect(find.text('Save your recovery code'), findsNothing);
    expect(container.read(recoveryCodeToShowProvider), isNull);
    expect(find.text('home'), findsOneWidget);
  });
}
