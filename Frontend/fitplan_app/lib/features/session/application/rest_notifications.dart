import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../../app/router.dart';
import 'next_set.dart';
import 'rest_timer.dart';

/// What the phone shows while the app is hidden during a rest:
/// - 9A: "Rest is over" at the end time, on Android and iOS. It arrives with the screen locked,
///   the app in the background, or the app closed. With a set to do next, it has a "Log" button (9E).
/// - 9B: on Android, a quiet notification counting down the rest, with "+30 s" and "Skip rest".
abstract class RestNotifier {
  /// Asks to show notifications. Asked once per app run, at the first rest, never at launch.
  Future<void> askPermission();

  /// Shows [timer] outside the app, replacing what was shown before.
  Future<void> show(RestTimer timer);

  /// Moves the bar of the Android countdown on. Android can't move it by itself, so the app does,
  /// once a second, while it still runs in the background.
  Future<void> updateCountdown(RestTimer timer);

  /// iPhone (9C/9D): the rest on the Lock Screen and in the Dynamic Island, started while the app
  /// is on screen (iOS only allows starting it then) and kept up to date. The system counts it down.
  Future<void> showLive(RestTimer timer);

  Future<void> endLive();

  Future<void> cancel();
}

/// The texts, shared by the phone notifications and the tests.
abstract final class RestTexts {
  static const alertTitle = 'Rest is over';
  static const countdownTitle = 'Resting';
  static const nextExercise = 'Time for your next exercise';
  static const nextSet = 'Time for your next set';

  /// "Squat · set 3 · 60 kg × 12"
  static String alertBody(RestTimer timer) =>
      timer.upNext == null ? timer.next ?? nextSet : '${timer.upNext!.label} · ${timer.upNext!.values}';

  static String countdownBody(RestTimer timer) => 'Next: ${alertBody(timer)}';

  static String logButton(NextSet set) => 'Log ${set.values}';
}

/// The buttons on the notifications.
abstract final class RestActionIds {
  static const addTime = 'rest_add_30';
  static const skip = 'rest_skip';
  static const logSet = 'rest_log_set';

  static const addedTime = Duration(seconds: 30);
}

/// The open app listens here, to pick up what a button changed.
const restActionsPortName = 'fitplan_rest_actions';

/// Runs a notification button. It works on what is saved on the phone, so it runs the same
/// whether the app is still in the background or was closed; it never calls the server.
class RestActions {
  RestActions({required this.timers, required this.pending, required this.notifier, DateTime Function()? now})
      : _now = now ?? DateTime.now;

  final RestTimerStore timers;
  final PendingSetsStore pending;
  final RestNotifier notifier;
  final DateTime Function() _now;

  Future<void> handle(String? actionId, String? payload) async {
    switch (actionId) {
      case RestActionIds.addTime:
        final timer = await timers.read();
        if (timer == null || timer.secondsLeft(_now()) == 0) return;
        final longer = timer.extendedBy(RestActionIds.addedTime);
        await timers.write(longer);
        await notifier.show(longer);
        await notifier.showLive(longer);
      case RestActionIds.skip:
        await timers.write(null);
        await notifier.cancel();
        await notifier.endLive();
      case RestActionIds.logSet:
        final set = NextSet.decode(payload);
        if (set == null) return;
        await pending.add(set);
        // the rest after this set starts now, as it does in the app
        final rest = Duration(seconds: set.restSeconds);
        final following = set.following;
        final timer = RestTimer(
          endsAt: _now().add(rest),
          total: rest,
          next: following == null ? RestTexts.nextExercise : null,
          upNext: following,
        );
        await timers.write(timer);
        await notifier.show(timer);
        await notifier.showLive(timer);
      default:
        return;
    }
    // the app, if it still runs, reloads the rest and sends the set
    IsolateNameServer.lookupPortByName(restActionsPortName)?.send(actionId);
  }
}

/// Called by the phone for a button tap, in a separate background isolate (the app may be closed).
@pragma('vm:entry-point')
Future<void> onRestNotificationAction(NotificationResponse response) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  const storage = FlutterSecureStorage();
  await RestActions(
    timers: RestTimerStore(storage),
    pending: PendingSetsStore(storage),
    notifier: LocalRestNotifier(onTap: () {}),
  ).handle(response.actionId, response.payload);
}

class LocalRestNotifier implements RestNotifier {
  LocalRestNotifier({required this.onTap});

  /// The user tapped a notification (not a button) while the app was still running.
  final VoidCallback onTap;

  final _plugin = FlutterLocalNotificationsPlugin();
  Future<bool>? _ready;
  bool _asked = false;

  static const _alertId = 9001;
  static const _countdownId = 9002;

  /// iOS shows buttons per category, registered up front, so the title can't hold the values;
  /// the notification text shows them instead.
  static const _iosLogCategory = 'rest_log';

  /// The app's accent on the logo (ic_stat_fitplan, the app icon as a silhouette) and the buttons.
  static const _brand = Color(0xFF36D6C5);

  static AndroidNotificationDetails _androidAlert(RestTimer timer) => AndroidNotificationDetails(
        'rest_timer',
        'Rest timer',
        channelDescription: 'Tells you when your rest between sets is over.',
        importance: Importance.high,
        priority: Priority.high,
        category: AndroidNotificationCategory.alarm,
        icon: 'ic_stat_fitplan',
        color: _brand,
        actions: [
          if (timer.upNext case final set?)
            AndroidNotificationAction(RestActionIds.logSet, RestTexts.logButton(set)),
        ],
      );

  static AndroidNotificationDetails _androidCountdown(RestTimer timer, DateTime now) => AndroidNotificationDetails(
        'rest_countdown',
        'Rest countdown',
        channelDescription: 'Shows the rest counting down while you are outside the app.',
        importance: Importance.low,
        priority: Priority.low,
        icon: 'ic_stat_fitplan',
        color: _brand,
        // shrinks like the bar in the app: full at the start, empty at the end
        showProgress: true,
        maxProgress: timer.total.inSeconds,
        progress: timer.secondsLeft(now),
        ongoing: true,
        autoCancel: false,
        onlyAlertOnce: true,
        silent: true,
        showWhen: true,
        when: timer.endsAt.millisecondsSinceEpoch,
        usesChronometer: true,
        chronometerCountDown: true,
        // gone at the end, when "Rest is over" takes its place
        timeoutAfter: timer.endsAt.difference(now).inMilliseconds,
        category: AndroidNotificationCategory.progress,
        actions: const [
          AndroidNotificationAction(RestActionIds.addTime, '+30 s', cancelNotification: false),
          AndroidNotificationAction(RestActionIds.skip, 'Skip rest'),
        ],
      );

  static DarwinNotificationDetails _ios(RestTimer timer) => DarwinNotificationDetails(
        // time-sensitive would need an Apple capability the free Apple ID build doesn't have
        presentSound: true,
        categoryIdentifier: timer.upNext == null ? null : _iosLogCategory,
      );

  static bool get _android => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  static bool get _supported => _android || (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS);

  /// Failures are ignored everywhere: the timer in the app keeps working without notifications.
  Future<bool> _init() => _ready ??= () async {
        if (!_supported) return false;
        try {
          await _plugin.initialize(
            settings: InitializationSettings(
              android: const AndroidInitializationSettings('ic_stat_fitplan'),
              // asked at the first rest instead, see askPermission
              iOS: DarwinInitializationSettings(
                requestAlertPermission: false,
                requestBadgePermission: false,
                requestSoundPermission: false,
                notificationCategories: [
                  DarwinNotificationCategory(
                    _iosLogCategory,
                    actions: [
                      // unlocked first: the phone's saved data can't be read while it is locked
                      DarwinNotificationAction.plain(
                        RestActionIds.logSet,
                        'Log set',
                        options: {DarwinNotificationActionOption.authenticationRequired},
                      ),
                    ],
                  ),
                ],
              ),
            ),
            onDidReceiveNotificationResponse: (response) {
              if (response.notificationResponseType == NotificationResponseType.selectedNotification) onTap();
            },
            onDidReceiveBackgroundNotificationResponse: onRestNotificationAction,
          );
          return true;
        } catch (_) {
          return false;
        }
      }();

  @override
  Future<void> askPermission() async {
    if (_asked || !await _init()) return;
    _asked = true;
    try {
      await _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      await _plugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, sound: true);
    } catch (_) {}
  }

  @override
  Future<void> show(RestTimer timer) async {
    if (!await _init()) return;
    final now = DateTime.now();
    if (timer.secondsLeft(now) == 0) return cancel();
    try {
      // on the second when the user allows exact alarms (Android), otherwise as close as Android allows
      final exact = await _plugin
              .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
              ?.canScheduleExactNotifications() ??
          true;
      await _plugin.zonedSchedule(
        id: _alertId,
        title: RestTexts.alertTitle,
        body: RestTexts.alertBody(timer),
        payload: timer.upNext?.encode(),
        // an absolute moment, so the phone's time zone doesn't matter
        scheduledDate: tz.TZDateTime.from(timer.endsAt.toUtc(), tz.UTC),
        notificationDetails: NotificationDetails(android: _androidAlert(timer), iOS: _ios(timer)),
        androidScheduleMode: exact ? AndroidScheduleMode.exactAllowWhileIdle : AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (_) {}
    await updateCountdown(timer);
  }

  @override
  Future<void> updateCountdown(RestTimer timer) async {
    if (!_android || !await _init()) return;
    final now = DateTime.now();
    if (timer.secondsLeft(now) == 0) return;
    try {
      await _plugin.show(
        id: _countdownId,
        title: RestTexts.countdownTitle,
        body: RestTexts.countdownBody(timer),
        notificationDetails: NotificationDetails(android: _androidCountdown(timer, now)),
      );
    } catch (_) {}
  }

  static const _live = MethodChannel('fitplan/rest_activity');

  static bool get _onIphone => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  @override
  Future<void> showLive(RestTimer timer) async {
    if (!_onIphone || timer.secondsLeft(DateTime.now()) == 0) return;
    try {
      await _live.invokeMethod<bool>('show', {
        'startedAtMs': timer.endsAt.subtract(timer.total).millisecondsSinceEpoch,
        'endsAtMs': timer.endsAt.millisecondsSinceEpoch,
        'next': RestTexts.alertBody(timer),
      });
    } catch (_) {
      // older iPhone, Live Activities turned off, or a build without the extension
    }
  }

  @override
  Future<void> endLive() async {
    if (!_onIphone) return;
    try {
      await _live.invokeMethod<void>('end');
    } catch (_) {}
  }

  @override
  Future<void> cancel() async {
    if (!await _init()) return;
    try {
      await _plugin.cancel(id: _alertId);
      if (_android) await _plugin.cancel(id: _countdownId);
    } catch (_) {}
  }
}

final restNotifierProvider = Provider<RestNotifier>((ref) {
  return LocalRestNotifier(onTap: () {
    // open the workout, unless it is already on screen
    final router = ref.read(routerProvider);
    if (router.routerDelegate.currentConfiguration.uri.path != Routes.session) router.push(Routes.session);
  });
});

final pendingSetsStoreProvider = Provider<PendingSetsStore>((ref) => PendingSetsStore(const FlutterSecureStorage()));
