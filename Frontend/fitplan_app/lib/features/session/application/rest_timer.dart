import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'active_session_controller.dart';
import 'next_set.dart';
import 'rest_notifications.dart';
import 'session_drafts.dart';

/// The rest countdown after a set. Stores the end time (not a counter),
/// so it stays correct even if the app was in the background.
class RestTimer {
  const RestTimer({required this.endsAt, required this.total, this.next, this.upNext});

  final DateTime endsAt;
  final Duration total;

  /// What comes after the rest when it isn't a set ("Time for your next exercise").
  final String? next;

  /// The set to do after the rest, with its pre-filled values, so the notification can log it.
  final NextSet? upNext;

  int secondsLeft(DateTime now) {
    final left = endsAt.difference(now).inMilliseconds;
    return left <= 0 ? 0 : (left / 1000).ceil();
  }

  /// 1.0 at the start, 0.0 at the end.
  double progress(DateTime now) =>
      total.inMilliseconds == 0 ? 0 : (endsAt.difference(now).inMilliseconds / total.inMilliseconds).clamp(0, 1);

  Map<String, dynamic> toJson() => {
        'endsAt': endsAt.toUtc().toIso8601String(),
        'totalMs': total.inMilliseconds,
        'next': ?next,
        'upNext': ?upNext?.toJson(),
      };

  static RestTimer? fromJson(Map<String, dynamic> json) {
    final endsAt = DateTime.tryParse(json['endsAt'] as String? ?? '');
    final totalMs = json['totalMs'];
    if (endsAt == null || totalMs is! int) return null;
    final next = json['next'];
    return RestTimer(
      endsAt: endsAt.toLocal(),
      total: Duration(milliseconds: totalMs),
      next: next is String ? next : null,
      upNext: NextSet.fromJson(json['upNext']),
    );
  }

  RestTimer extendedBy(Duration extra) =>
      RestTimer(endsAt: endsAt.add(extra), total: total + extra, next: next, upNext: upNext);

  /// "-15s": never before [now], so taking more than is left just ends the rest.
  RestTimer shortenedBy(Duration less, DateTime now) {
    final newEnd = endsAt.subtract(less).isBefore(now) ? now : endsAt.subtract(less);
    final removed = endsAt.difference(newEnd);
    final newTotal = total - removed;
    return RestTimer(
      endsAt: newEnd,
      total: newTotal > Duration.zero ? newTotal : const Duration(seconds: 1),
      next: next,
      upNext: upNext,
    );
  }

  RestTimer withUpNext(NextSet? set) => RestTimer(endsAt: endsAt, total: total, next: next, upNext: set);
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

/// The running rest. While the app is on screen, the bar in the workout shows it;
/// once the app is hidden (home screen, locked, app switcher), the phone shows it instead:
/// a countdown on Android (9B) and "Rest is over" at the end time (9A).
class RestTimerController extends Notifier<RestTimer?> {
  static const defaultRest = Duration(seconds: 90);

  /// Set once the user changed the timer, so a slow restore never overwrites it.
  bool _touched = false;

  /// Whether the app is on screen. The notifications are only shown while it is not.
  bool _visible = true;

  /// Moves the bar of the Android countdown notification while the app is hidden but still running.
  Timer? _ticker;

  RestTimerStore get _store => ref.read(restTimerStoreProvider);
  RestNotifier get _notifier => ref.read(restNotifierProvider);

  @override
  RestTimer? build() {
    final binding = WidgetsBinding.instance;
    _visible = switch (binding.lifecycleState) {
      null || AppLifecycleState.resumed || AppLifecycleState.inactive => true,
      _ => false,
    };
    final lifecycle = AppLifecycleListener(onHide: _hidden, onShow: _shown);
    ref.onDispose(lifecycle.dispose);
    ref.onDispose(_stopTicker);
    _listenToButtons();
    _restore();
    return null;
  }

  /// A notification button ran while the app was in the background: take over what it saved.
  void _listenToButtons() {
    try {
      final port = ReceivePort();
      IsolateNameServer.removePortNameMapping(restActionsPortName);
      IsolateNameServer.registerPortWithName(port.sendPort, restActionsPortName);
      final subscription = port.listen((_) => _pickUp());
      ref.onDispose(() {
        subscription.cancel();
        port.close();
        IsolateNameServer.removePortNameMapping(restActionsPortName);
      });
    } catch (_) {
      // without it, the changes are picked up when the app is shown again
    }
  }

  Future<void> _restore() async {
    // The app was opened: one scheduled before it was closed would fire on top of the open app,
    // and one already shown is no longer needed.
    if (_visible) _notifier.cancel();
    var saved = await _store.read();
    // the Lock Screen buttons may have changed it while the app was closed
    final change = await _notifier.takeLiveChange();
    if (change != null) {
      saved = _changed(saved, change);
      await _store.write(saved);
    }
    if (_touched) return;
    if (saved != null && saved.secondsLeft(DateTime.now()) > 0) {
      state = saved;
      _notifier.showLive(saved);
    } else {
      // it ended while the app was closed: the Lock Screen countdown stood at 0:00 since
      _notifier.endLive();
      if (saved != null) await _store.write(null);
    }
  }

  /// Reads back the rest a notification button saved, and sends a set it logged.
  /// [fromButton]: a button just ran, so nothing saved means it skipped the rest. Otherwise
  /// (the app was shown) nothing saved may just be a failed read, and the rest on screen stays.
  Future<void> _pickUp({bool fromButton = true}) async {
    final saved = await _store.read();
    if (saved != null || fromButton) {
      _touched = true;
      state = saved != null && saved.secondsLeft(DateTime.now()) > 0 ? saved : null;
      if (!_visible) _startTicker();
      final timer = state;
      timer == null ? _notifier.endLive() : _notifier.showLive(timer);
    }
    if ((await ref.read(pendingSetsStoreProvider).read()).isNotEmpty) {
      await ref.read(activeSessionControllerProvider.notifier).sendPendingSets();
    }
  }

  void _hidden() {
    _visible = false;
    var timer = state;
    if (timer == null || timer.secondsLeft(DateTime.now()) == 0) return;
    // values typed into the next set before leaving the app win over the pre-filled ones
    final set = timer.upNext;
    final typed = set == null ? null : ref.read(sessionDraftsProvider).value(set.sessionExerciseId, set.setNumber);
    final edited = typed == null ? null : set!.withTyped(kg: typed.kg, reps: typed.reps);
    if (edited != null) {
      timer = timer.withUpNext(edited);
      state = timer;
      // the buttons read the saved one
      _store.write(timer);
      _notifier.showLive(timer);
    }
    _notifier.show(timer);
    _startTicker();
  }

  void _startTicker() {
    _stopTicker();
    if (state == null) return;
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      final timer = state;
      if (_visible || timer == null || timer.secondsLeft(DateTime.now()) == 0) return _stopTicker();
      _notifier.updateCountdown(timer);
    });
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  void _shown() {
    _visible = true;
    _stopTicker();
    _notifier.cancel();
    unawaited(_catchUp());
  }

  /// Back on screen: take over what a Lock Screen button (iOS) or a notification button
  /// (in case its message didn't arrive) changed while the app was away.
  Future<void> _catchUp() async {
    final change = await _notifier.takeLiveChange();
    if (change != null) {
      final timer = _changed(state, change);
      // saved first, so the pick-up below reads the new one
      await _store.write(timer);
      _set(timer);
    }
    await _pickUp(fromButton: false);
  }

  /// [timer] after a Lock Screen button: skipped, or moved to the new end (the extra time is
  /// added to the total, as +15s in the app does).
  static RestTimer? _changed(RestTimer? timer, LiveChange change) {
    if (change.skipped || timer == null) return null;
    final endsAt = change.endsAt;
    if (endsAt == null || endsAt == timer.endsAt) return timer;
    // +15s or -15s on the Lock Screen
    return endsAt.isAfter(timer.endsAt)
        ? timer.extendedBy(endsAt.difference(timer.endsAt))
        : timer.shortenedBy(timer.endsAt.difference(endsAt), DateTime.now());
  }

  void _set(RestTimer? timer) {
    _touched = true;
    state = timer;
    _store.write(timer);
    timer == null ? _notifier.endLive() : _notifier.showLive(timer);
    if (_visible) {
      // the user ended the rest on screen: drop the notification
      if (timer == null) _notifier.cancel();
    } else if (timer != null) {
      _notifier.show(timer);
      _startTicker();
    }
  }

  /// [next] names what comes after the rest when it isn't a set; [upNext] is the next set.
  void start([Duration rest = defaultRest, String? next, NextSet? upNext]) {
    _notifier.askPermission();
    _set(RestTimer(endsAt: DateTime.now().add(rest), total: rest, next: next, upNext: upNext));
  }

  void addTime(Duration extra) {
    final timer = state;
    if (timer == null) return;
    _set(timer.extendedBy(extra));
  }

  void removeTime(Duration less) {
    final timer = state;
    if (timer == null || timer.secondsLeft(DateTime.now()) == 0) return;
    _set(timer.shortenedBy(less, DateTime.now()));
  }

  void skip() => _set(null);

  /// The bar hides itself a moment after the rest ended. Nothing else changes: while the app is
  /// hidden, Android keeps it running, and this must not cancel the "Rest is over" the phone is
  /// about to show (an inexact alarm can arrive several seconds late).
  void clearEnded() {
    final timer = state;
    if (timer != null && timer.secondsLeft(DateTime.now()) == 0) {
      state = null;
      if (_visible) _notifier.endLive();
    }
  }
}
