# Flutter Funding Choices

_Flutter Funding Choices_ is an unofficial Flutter implementation of Funding Choices,
a Google service that allows to request user consent for personalized ads in AdMob.

<img src="https://github.com/Skyost/FlutterFundingChoices/raw/master/screenshots/android.png" height="500">

## Prerequisites

You must have linked your FundingChoices account to your Admob account.
See [this documentation](https://support.google.com/fundingchoices/answer/9180084) on Google Support.

## Installation

### Android

Your app must use [Android Embedding V2](https://github.com/flutter/flutter/wiki/Upgrading-pre-1.12-Android-projects).
Also, you need to add an app id in your `AndroidManifest.xml` (in the `application` tag) :

```xml
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
   package="fr.skyost.example">

   <application
       <!--
         Some attributes here...
        -->
    >
       <meta-data
           android:name="com.google.android.gms.ads.APPLICATION_ID"
           android:value="YOUR-APP-ID"/>
       <!--
         Activities, ...
        -->
   </application>

</manifest>
```

You can obtain your app ID by following [these instructions](https://support.google.com/admob/answer/7356431).

### iOS

You need to add an app id in your `Info.plist` :

```xml
<key>GADApplicationIdentifier</key>
<string>YOUR-APP-ID</string>
```

You can obtain your app ID by following [these instructions](https://support.google.com/admob/answer/7356431).
You may also need to handle Apple's App Tracking Transparency message by putting this in your `Info.plist` :

```xml
<key>NSUserTrackingUsageDescription</key>
<string>This identifier will be used to deliver personalized ads to you.</string>
```

Feel free to configure the message as you want.

## How to use

There are three methods :

* `FlutterFundingChoices.requestConsentInformation()` : Allows to get current user consent information (whether you need to show the consent form, whether the user wants personalized ads, ...).
* `FlutterFundingChoices.showConsentForm()` : Loads and shows the consent form. You must check first that there is a consent form (with `isConsentFormAvailable` on the returned object of the previous method).
* `FlutterFundingChoices.reset()` : Resets the consent information.

You typically want to use it like this on Android :

```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    ConsentInformation consentInfo = await FlutterFundingChoices.requestConsentInformation();
    if (consentInfo.isConsentFormAvailable && consentInfo.consentStatus == ConsentStatus.REQUIRED_ANDROID) {  
      await FlutterFundingChoices.showConsentForm();
      // You can check the result by calling `FlutterFundingChoices.requestConsentInformation()` again !
    }
  });
}
```

Feel free to replace `ConsentStatus.REQUIRED_ANDROID` by `ConsentStatus.REQUIRED_IOS` if you're on iOS.

## Contributions

You have a lot of options to contribute to this project ! You can :

* [Fork it](https://github.com/Skyost/FlutterFundingChoices/fork) on Github.
* [Submit](https://github.com/Skyost/FlutterFundingChoices/issues/new/choose) a feature request or a bug report.
* [Donate](https://paypal.me/Skyost) to the developer.
