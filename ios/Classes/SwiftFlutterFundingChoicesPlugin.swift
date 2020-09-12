import Flutter
import UIKit
import UserMessagingPlatform/UserMessagingPlatform

public class SwiftFlutterFundingChoicesPlugin: NSObject, FlutterPlugin {
  /// The channel method name.
  static let channelName: String = "flutter_funding_choices"

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: channelName, binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterFundingChoicesPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "discovery.stop":
        (browsers[id]?.delegate as! BonsoirServiceBrowserDelegate?)?.dispose()
        result(true)
    default:
        result(FlutterMethodNotImplemented)
    }
  }
}
