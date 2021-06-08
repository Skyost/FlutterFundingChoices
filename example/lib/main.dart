import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_funding_choices/flutter_funding_choices.dart';

/// Hello world !
void main() {
  runApp(_ExampleApp());
}

/// Our main widget.
class _ExampleApp extends StatefulWidget {
  @override
  _ExampleAppState createState() => _ExampleAppState();
}

/// Our main widget state.
class _ExampleAppState extends State<_ExampleApp> {
  /// The current consent info.
  ConsentInformation consentInfo;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await refreshConsentInfo();
    });
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Flutter Funding Choices'),
          ),
          body: consentInfo == null
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: buildChildren(),
                  ),
                ),
        ),
      );

  /// Builds the column children.
  List<Widget> buildChildren() => [
        Text(
          'Consent status : $consentStatusString.',
          textAlign: TextAlign.center,
        ),
        Text(
          'Is consent form available ? ' +
              (consentInfo.isConsentFormAvailable ? 'Yes' : 'No') +
              '.',
          textAlign: TextAlign.center,
        ),
        if (consentInfo.isConsentFormAvailable &&
            ((Platform.isAndroid &&
                    consentInfo.consentStatus ==
                        ConsentStatus.REQUIRED_ANDROID) ||
                (Platform.isIOS &&
                    consentInfo.consentStatus == ConsentStatus.REQUIRED_IOS)))
          ElevatedButton(
            child: Text('Show consent form'),
            onPressed: () async {
              await FlutterFundingChoices.showConsentForm();
              await refreshConsentInfo();
            },
          ),
        ElevatedButton(
          child: Text('Reset'),
          onPressed: () async {
            await FlutterFundingChoices.reset();
            await refreshConsentInfo();
          },
        ),
      ];

  /// Refreshes the current consent info.
  Future<void> refreshConsentInfo() async {
    ConsentInformation consentInfo =
        await FlutterFundingChoices.requestConsentInformation();
    setState(() => this.consentInfo = consentInfo);
  }

  /// Converts a consent status to a human-readable string.
  String get consentStatusString {
    if (consentInfo.consentStatus == ConsentStatus.OBTAINED) {
      return 'Obtained';
    }
    if (Platform.isAndroid) {
      if (consentInfo.consentStatus == ConsentStatus.NOT_REQUIRED_ANDROID) {
        return 'Not required';
      }
      if (consentInfo.consentStatus == ConsentStatus.REQUIRED_ANDROID) {
        return 'Required';
      }
    } else if (Platform.isIOS) {
      if (consentInfo.consentStatus == ConsentStatus.NOT_REQUIRED_IOS) {
        return 'Not required';
      }
      if (consentInfo.consentStatus == ConsentStatus.REQUIRED_IOS) {
        return 'Required';
      }
    }
    return 'Unknown';
  }
}
