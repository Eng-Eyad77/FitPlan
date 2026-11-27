import Flutter
import UIKit
import UserNotifications
// for FlutterLocalNotificationsPlugin.setPluginRegistrantCallback
import flutter_local_notifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // flutter_local_notifications: lets the plugin handle taps on the "rest is over" notification
    UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    // the "Log set" button on the notification runs in a background isolate, which needs the plugins too
    FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { registry in
      GeneratedPluginRegistrant.register(with: registry)
      // so a button can also move the Lock Screen countdown on
      if let registrar = registry.registrar(forPlugin: "RestLiveActivity") {
        RestLiveActivity.register(with: registrar)
      }
    }
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    // the rest countdown on the Lock Screen and in the Dynamic Island (Phase 9C/9D)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "RestLiveActivity") {
      RestLiveActivity.register(with: registrar)
    }
  }
}
