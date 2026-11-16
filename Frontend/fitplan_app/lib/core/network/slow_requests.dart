import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// How many requests have been waiting longer than [SlowRequests.threshold].
///
/// The free server and database sleep when nobody uses them, and the first request after that
/// can take up to about a minute. While this is above zero, the app shows "Waking the server".
final slowRequestsProvider = NotifierProvider<SlowRequests, int>(SlowRequests.new);

class SlowRequests extends Notifier<int> {
  static const threshold = Duration(seconds: 8);

  @override
  int build() => 0;

  /// Call when a request starts. Call the returned function once when it ends, however it ends.
  void Function() track() {
    var counted = false;
    var ended = false;
    final timer = Timer(threshold, () {
      if (ended) return;
      counted = true;
      state = state + 1;
    });

    return () {
      if (ended) return;
      ended = true;
      timer.cancel();
      if (counted) state = state - 1;
    };
  }
}
