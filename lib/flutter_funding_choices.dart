import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

/// The main plugin class.
class FlutterFundingChoices {
  /// The method channel.
  static const MethodChannel _channel = MethodChannel('flutter_funding_choices');

  /// Allows to get the current consent information.
  ///
  /// [tagForUnderAgeOfConsent] Whether to tag for under age of consent.
  /// [testDevicesHashedIds] Provide test devices id in order to force geography to the EEA.
  /// [debugGeography] Force geography to be in EEA or not EEA. Default value is [DebugGeography.DEBUG_GEOGRAPHY_DISABLED].
  static Future<ConsentInformation> requestConsentInformation({
    bool tagForUnderAgeOfConsent = false,
    List<String> testDevicesHashedIds = const <String>[],
    DebugGeography debugGeography = DebugGeography.debugGeographyDisabled,
    bool? isAndroid,
  }) async {
    Map<String, dynamic> result = Map<String, dynamic>.from(
      (await _channel.invokeMethod(
            'requestConsentInformation',
            {
              'tagForUnderAgeOfConsent': tagForUnderAgeOfConsent,
              'testDevicesHashedIds': testDevicesHashedIds,
              'debugGeography': debugGeography.value,
            },
          )) ?? // If null default to unknown.
          {
            'consentStatus': ConsentStatus.unknown,
            'isConsentFormAvailable': false,
          },
    );
    return ConsentInformation(
      consentStatus: ConsentStatus.fromValue(result['consentStatus'], isAndroid ?? Platform.isAndroid),
      isConsentFormAvailable: result['isConsentFormAvailable'],
    );
  }

  /// Shows the consent form.
  static Future<bool> showConsentForm() async => (await _channel.invokeMethod('showConsentForm')) ?? false;

  /// Resets the user consent information.
  /// Must be requested using [requestConsentInformation] before.
  static Future<bool> reset() async => (await _channel.invokeMethod('reset')) ?? false;
}

/// Contains all possible information about user consent state.
class ConsentInformation {
  /// The consent status. See [ConsentStatus].
  final ConsentStatus consentStatus;

  /// Whether a consent form is available to show.
  final bool isConsentFormAvailable;

  /// Creates a new consent information instance.
  const ConsentInformation({
    required this.consentStatus,
    required this.isConsentFormAvailable,
  });
}

/// Contains all possible consent status.
enum ConsentStatus {
  /// Consent status is unknown.
  unknown.oneValue(value: 0),

  /// Consent is not required for this user.
  notRequired(androidValue: 1, iosValue: 2),

  /// Consent is required for this user.
  required(androidValue: 2, iosValue: 1),

  /// Consent has been obtained for this user.
  obtained.oneValue(value: 0);

  /// The Android value.
  final int androidValue;

  /// The iOS value.
  final int iosValue;

  /// Creates a new consent status instance.
  const ConsentStatus({
    required this.androidValue,
    required this.iosValue,
  });

  /// Creates a new consent status instance.
  const ConsentStatus.oneValue({
    required int value,
  }) : this(
          androidValue: value,
          iosValue: value,
        );

  /// Returns the consent status associated with the specified value.
  static ConsentStatus fromValue(int value, bool isAndroid) => values.firstWhere((status) => (isAndroid ? status.androidValue : status.iosValue) == value);
}

/// Contains all possible debugGeography values.
enum DebugGeography {
  /// Debug geography disabled. Default value.
  debugGeographyDisabled(value: 0),

  /// Geography appears as in EEA for debug devices.
  debugGeographyEea(value: 1),

  /// Geography appears as not in EEA for debug devices.
  debugGeographyNotEea(value: 2);

  /// The value.
  final int value;

  /// Creates a new consent status instance.
  const DebugGeography({
    required this.value,
  });
}
