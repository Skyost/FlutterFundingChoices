import Flutter
import UIKit
import UserMessagingPlatform

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
        case "requestConsentInformation":
            let arguments: [String: Any?] = call.arguments as! [String: Any?]
            requestConsentInformation(tagForUnderAgeOfConsent: arguments["tagForUnderAgeOfConsent"] as! Bool, testDevicesHashedIds: (arguments["testDevicesHashedIds"] as? [String]) ?? [], debugGeography: (arguments["debugGeography"] as? [Int]) ?? UMPDebugGeography.disabled, result: result)
        case "showConsentForm": showConsentForm(result: result)
        case "reset":
            UMPConsentInformation.sharedInstance.reset()
            result(true)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    /// Requests the consent information.
    private func requestConsentInformation(tagForUnderAgeOfConsent: Bool, testDevicesHashedIds: [String], debugGeography: [Int], result: @escaping FlutterResult) {
        let params = UMPRequestParameters()
        params.tagForUnderAgeOfConsent = tagForUnderAgeOfConsent

        if (testDevicesHashedIds.count > 0) {
            let debugSettings = UMPDebugSettings()
            debugSettings.testDeviceIdentifiers = testDevicesHashedIds
            debugSettings.geography = debugGeography
            params.debugSettings = debugSettings
        }
        
        UMPConsentInformation.sharedInstance.requestConsentInfoUpdate(with: params) { error in
            if error == nil {
                var consentInfo: [String: Any] = [:]
                consentInfo["consentStatus"] = UMPConsentInformation.sharedInstance.consentStatus.rawValue
                consentInfo["isConsentFormAvailable"] = UMPConsentInformation.sharedInstance.formStatus == UMPFormStatus.available
                result(consentInfo)
            } else {
                result(FlutterError(code: "request_error", message: error!.localizedDescription, details: nil))
            }
        }
    }

    /// Shows the consent form.
    private func showConsentForm(result: @escaping FlutterResult) {
        let viewController = UIApplication.shared.keyWindow?.rootViewController
        if viewController == nil {
            result(FlutterError(code: "view_controller_error", message: "View controller is null.", details: nil))
            return
        }

        UMPConsentForm.load { form, error in
            if error == nil {
                form!.present(from: viewController!) { dismissError in
                    if dismissError == nil {
                        result(true)
                    } else {
                        result(FlutterError(code: "form_dismiss_error", message: dismissError!.localizedDescription, details: nil))
                    }
                }
            } else {
                result(FlutterError(code: "form_error", message: error!.localizedDescription, details: nil))
            }
        }
    }
}
