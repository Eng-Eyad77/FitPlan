import ActivityKit
import Foundation

/// The rest countdown on the Lock Screen and in the Dynamic Island (Phase 9C/9D).
/// Compiled into both the app (which starts and updates it) and the widget extension (which draws it),
/// so both sides agree on the data.
@available(iOS 16.1, *)
struct RestActivityAttributes: ActivityAttributes {
  public struct ContentState: Codable, Hashable {
    /// When this rest started; the progress bar runs from here to `endsAt`.
    var startedAt: Date
    var endsAt: Date
    /// What comes next: "Squat · set 3 · 40 kg × 10", or "Time for your next exercise".
    var next: String
  }
}
