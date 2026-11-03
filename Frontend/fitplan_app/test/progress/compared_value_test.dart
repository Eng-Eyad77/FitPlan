import 'package:fitplan_app/features/progress/domain/stats.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('percentChange compares with last time', () {
    expect(const ComparedValue(current: 8940, previous: 8430).percentChange!.round(), 6);
    expect(const ComparedValue(current: 900, previous: 1000).percentChange, closeTo(-10, 0.001));
  });

  test('no percentage without a previous value', () {
    expect(const ComparedValue(current: 100).percentChange, isNull);
    expect(const ComparedValue(current: 100, previous: 0).percentChange, isNull);
  });

  test('reads the API record types', () {
    final record = NewRecord.fromJson({
      'exerciseId': 'x',
      'name': 'bench press',
      'type': 'Estimated1Rm',
      'value': 82.3,
      'previousBest': 80,
    });
    expect(record.type, RecordType.estimated1Rm);
    expect(record.value - record.previousBest, closeTo(2.3, 0.001));
  });
}
