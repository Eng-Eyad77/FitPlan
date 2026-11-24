import 'package:dio/dio.dart';
import 'package:fitplan_app/core/network/api_exception.dart';
import 'package:fitplan_app/core/storage/session_storage.dart';
import 'package:fitplan_app/features/auth/data/auth_repository.dart';
import 'package:fitplan_app/features/auth/domain/auth_session.dart';
import 'package:fitplan_app/features/auth/presentation/reset_password_screen.dart';
import 'package:fitplan_app/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

const _rightCode = '123456';

class _FakeRepository extends AuthRepository {
  _FakeRepository() : super(Dio());

  Map<String, String>? reset;

  @override
  Future<void> sendPasswordResetCode(String email) async {}

  @override
  Future<void> checkPasswordResetCode({required String email, required String code}) async {
    if (code != _rightCode) {
      throw const ApiException(code: 'InvalidEmailCode', message: 'wrong', statusCode: 400);
    }
  }

  @override
  Future<AuthSession> resetPassword({required String email, required String code, required String newPassword}) async {
    reset = {'email': email, 'code': code, 'newPassword': newPassword};
    return const AuthSession(id: '1', username: 'eyad1234', accessToken: 'token');
  }
}

class _MemoryStorage extends SessionStorage {
  _MemoryStorage() : super(const FlutterSecureStorage());

  @override
  Future<AuthSession?> read() async => null;

  @override
  Future<void> save(AuthSession session) async {}

  @override
  Future<void> clear() async {}
}

Future<void> _tapText(WidgetTester tester, String text) async {
  await tester.ensureVisible(find.text(text));
  await tester.tap(find.text(text));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('the code is checked first, then the new password is asked for', (tester) async {
    final repository = _FakeRepository();
    await tester.pumpWidget(ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(repository),
        sessionStorageProvider.overrideWithValue(_MemoryStorage()),
      ],
      child: const MaterialApp(home: ResetPasswordScreen()),
    ));

    await tester.enterText(find.byType(TextFormField), 'eyad@example.test');
    await _tapText(tester, l10n.sendCode);

    // step 2: only the code; a wrong one stays here with its message
    expect(find.text(l10n.newPassword), findsNothing);
    await tester.enterText(find.byType(TextFormField), '000000');
    await _tapText(tester, l10n.confirm);
    expect(find.text(l10n.errInvalidEmailCode), findsOneWidget);
    expect(find.text(l10n.newPassword), findsNothing);

    await tester.enterText(find.byType(TextFormField), _rightCode);
    await _tapText(tester, l10n.confirm);

    // step 3: the new password
    final fields = find.byType(TextFormField);
    expect(fields, findsNWidgets(2));
    await tester.enterText(fields.at(0), 'newpassword1');
    await tester.enterText(fields.at(1), 'newpassword1');
    await _tapText(tester, l10n.resetPassword);

    expect(repository.reset, {'email': 'eyad@example.test', 'code': _rightCode, 'newPassword': 'newpassword1'});
  });
}
