import 'dart:async';

import 'package:flutter/services.dart';

/// The main plugin class.
class FlutterFundingChoices {
  /// The method channel.
  static const MethodChannel _channel =
      const MethodChannel('flutter_funding_choices');

  /// Allows to get the current consent information.
  ///
  /// [tagForUnderAgeOfConsent] Whether to tag for under age of consent.
  /// [testDevicesHashedIds] Provide test devices id in order to force geography to the EEA.
  /// [debugGeography] Force geography to be in EEA or not EEA. Default value is [DebugGeography.DEBUG_GEOGRAPHY_DISABLED].
  static Future<ConsentInformation> requestConsentInformation({
    bool tagForUnderAgeOfConsent = false,
    List<String> testDevicesHashedIds = const <String>[],
    int debugGeography = DebugGeography.DEBUG_GEOGRAPHY_DISABLED,
  }) async {
    Map<String, dynamic> result = Map<String, dynamic>.from(
      (await _channel.invokeMethod(
            'requestConsentInformation',
            {
              'tagForUnderAgeOfConsent': tagForUnderAgeOfConsent,
              'testDevicesHashedIds': testDevicesHashedIds,
              'debugGeography': debugGeography,
            },
          )) ?? // If null default to unknown.
          {
            "consentStatus": ConsentStatus.UNKNOWN,
            "isConsentFormAvailable": false,
          },
    );
    return ConsentInformation(
      consentStatus: result['consentStatus'],
      isConsentFormAvailable: result['isConsentFormAvailable'],
    );
  }

  /// Shows the consent form.
  static Future<bool> showConsentForm() async =>
      (await _channel.invokeMethod('showConsentForm')) ?? false;

  /// Resets the user consent information.
  /// Must be requested using [requestConsentInformation] before.
  static Future<bool> reset() async =>
      (await _channel.invokeMethod('reset')) ?? false;
}

/// Contains all possible information about user consent state.
class ConsentInformation {
  /// The consent status. See [ConsentStatus].
  final int consentStatus;

  /// Whether a consent form is available to show.
  final bool isConsentFormAvailable;

  /// Creates a new consent information instance.
  const ConsentInformation({
    required this.consentStatus,
    required this.isConsentFormAvailable,
  });
}

/// Contains all possible consent status.
class ConsentStatus {
  /// Consent status is unknown.
  static const int UNKNOWN = 0;

  /// Consent is not required for this user (Android).
  static const int NOT_REQUIRED_ANDROID = 1;

  /// Consent is required for this user (Android).
  static const int REQUIRED_ANDROID = 2;

  /// Consent is not required for this user (iOS).
  static const int NOT_REQUIRED_IOS = 2;

  /// Consent is required for this user (iOS).
  static const int REQUIRED_IOS = 1;

  /// Consent has been obtained for this user.
  static const int OBTAINED = 3;
}

/// Contains all possible debugGeography values.
class DebugGeography {
  /// Debug geography disabled. Default value.
  static const int DEBUG_GEOGRAPHY_DISABLED = 0;

  /// Geography appears as in EEA for debug devices.
  static const int DEBUG_GEOGRAPHY_EEA = 1;

  /// Geography appears as not in EEA for debug devices.
  static const int DEBUG_GEOGRAPHY_NOT_EEA = 2;
}
