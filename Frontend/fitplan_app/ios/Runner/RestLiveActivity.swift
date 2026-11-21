import ActivityKit
import Flutter
import Foundation

/// Lets Dart show the rest on the Lock Screen and in the Dynamic Island (Phase 9C/9D).
/// Channel "fitplan/rest_activity":
///   show {startedAtMs, endsAtMs, next} -> starts it, or updates the one running
///   end -> removes it
/// Answers false (nothing shown) on iOS before 16.1 or when Live Activities are off for the app.
final class RestLiveActivity: NSObject, FlutterPlugin {
  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "fitplan/rest_activity", binaryMessenger: registrar.messenger())
    registrar.addMethodCallDelegate(RestLiveActivity(), channel: channel)
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard #available(iOS 16.1, *) else {
      result(false)
      return
    }
    switch call.method {
    case "show":
      guard let args = call.arguments as? [String: Any],
            let started = (args["startedAtMs"] as? NSNumber)?.doubleValue,
            let ends = (args["endsAtMs"] as? NSNumber)?.doubleValue,
            let next = args["next"] as? String else {
        result(false)
        return
      }
      let startedAt = Date(timeIntervalSince1970: started / 1000)
      let state = RestActivityAttributes.ContentState(
        startedAt: startedAt,
        endsAt: max(startedAt, Date(timeIntervalSince1970: ends / 1000)),
        next: next
      )
      // Flutter wants its answer on the main thread
      Task { @MainActor in result(await RestActivities.show(state)) }
    case "end":
      Task { @MainActor in
        await RestActivities.endAll()
        result(nil)
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}

@available(iOS 16.1, *)
private enum RestActivities {
  static func show(_ state: RestActivityAttributes.ContentState) async -> Bool {
    let running = Activity<RestActivityAttributes>.activities
    if let current = running.first {
      await current.update(using: state)
      // only one at a time
      for extra in running.dropFirst() { await extra.end(dismissalPolicy: .immediate) }
      return true
    }
    guard ActivityAuthorizationInfo().areActivitiesEnabled else { return false }
    do {
      _ = try Activity.request(attributes: RestActivityAttributes(), contentState: state, pushType: nil)
      return true
    } catch {
      return false
    }
  }

  static func endAll() async {
    for activity in Activity<RestActivityAttributes>.activities {
      await activity.end(dismissalPolicy: .immediate)
    }
  }
}
