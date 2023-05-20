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
  bool consentInfoRetrieved = false;

  /// The current consent info.
  late ConsentInformation consentInfo;

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
          body: !consentInfoRetrieved
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
          'Is consent form available ? ' + (consentInfo.isConsentFormAvailable ? 'Yes' : 'No') + '.',
          textAlign: TextAlign.center,
        ),
        if (consentInfo.isConsentFormAvailable && consentInfo.consentStatus == ConsentStatus.required)
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
    ConsentInformation consentInfo = await FlutterFundingChoices.requestConsentInformation();
    setState(() {
      consentInfoRetrieved = true;
      this.consentInfo = consentInfo;
    });
  }

  /// Converts a consent status to a human-readable string.
  String get consentStatusString {
    if (consentInfo.consentStatus == ConsentStatus.obtained) {
      return 'Obtained';
    }
    if (consentInfo.consentStatus == ConsentStatus.notRequired) {
      return 'Not required';
    }
    if (consentInfo.consentStatus == ConsentStatus.required) {
      return 'Required';
    }
    return 'Unknown';
  }
}
