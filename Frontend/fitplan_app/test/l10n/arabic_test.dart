import 'dart:convert';
import 'dart:io';

import 'package:fitplan_app/core/network/api_exception.dart';
import 'package:fitplan_app/features/progress/application/progress_providers.dart';
import 'package:fitplan_app/features/progress/domain/volume.dart';
import 'package:fitplan_app/features/progress/presentation/volume_card.dart';
import 'package:fitplan_app/features/session/domain/workout_session.dart';
import 'package:fitplan_app/l10n/l10n.dart';
import 'package:fitplan_app/shared/format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart' show DateFormat;

Map<String, dynamic> _arb(String locale) =>
    jsonDecode(File('lib/l10n/app_$locale.arb').readAsStringSync()) as Map<String, dynamic>;

VolumeStats _volume(double total, Set<String> reached) => VolumeStats.fromJson({
      'totalVolumeKg': total,
      'milestones': [
        for (final m in Milestone.all)
          {'key': m.key, 'thresholdKg': m.weightKg, 'reachedAt': reached.contains(m.key) ? '2026-11-03T18:00:00Z' : null},
      ],
    });

void main() {
  setUpAll(() => initializeDateFormatting());
  setUp(() => useStrings(const Locale('ar')));
  tearDown(() => useStrings(const Locale('en')));

  test('every English text has an Arabic one, and none is left in English by mistake', () {
    final en = _arb('en');
    final ar = _arb('ar');
    final keys = en.keys.where((k) => !k.startsWith('@')).toSet();

    expect(ar.keys.where((k) => !k.startsWith('@')).toSet(), keys);
    // the same text in both is fine only for words that are the same (the language names, "×" patterns)
    const sameOnPurpose = {'@@locale', 'languageEnglish', 'languageArabic', 'setWeightRepsShort'};
    final untranslated = [
      for (final k in keys)
        if (!sameOnPurpose.contains(k) && en[k] == ar[k]) k,
    ];
    expect(untranslated, isEmpty);
  });

  test('the app follows the phone unless a language is chosen', () {
    expect(resolveLocale(AppLanguage.system, const Locale('ar', 'SA')), const Locale('ar'));
    expect(resolveLocale(AppLanguage.system, const Locale('fr')), const Locale('en'));
    expect(resolveLocale(AppLanguage.english, const Locale('ar')), const Locale('en'));
    expect(resolveLocale(AppLanguage.arabic, const Locale('en')), const Locale('ar'));
  });

  test('Arabic counts use the right form, with Western digits', () {
    expect(l10n.setCount(1), 'جولة وحدة');
    expect(l10n.setCount(2), 'جولتين');
    expect(l10n.setCount(3), '3 جولات');
    expect(l10n.setCount(12), '12 جولة');
    expect(l10n.exerciseCount(5), '5 تمارين');
    expect(formatSet(60, 8), '60 كيلو × 8');
    expect(formatSet(null, 2), 'عدّتين');
    expect(formatVolume(2140), '2,140 كيلو');
    expect(formatDuration(4500), '1 س 15 د');
    expect(formatDaysAgo(DateTime(2026, 11, 20), DateTime(2026, 11, 23)), 'قبل 3 أيام');
    expect(DateFormat.MMMd().format(DateTime(2026, 11, 23)), '23 نوفمبر');
  });

  test('server errors show in Arabic by their code, never the English title', () {
    const known = ApiException(code: 'ActiveSessionExists', message: 'You already have a workout session in progress.');
    const unknown = ApiException(code: 'SomethingNew', message: 'A new English message.');
    const validation = ApiException(
      code: 'ValidationFailed',
      message: 'One or more validation errors occurred.',
      fieldErrors: {'name': ['The name is required.']},
    );

    expect(known.message, 'عندك حصة شغّالة من قبل.');
    expect(unknown.message, 'صار خطأ. جرّب مرة ثانية.');
    expect(validation.message, 'تأكد من اللي كتبته وجرّب مرة ثانية.');
    expect(validation.fieldError('name'), 'تأكد من اللي كتبته وجرّب مرة ثانية.');
  });

  test('milestones and gym words read naturally in Arabic', () {
    expect(Milestone.compare(8420), 'تقريبًا وزن 1.4 فيل');
    expect(Milestone.compare(6000), 'تقريبًا وزن فيل');
    expect(Milestone.compare(5000), 'تقريبًا وزن 5 سيارات صغيرة');
    expect(bodyPartName('upper arms'), 'باي وتراي');
    expect(CardioMachine.treadmill.label, 'سير');
    expect(CardioField.speed.rangeText, 'السرعة: من 0.1 إلى 30 كم/س');
  });

  testWidgets('the volume card lays out right to left in Arabic, without overflow', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [volumeProvider.overrideWith((ref) async => _volume(8420, {'grand-piano', 'small-car', 'elephant'}))],
      child: const MaterialApp(
        locale: Locale('ar'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Scaffold(body: VolumeCard()),
      ),
    ));
    await tester.pump();

    expect(find.text('كل الوزن اللي شلته'), findsOneWidget);
    expect(find.text('تقريبًا وزن 1.4 فيل'), findsOneWidget);
    expect(find.text('اللي بعده: باص'), findsOneWidget);
    expect(Directionality.of(tester.element(find.byType(VolumeCard))), TextDirection.rtl);

    // the title sits on the right in Arabic
    final title = tester.getTopRight(find.text('كل الوزن اللي شلته'));
    final card = tester.getTopRight(find.byType(VolumeCard));
    expect(card.dx - title.dx, lessThan(40));
    expect(tester.takeException(), isNull);
  });
}
