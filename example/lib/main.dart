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
          'Consent type : $consentTypeString.',
          textAlign: TextAlign.center,
        ),
        Text(
          'Is consent form available ? ' + (consentInfo.isConsentFormAvailable ? 'Yes' : 'No') + '.',
          textAlign: TextAlign.center,
        ),
        if (consentInfo.isConsentFormAvailable && consentInfo.consentStatus == ConsentStatus.REQUIRED)
          RaisedButton(
            child: Text('Show consent form'),
            onPressed: () async {
              await FlutterFundingChoices.showConsentForm();
              await refreshConsentInfo();
            },
          ),
        RaisedButton(
          child: Text('Reset'),
          onPressed: () async {
            await FlutterFundingChoices.reset();
            await refreshConsentInfo();
          },
        ),
      ];

  /// Refreshes the current consent info.
  Future<void> refreshConsentInfo() async {
    ConsentInformation consentInfo = await FlutterFundingChoices.requestConsentInformation();
    setState(() => this.consentInfo = consentInfo);
  }

  /// Converts a consent status to a human-readable string.
  String get consentStatusString {
    switch (consentInfo.consentStatus) {
      case ConsentStatus.NOT_REQUIRED:
        return 'Not required';
      case ConsentStatus.REQUIRED:
        return 'Required';
      case ConsentStatus.OBTAINED:
        return 'Obtained';
      default:
        return 'Unknown';
    }
  }

  /// Converts a consent type to a human-readable string.
  String get consentTypeString {
    switch (consentInfo.consentType) {
      case ConsentType.PERSONALIZED:
        return 'Personalized ads';
      case ConsentType.NON_PERSONALIZED:
        return 'Non personalized ads';
      default:
        return 'Unknown';
    }
  }
}
