import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(
        name: "flutter_blue_ultra_example/config",
        binaryMessenger: controller.binaryMessenger
      )
      channel.setMethodCallHandler { call, result in
        guard call.method == "accessorySetupKitConfigured" else {
          result(FlutterMethodNotImplemented)
          return
        }

        let supports = Bundle.main.object(
          forInfoDictionaryKey: "NSAccessorySetupKitSupports"
        ) as? [String]
        result(supports?.contains("Bluetooth") == true)
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
