import ActivityKit
import AppIntents
import Foundation
import UserNotifications

// The "+15s" and "Skip" buttons on the Lock Screen countdown (iOS 17+).
// Compiled into the app and the widget extension; iOS runs them in the app's process, in the
// background, without opening the app. They change the countdown and the "Rest is over"
// notification right away, and leave a note the app reads when it runs again
// (channel "fitplan/rest_activity", method "takeChange").

@available(iOS 17.0, *)
struct AddRestTimeIntent: LiveActivityIntent {
  static var title: LocalizedStringResource = "Add 15 seconds to the rest"
  static var isDiscoverable: Bool = false

  init() {}

  func perform() async throws -> some IntentResult {
    await RestActivityControl.addTime(RestActivityControl.addedSeconds)
    return .result()
  }
}

@available(iOS 17.0, *)
struct SkipRestIntent: LiveActivityIntent {
  static var title: LocalizedStringResource = "Skip the rest"
  static var isDiscoverable: Bool = false

  init() {}

  func perform() async throws -> some IntentResult {
    await RestActivityControl.skip()
    return .result()
  }
}

@available(iOS 17.0, *)
enum RestActivityControl {
  static let addedSeconds: TimeInterval = 15

  /// The note for the app: {"endsAtMs": …} after +15s, {"skip": true} after Skip.
  static let changeKey = "fitplan.restActivity.change"

  /// The id flutter_local_notifications gives "Rest is over" (9001 in rest_notifications.dart).
  static let alertId = "9001"

  static func addTime(_ seconds: TimeInterval) async {
    guard let activity = Activity<RestActivityAttributes>.activities.first else { return }
    var state = activity.content.state
    // after the end, the new rest counts from now
    state.endsAt = max(state.endsAt, Date()).addingTimeInterval(seconds)
    await activity.update(ActivityContent(state: state, staleDate: nil))
    UserDefaults.standard.set(["endsAtMs": state.endsAt.timeIntervalSince1970 * 1000], forKey: changeKey)
    await moveAlert(to: state.endsAt)
  }

  static func skip() async {
    for activity in Activity<RestActivityAttributes>.activities {
      await activity.end(nil, dismissalPolicy: .immediate)
    }
    UserDefaults.standard.set(["skip": true], forKey: changeKey)
    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [alertId])
  }

  /// Hands the note to the app once.
  static func takeChange() -> [String: Any]? {
    let change = UserDefaults.standard.dictionary(forKey: changeKey)
    UserDefaults.standard.removeObject(forKey: changeKey)
    return change
  }

  /// Same notification, new time.
  private static func moveAlert(to date: Date) async {
    let center = UNUserNotificationCenter.current()
    let pending = await center.pendingNotificationRequests()
    guard let alert = pending.first(where: { $0.identifier == alertId }) else { return }
    center.removePendingNotificationRequests(withIdentifiers: [alertId])
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(1, date.timeIntervalSinceNow), repeats: false)
    try? await center.add(UNNotificationRequest(identifier: alertId, content: alert.content, trigger: trigger))
  }
}
