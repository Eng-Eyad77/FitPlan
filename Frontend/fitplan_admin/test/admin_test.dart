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

  Map<String, Object>? savedText;

  @override
  Future<ExercisePage> exercises({String search = '', String filter = 'all', int page = 1}) async => const ExercisePage(
        items: [ExerciseRow(id: 'e1', name: 'Barbell pin presses', arabicName: null, bodyPart: 'chest', hidden: false, gifStatus: 'Missing')],
        page: 1,
        totalPages: 1,
        counts: {'all': 1, 'noDemo': 1, 'notChecked': 0, 'hidden': 0},
      );

  @override
  Future<ExerciseDetail> exercise(String id) async => ExerciseDetail(
        id: id,
        bodyPart: 'chest',
        gifUrl: 'https://media.example.test/a.gif',
        gifStatus: 'Missing',
        hidden: false,
        englishName: 'Barbell pin presses',
        englishSteps: const ['Set the pins.', 'Press up.'],
        arabicName: savedText?['arabicName'] as String?,
        arabicSteps: const [],
        plans: 2,
        workouts: 5,
      );

  @override
  Future<void> saveExerciseText(String id,
      {required String englishName,
      required List<String> englishSteps,
      required String arabicName,
      required List<String> arabicSteps}) async {
    savedText = {'englishName': englishName, 'englishSteps': englishSteps, 'arabicName': arabicName, 'arabicSteps': arabicSteps};
  }

  @override
  Future<({String username, List<UserPlan> plans})> viewPlans(String userId) async {
    actions.add('$userId:view-plans');
    return (
      username: 'sami_lifts',
      plans: [
        (
          name: 'Push day',
          createdAt: DateTime(2026, 11, 5),
          exercises: [(name: 'Barbell bench press', sets: 4, reps: 6, restSeconds: 150)],
        ),
      ],
    );
  }

  @override
  Future<List<CardioMachineRow>> cardioMachines() async => [
        (machine: 'StationaryBike', fields: ['level', 'distanceKm', 'cadenceRpm'], usesThisMonth: 5),
      ];

  bool refreshed = false;
  bool exported = false;

  @override
  Future<ReportPage> reports({String filter = 'open', int page = 1}) async {
    final done = actions.contains('r14:done');
    final report = (
      id: 14,
      username: 'khalid88',
      message: 'مؤقت الراحة يوقف لما أقفل الشاشة.',
      isSuggestion: false,
      platform: 'ios',
      appVersion: '1.0.3',
      language: 'ar',
      sentToTelegram: false,
      createdAt: DateTime(2026, 11, 25, 9),
      doneAt: done ? DateTime(2026, 11, 25, 10) : null,
    );
    final showIt = (filter == 'open' && !done) || (filter == 'done' && done);
    return (items: showIt ? [report] : <Report>[], page: 1, totalPages: 1, open: done ? 0 : 1, suggestions: 0, done: done ? 1 : 0);
  }

  @override
  Future<void> setReportDone(int id, bool done) async => actions.add('r$id:${done ? 'done' : 'reopen'}');

  @override
  Future<List<int>> exportReports() async {
    exported = true;
    return const [];
  }

  @override
  Future<({List<ApiError> apiErrors, List<FailedSignIn> failedSignIns})> errors() async => (
        apiErrors: [(createdAt: DateTime(2026, 11, 25, 9, 41), endpoint: 'POST /api/sessions', error: 'InvalidOperationException', requestId: '00-abc-01')],
        failedSignIns: [(account: 'reem_runs', reason: 'Wrong password', attempts: 4, lastAt: DateTime(2026, 11, 25, 9))],
      );

  @override
  Future<Overview> overview({bool refresh = false}) async {
    refreshed = refreshed || refresh;
    return Overview(
      countedAt: DateTime.now(),
      users: 38,
      newUsers: 5,
      activeUsers: 19,
      workouts: 64,
      workoutsBefore: 52,
      volumeKg: 182400,
      volumeKgBefore: 167000,
      cardioThisMonth: 27,
      topCardio: 'Treadmill',
      openReports: 3,
      noDemo: 176,
      emailsToday: 12,
      emailLimit: 100,
      workoutsPerDay: const [3, 4, 2, 5, 6, 3, 1, 5, 7, 4, 6, 8, 4, 6],
      signUpsPerWeek: const [1, 2, 2, 4, 3, 5, 4, 5],
      topExercises: const [(name: 'Barbell bench press', workouts: 41), (name: 'Barbell full squat', workouts: 34)],
    );
  }

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

    expect(find.text('Workouts per day'), findsOneWidget);
    await tester.tap(find.text('Admins').first);
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

  testWidgets('exercises: saving needs Arabic too, then sends both languages', (tester) async {
    final api = await openApp(tester);
    await enterPassword(tester);
    await tester.enterText(find.byType(TextField), '123456');
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Exercises').first);
    await tester.pumpAndSettle();
    expect(find.text('No demo 1'), findsOneWidget);
    await tester.tap(find.text('Barbell pin presses'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();
    expect(api.savedText, isNull);
    expect(find.textContaining('both English and Arabic'), findsWidgets);

    await tester.enterText(find.widgetWithText(TextField, 'الاسم بالعربي'), 'ضغط البار من المساند');
    await tester.enterText(find.widgetWithText(TextField, 'الخطوات بالعربي، كل خطوة في سطر'), 'اضبط المساند.\n\nادفع للأعلى.');
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();

    expect(api.savedText!['arabicName'], 'ضغط البار من المساند');
    expect(api.savedText!['arabicSteps'], ['اضبط المساند.', 'ادفع للأعلى.']);
    expect(api.savedText!['englishSteps'], ['Set the pins.', 'Press up.']);
  });

  testWidgets('plans: View on a user opens their plans with the logged banner, and cardio lists the machines', (tester) async {
    final api = await openApp(tester);
    await enterPassword(tester);
    await tester.enterText(find.byType(TextField), '123456');
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Users').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('sami_lifts'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('View'));
    await tester.pumpAndSettle();

    expect(api.actions, contains('u1:view-plans'));
    expect(find.textContaining('This view is logged.'), findsOneWidget);
    expect(find.text('Barbell bench press'), findsOneWidget);
    expect(find.text('2:30'), findsOneWidget);
    expect(find.text('Stationary bike'), findsOneWidget);
    expect(find.text('Level, distance, cadence'), findsOneWidget);
  });

  testWidgets('overview: totals and charts after sign-in, and Refresh counts again', (tester) async {
    final api = await openApp(tester);
    await enterPassword(tester);
    await tester.enterText(find.byType(TextField), '123456');
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('38'), findsOneWidget);
    expect(find.text('+5 in the last 7 days'), findsOneWidget);
    expect(find.text('+23% on the 7 before'), findsOneWidget);
    expect(find.text('182 t'), findsOneWidget);
    expect(find.text('Most used: treadmill'), findsOneWidget);
    expect(find.text('Barbell bench press'), findsOneWidget);
    expect(find.text('176 exercises have no working demo GIF'), findsOneWidget);
    expect(find.text('12 / 100'), findsOneWidget);

    await tester.tap(find.text('Refresh'));
    await tester.pumpAndSettle();
    expect(api.refreshed, isTrue);
  });

  testWidgets('reports: an open report is marked done, errors and failed sign-ins show, and CSV exports', (tester) async {
    final api = await openApp(tester);
    await enterPassword(tester);
    await tester.enterText(find.byType(TextField), '123456');
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Reports and errors').first);
    await tester.pumpAndSettle();
    expect(find.text('Open 1'), findsOneWidget);
    expect(find.text('Telegram failed'), findsOneWidget);
    expect(find.text('POST /api/sessions'), findsOneWidget);
    expect(find.text('00-abc-01'), findsOneWidget);
    expect(find.text('reem_runs'), findsOneWidget);
    expect(find.text('4 tries'), findsOneWidget);

    await tester.tap(find.text('Mark done'));
    await tester.pumpAndSettle();
    expect(api.actions, contains('r14:done'));
    expect(find.text('Open 0'), findsOneWidget);
    expect(find.text('No open reports.'), findsOneWidget);

    await tester.tap(find.text('Export CSV'));
    await tester.pumpAndSettle();
    expect(api.exported, isTrue);
  });
}
