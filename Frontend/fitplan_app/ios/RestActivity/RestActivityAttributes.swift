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
    /// The texts in the app's language (Phase 11): "Resting", "Next: …" and "Skip", or their Arabic.
    var title: String
    var nextLine: String
    var skipLabel: String
    /// Right to left when the app is in Arabic. Optional, so a countdown started by an older app still decodes.
    var rtl: Bool?
  }
}
