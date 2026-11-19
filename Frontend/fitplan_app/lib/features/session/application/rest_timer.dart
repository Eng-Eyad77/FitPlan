import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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

  Map<String, dynamic> toJson() => {'endsAt': endsAt.toUtc().toIso8601String(), 'totalMs': total.inMilliseconds};

  static RestTimer? fromJson(Map<String, dynamic> json) {
    final endsAt = DateTime.tryParse(json['endsAt'] as String? ?? '');
    final totalMs = json['totalMs'];
    if (endsAt == null || totalMs is! int) return null;
    return RestTimer(endsAt: endsAt.toLocal(), total: Duration(milliseconds: totalMs));
  }
}

/// Keeps the running rest on the phone, so closing and opening the app keeps the countdown.
/// Failures are ignored: the timer still works, it just won't survive a restart.
class RestTimerStore {
  RestTimerStore(this._storage);

  final FlutterSecureStorage _storage;

  static const _key = 'rest_timer';

  Future<RestTimer?> read() async {
    try {
      final raw = await _storage.read(key: _key);
      if (raw == null) return null;
      return RestTimer.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> write(RestTimer? timer) async {
    try {
      if (timer == null) {
        await _storage.delete(key: _key);
      } else {
        await _storage.write(key: _key, value: jsonEncode(timer.toJson()));
      }
    } catch (_) {
      // not saved; the countdown on screen is unaffected
    }
  }
}

final restTimerStoreProvider = Provider<RestTimerStore>((ref) => RestTimerStore(const FlutterSecureStorage()));

final restTimerProvider = NotifierProvider<RestTimerController, RestTimer?>(RestTimerController.new);

class RestTimerController extends Notifier<RestTimer?> {
  static const defaultRest = Duration(seconds: 90);

  /// Set once the user changed the timer, so a slow restore never overwrites it.
  bool _touched = false;

  RestTimerStore get _store => ref.read(restTimerStoreProvider);

  @override
  RestTimer? build() {
    _restore();
    return null;
  }

  Future<void> _restore() async {
    final saved = await _store.read();
    if (_touched || saved == null) return;
    if (saved.secondsLeft(DateTime.now()) > 0) {
      state = saved;
    } else {
      // it ended while the app was closed
      await _store.write(null);
    }
  }

  void _set(RestTimer? timer) {
    _touched = true;
    state = timer;
    _store.write(timer);
  }

  void start([Duration rest = defaultRest]) {
    _set(RestTimer(endsAt: DateTime.now().add(rest), total: rest));
  }

  void addTime(Duration extra) {
    final timer = state;
    if (timer == null) return;
    _set(RestTimer(endsAt: timer.endsAt.add(extra), total: timer.total + extra));
  }

  void skip() => _set(null);
}
