import 'package:fitplan_admin/app.dart';
import 'package:fitplan_admin/core/admin_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Signs in without a server.
class _FakeApi extends AdminApi {
  String? lastCode;

  @override
  Future<void> signIn({required String login, required String password, required String code}) async {
    lastCode = code;
    if (code != '123456') throw AdminApi.describe(401, {'errorCode': 'InvalidAdminSignIn'});
    session.value = AdminSession(
      username: login,
      role: 'Owner',
      accessToken: 't',
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
    );
  }

  final actions = <String>[];

  @override
  Future<UserPage> users({String search = '', String status = 'all', int page = 1}) async => UserPage(
        items: [
          UserRow(
            id: 'u1',
            username: 'sami_lifts',
            email: 's***@gmail.com',
            createdAt: DateTime(2026, 11, 4),
            lastWorkoutAt: null,
            disabled: actions.contains('u1:disable'),
            isAdmin: false,
          ),
        ],
        page: 1,
        totalPages: 1,
        totalCount: 1,
      );

  @override
  Future<UserDetail> user(String id) async => UserDetail(
        id: id,
        username: 'sami_lifts',
        email: 's***@gmail.com',
        createdAt: DateTime(2026, 11, 4),
        disabledAt: actions.contains('$id:disable') ? DateTime(2026, 11, 25) : null,
        isAdmin: false,
        workouts: 23,
        plans: 3,
        signedInDevices: 2,
        reports: 1,
        lastWorkoutAt: null,
      );

  @override
  Future<String> revealEmail(String id) async {
    actions.add('$id:reveal');
    return 'sami@gmail.com';
  }

  @override
  Future<void> userAction(String id, String action) async => actions.add('$id:$action');

  @override
  Future<AuditPage> audit({int page = 1}) async => AuditPage(
        items: [AuditEntry(adminName: 'eyad', action: 'Signed in', target: null, createdAt: DateTime(2026, 11, 25, 10, 12))],
        page: 1,
        totalPages: 1,
      );
}

void main() {
  Future<_FakeApi> openApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final api = _FakeApi();
    await tester.pumpWidget(AdminApp(api: api));
    await tester.pumpAndSettle();
    return api;
  }

  Future<void> enterPassword(WidgetTester tester) async {
    await tester.enterText(find.widgetWithText(TextFormField, 'Email or username'), 'eyad');
    await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'secret-password');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
  }

  testWidgets('signed out, every page leads to sign-in', (tester) async {
    await openApp(tester);

    expect(find.text('Admin sign in'), findsOneWidget);
  });

  testWidgets('a wrong code stays on the code step with one message for both mistakes', (tester) async {
    final api = await openApp(tester);
    await enterPassword(tester);

    await tester.enterText(find.byType(TextField), '999999');
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(api.lastCode, '999999');
    expect(find.textContaining('The sign-in details or the code are wrong.'), findsOneWidget);
    expect(api.session.value, isNull);
  });

  testWidgets('the right code opens the admin with the audit log, and sign out returns', (tester) async {
    final api = await openApp(tester);
    await enterPassword(tester);

    await tester.enterText(find.byType(TextField), '123456');
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Audit log'), findsOneWidget);
    expect(find.text('Signed in'), findsOneWidget);

    api.signOut();
    await tester.pumpAndSettle();
    expect(find.text('Admin sign in'), findsOneWidget);
  });

  testWidgets('users: pick one, show the email, disable after confirming', (tester) async {
    final api = await openApp(tester);
    await enterPassword(tester);
    await tester.enterText(find.byType(TextField), '123456');
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Users').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('sami_lifts'));
    await tester.pumpAndSettle();
    expect(find.text('23'), findsOneWidget);

    await tester.tap(find.text('Show'));
    await tester.pumpAndSettle();
    expect(find.text('sami@gmail.com'), findsOneWidget);

    await tester.tap(find.text('Disable account'));
    await tester.pumpAndSettle();
    expect(api.actions, isNot(contains('u1:disable')));
    await tester.tap(find.widgetWithText(FilledButton, 'Disable'));
    await tester.pumpAndSettle();

    expect(api.actions, containsAll(['u1:reveal', 'u1:disable']));
    expect(find.text('Enable account'), findsOneWidget);
  });
}
