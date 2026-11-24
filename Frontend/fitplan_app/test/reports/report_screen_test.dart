import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fitplan_app/core/config/env.dart';
import 'package:fitplan_app/core/network/api_exception.dart';
import 'package:fitplan_app/features/reports/data/report_repository.dart';
import 'package:fitplan_app/features/reports/presentation/report_screen.dart';
import 'package:fitplan_app/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRepository extends ReportRepository {
  _FakeRepository() : super(Dio());

  final sent = <String>[];
  Object? error;

  @override
  Future<void> send(String message) async {
    if (error != null) throw error!;
    sent.add(message);
  }
}

/// Opens the report screen from a home page, so closing it after sending can be seen.
Future<_FakeRepository> _pump(WidgetTester tester) async {
  final repository = _FakeRepository();
  await tester.pumpWidget(ProviderScope(
    overrides: [reportRepositoryProvider.overrideWithValue(repository)],
    child: MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const ReportScreen())),
            child: const Text('open'),
          ),
        ),
      ),
    ),
  ));
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return repository;
}

Future<void> _send(WidgetTester tester, String message) async {
  await tester.enterText(find.byType(TextFormField), message);
  await tester.tap(find.text(l10n.send));
  await tester.pumpAndSettle();
}

void main() {
  test('the version sent with reports matches pubspec.yaml', () {
    final line = File('pubspec.yaml').readAsLinesSync().firstWhere((l) => l.startsWith('version:'));
    expect(line.split(':')[1].trim().split('+').first, Env.appVersion);
  });

  testWidgets('a short message is refused before anything is sent', (tester) async {
    final repository = await _pump(tester);

    await _send(tester, 'too short');

    expect(find.text(l10n.atLeastChars(10)), findsOneWidget);
    expect(repository.sent, isEmpty);
  });

  testWidgets('a report is sent, thanked for, and the screen closes', (tester) async {
    final repository = await _pump(tester);

    await _send(tester, 'Finishing a workout freezes the app.');

    expect(repository.sent, ['Finishing a workout freezes the app.']);
    expect(find.text(l10n.reportSent), findsOneWidget);
    expect(find.byType(ReportScreen), findsNothing);
  });

  testWidgets('a failure keeps the text and says why', (tester) async {
    (await _pump(tester)).error = const ApiException(code: ApiException.networkError, message: 'offline');

    await _send(tester, 'Finishing a workout freezes the app.');

    expect(find.byType(ReportScreen), findsOneWidget);
    expect(find.text('Finishing a workout freezes the app.'), findsOneWidget);
    expect(find.text(l10n.errNetwork), findsOneWidget);
  });

  testWidgets('too many reports get their own message', (tester) async {
    final repository = await _pump(tester)
      ..error = const ApiException(code: 'TooManyRequests', message: 'Too many requests.', statusCode: 429);

    await _send(tester, 'Finishing a workout freezes the app.');

    expect(find.text(l10n.reportTooMany), findsOneWidget);
    expect(repository.sent, isEmpty);
  });
}
