<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

# Formbricks_flutter

Formbricks_flutter allows you to integrate in-product micro-surveys and forms into your applications, enhancing user experience and gathering valuable feedback. 🚀 This package provides a customizable solution to display surveys and manage triggers, built with Flutter and Dart.

Formbricks is a versatile open-source platform for collecting and analyzing feedback from customers, users, and employees through targeted surveys. Whether you need simple forms or complex experience management solutions, Formbricks scales with your needs.

For more information, visit [formbricks.com](https://formbricks.com).

## Features

In-App Surveys: Display micro-surveys seamlessly within your Flutter app.

Localization: Support for multiple languages  (ar, en, es, fr, ja, pt, sw, zh).

Custom Triggers: Define survey triggers based on user actions or conditions.

Theme Customization: Apply a custom ThemeData to match your app's design.

User Attributes: Pass user-specific data for targeted surveys.

Display Mode: Define whether to use fullscreen, dialog or bottom sheet modal.

Question Customization: Don't like the default question widgets? You can build yours.

## Installation

Add the Formbricks_flutter to your `pubspec.yaml` file:

```yaml
dependencies:
  flutter:
    sdk: flutter
  formbricks_flutter: ^x.y.z # Replace with the latest version
```
## Usage
```dart

    FormBricksProvider(
        showPoweredBy: true,
        client: FormBricksClient(
          apiHost: 'https://app.formbricks.com',
          environmentId: 'xxxxxx',
          apiKey: 'xxxxx',
          isDev: false,
          ),
        userId: 'us070',
        userAttributes: {'isPremium': true},
        surveyDisplayMode: SurveyDisplayMode.fullScreen,
        useWrapInRankingQuestion: false,
        triggers: [
          TriggerValue(type: TriggerType.noCode, name: 'Clicked Farmer'),
          TriggerValue(type: TriggerType.code, key: 'click_to_download'),
        ],
        customTheme: ThemeData(
          primaryColor: Colors.teal,
          textTheme: const TextTheme(
            headlineMedium: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            bodyMedium: TextStyle(fontSize: 12),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.teal),
              foregroundColor: WidgetStateProperty.all(Colors.white),
            ),
          ),
          ),
        child: const HomeScreen(),
    )
```

## License
This package is licensed under the AGPLv3 Open Source License. You can use it for 
personal and commercial purposes. Modified versions must be distributed under the same 
license. See the LICENSE file for details.
