import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The rest countdown after a set. Stores the end time (not a counter),
/// so it stays correct even if the app was in the background.
class RestTimer {
  const RestTimer({required this.endsAt, required this.total});

  final DateTime endsAt;
  final Duration total;

  int secondsLeft(DateTime now) {
    final left = endsAt.difference(now).inMilliseconds;
    return left <= 0 ? 0 : (left / 1000).ceil();
  }

  /// 1.0 at the start, 0.0 at the end.
  double progress(DateTime now) =>
      total.inMilliseconds == 0 ? 0 : (endsAt.difference(now).inMilliseconds / total.inMilliseconds).clamp(0, 1);
}

final restTimerProvider = NotifierProvider<RestTimerController, RestTimer?>(RestTimerController.new);

class RestTimerController extends Notifier<RestTimer?> {
  static const defaultRest = Duration(seconds: 90);

  @override
  RestTimer? build() => null;

  void start([Duration rest = defaultRest]) {
    state = RestTimer(endsAt: DateTime.now().add(rest), total: rest);
  }

  void addTime(Duration extra) {
    final timer = state;
    if (timer == null) return;
    state = RestTimer(endsAt: timer.endsAt.add(extra), total: timer.total + extra);
  }

  void skip() => state = null;
}
