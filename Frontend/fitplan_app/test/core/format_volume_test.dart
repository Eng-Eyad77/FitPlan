import 'package:fitplan_app/shared/format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('volume in kg, short above 10 t, a dash when nothing was lifted', () {
    expect(formatVolume(2140), '2,140 kg');
    expect(formatVolume(12400), '12.4k kg');
    expect(formatVolume(0), '—');
  });

  test('a set reads weight first', () {
    expect(formatSet(65, 8), '65 kg × 8');
    expect(formatSet(null, 12), '12 reps');
  });
}
