import 'package:fitplan_app/features/history/application/history_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('each range starts at the beginning of its week (Sunday), month or year', () {
    final wednesday = DateTime(2026, 11, 25, 18, 30);

    expect(HistoryRange.all.since(wednesday), isNull);
    expect(HistoryRange.week.since(wednesday), DateTime(2026, 11, 22));
    expect(HistoryRange.month.since(wednesday), DateTime(2026, 11));
    expect(HistoryRange.year.since(wednesday), DateTime(2026));
    // on a Sunday the week starts that same day
    expect(HistoryRange.week.since(DateTime(2026, 11, 22, 9)), DateTime(2026, 11, 22));
  });
}
