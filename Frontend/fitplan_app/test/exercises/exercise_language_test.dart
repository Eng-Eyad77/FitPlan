import 'package:fitplan_app/features/exercises/domain/exercise.dart';
import 'package:fitplan_app/features/exercises/presentation/widgets/exercise_name.dart';
import 'package:fitplan_app/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Phase 11C: exercise text in the app's language.
void main() {
  test('the API is asked for the language on screen', () {
    expect(contentLanguageFor(AppLanguage.arabic), 'ar');
    expect(contentLanguageFor(AppLanguage.english), 'en');
    expect(['ar', 'en'], contains(contentLanguageFor(AppLanguage.system)));
  });

  test('an exercise reads its English name and details, and works without them', () {
    final arabic = Exercise.fromJson({
      'id': 'a1',
      'name': 'بنش بريس صدر مستوي بار',
      'englishName': 'barbell bench press',
      'gifUrl': 'https://example.test/a.gif',
      'bodyPart': 'chest',
      'instructions': ['انسدح على البنش'],
      'equipments': ['بار'],
      'targetMuscles': ['الصدر'],
      'secondaryMuscles': ['الترايسبس', 'الكتف'],
    });
    final old = Exercise.fromJson({'id': 'a2', 'name': 'push-up', 'gifUrl': 'https://example.test/b.gif', 'bodyPart': 'chest'});

    expect(arabic.englishName, 'barbell bench press');
    expect(arabic.secondaryMuscles, ['الترايسبس', 'الكتف']);
    expect(old.englishName, isNull);
    expect(old.equipments, isEmpty);
  });

  Future<void> pump(WidgetTester tester, Widget child) => tester.pumpWidget(
        MaterialApp(home: Directionality(textDirection: TextDirection.rtl, child: Material(child: child))),
      );

  testWidgets('the English name shows small under an Arabic one', (tester) async {
    await pump(tester, const ExerciseName(name: 'ديدليفت بار', englishName: 'barbell deadlift'));

    expect(find.text('ديدليفت بار'), findsOneWidget);
    expect(find.text('Barbell deadlift'), findsOneWidget);
  });

  testWidgets('an English name shows once', (tester) async {
    await pump(tester, const ExerciseName(name: 'barbell deadlift'));

    expect(find.text('Barbell deadlift'), findsOneWidget);
    expect(find.byType(Text), findsOneWidget);
  });
}
