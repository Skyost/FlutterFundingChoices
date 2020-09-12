import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// The main plugin class.
class FlutterFundingChoices {
  /// The method channel.
  static const MethodChannel _channel = const MethodChannel('flutter_funding_choices');

  /// Allows to get the current consent information.
  static Future<ConsentInformation> requestConsentInformation({bool tagForUnderAgeOfConsent = false}) async {
    Map<String, dynamic> result = Map<String, dynamic>.from(await _channel.invokeMethod('requestConsentInformation', {'tagForUnderAgeOfConsent': tagForUnderAgeOfConsent}));
    return ConsentInformation(
      consentStatus: result['consentStatus'],
      consentType: result['consentType'],
      isConsentFormAvailable: result['isConsentFormAvailable'],
    );
  }

  /// Shows the consent form.
  static Future<bool> showConsentForm() => _channel.invokeMethod('showConsentForm');

  /// Resets the user consent information.
  /// Must be requested using [requestConsentInformation] before.
  static Future<bool> reset() => _channel.invokeMethod('reset');
}

/// Contains all possible information about user consent state.
class ConsentInformation {
  /// The consent status. See [ConsentStatus].
  final int consentStatus;

  /// The consent type. See [ConsentType].
  final int consentType;

  /// Whether a consent form is available to show.
  final bool isConsentFormAvailable;

  /// Creates a new consent information instance.
  const ConsentInformation({
    @required this.consentStatus,
    @required this.consentType,
    @required this.isConsentFormAvailable,
  });
}

/// Contains all possible consent status.
class ConsentStatus {
  /// Consent status is unknown.
  static const int UNKNOWN = 0;

  /// Consent is not required for this user.
  static const int NOT_REQUIRED = 1;

  /// Consent is required for this user.
  static const int REQUIRED = 2;

  /// Consent has been obtained for this user.
  static const int OBTAINED = 3;
}

/// Contains all possible consent type.
class ConsentType {
  /// Unknown consent type.
  static const int UNKNOWN = 0;

  /// The user doesn't want personalized ads.
  static const int NON_PERSONALIZED = 1;

  /// The user wants personalized ads.
  static const int PERSONALIZED = 2;
}
