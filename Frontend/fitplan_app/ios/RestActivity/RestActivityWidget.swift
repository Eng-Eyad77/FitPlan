import ActivityKit
import SwiftUI
import WidgetKit

@main
struct RestActivityBundle: WidgetBundle {
  var body: some Widget {
    RestActivityWidget()
  }
}

/// The app's colours, as in lib/core/theme/app_colors.dart.
private enum Brand {
  static let accent = Color(red: 0x36 / 255, green: 0xD6 / 255, blue: 0xC5 / 255)
  static let background = Color(red: 0x10 / 255, green: 0x17 / 255, blue: 0x19 / 255)
}

/// The FitPlan logo, bundled with the extension.
private struct Logo: View {
  var size: CGFloat
  var body: some View {
    if let image = UIImage(named: "rest_logo") {
      Image(uiImage: image).resizable().scaledToFit().frame(width: size, height: size)
    } else {
      Image(systemName: "timer").foregroundColor(Brand.accent)
    }
  }
}

/// The system counts these down by itself, also while the app is closed.
private func countdown(_ state: RestActivityAttributes.ContentState) -> Text {
  Text(timerInterval: state.startedAt...max(state.startedAt, state.endsAt), countsDown: true)
}

/// "-15s", "+15s" and "Skip", as on the bar in the app. iOS 17+; older phones show the countdown only.
private struct RestButtons: View {
  let skipLabel: String

  var body: some View {
    if #available(iOS 17.0, *) {
      HStack(spacing: 8) {
        Button(intent: RemoveRestTimeIntent()) {
          Text("-15s").font(.subheadline.weight(.semibold)).frame(maxWidth: .infinity)
        }
        .tint(Brand.accent)
        Button(intent: SkipRestIntent()) {
          Text(skipLabel).font(.subheadline.weight(.semibold)).frame(maxWidth: .infinity)
        }
        .tint(.white.opacity(0.35))
        Button(intent: AddRestTimeIntent()) {
          Text("+15s").font(.subheadline.weight(.semibold)).frame(maxWidth: .infinity)
        }
        .tint(Brand.accent)
      }
      // the same order in both languages: -15 left, Skip middle, +15 right
      .environment(\.layoutDirection, .leftToRight)
      .buttonStyle(.bordered)
    }
  }
}

/// The app's language decides the direction, not the phone's.
private func direction(_ state: RestActivityAttributes.ContentState) -> LayoutDirection {
  state.rtl == true ? .rightToLeft : .leftToRight
}

private func progress(_ state: RestActivityAttributes.ContentState) -> some View {
  ProgressView(timerInterval: state.startedAt...max(state.startedAt, state.endsAt), countsDown: true) {
    EmptyView()
  } currentValueLabel: {
    EmptyView()
  }
  .tint(Brand.accent)
}

struct RestActivityWidget: Widget {
  var body: some WidgetConfiguration {
    ActivityConfiguration(for: RestActivityAttributes.self) { context in
      // Lock Screen, and the banner on iPhones without a Dynamic Island
      VStack(alignment: .leading, spacing: 10) {
        HStack(spacing: 10) {
          Logo(size: 28)
          Text(context.state.title).font(.headline).foregroundColor(.white)
          Spacer()
          countdown(context.state)
            .font(.system(size: 30, weight: .semibold, design: .rounded).monospacedDigit())
            .foregroundColor(Brand.accent)
            .multilineTextAlignment(.trailing)
            .frame(maxWidth: 110, alignment: .trailing)
        }
        progress(context.state)
        Text(context.state.nextLine)
          .font(.subheadline)
          .foregroundColor(.white.opacity(0.75))
          .lineLimit(1)
        RestButtons(skipLabel: context.state.skipLabel)
      }
      .padding(16)
      .environment(\.layoutDirection, direction(context.state))
      .activityBackgroundTint(Brand.background)
      .activitySystemActionForegroundColor(Brand.accent)
    } dynamicIsland: { context in
      DynamicIsland {
        DynamicIslandExpandedRegion(.leading) {
          HStack(spacing: 6) {
            Logo(size: 22)
            Text(context.state.title).font(.headline)
          }
          .environment(\.layoutDirection, direction(context.state))
        }
        DynamicIslandExpandedRegion(.trailing) {
          countdown(context.state)
            .font(.title2.monospacedDigit())
            .foregroundColor(Brand.accent)
            .multilineTextAlignment(.trailing)
            .frame(maxWidth: 90, alignment: .trailing)
        }
        DynamicIslandExpandedRegion(.bottom) {
          VStack(alignment: .leading, spacing: 6) {
            progress(context.state)
            Text(context.state.nextLine).font(.subheadline).lineLimit(1)
            RestButtons(skipLabel: context.state.skipLabel)
          }
          .environment(\.layoutDirection, direction(context.state))
        }
      } compactLeading: {
        Logo(size: 18)
      } compactTrailing: {
        countdown(context.state)
          .monospacedDigit()
          .foregroundColor(Brand.accent)
          .frame(maxWidth: 44)
      } minimal: {
        Logo(size: 18)
      }
      .keylineTint(Brand.accent)
    }
  }
}
