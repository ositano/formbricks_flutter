
# Formbricks Flutter SDK
[![Pub](https://img.shields.io/pub/v/formbricks_flutter.svg)](https://pub.dartlang.org/packages/formbricks_flutter)

[//]: # ([![Build]&#40;https://img.shields.io/github/actions/workflow/status/wiredashio/wiredash-sdk/nightly.yaml?branch=stable&#41;]&#40;https://github.com/wiredashio/wiredash-sdk/actions&#41;)
[![Pub Likes](https://img.shields.io/pub/likes/formbricks_flutter)](https://pub.dev/packages/formbricks_flutter/score)
[![Popularity](https://img.shields.io/pub/popularity/formbricks_flutter)](https://pub.dev/packages/formbricks_flutter/score)
[![Pub points](https://img.shields.io/pub/points/formbricks_flutter)](https://pub.dev/packages/formbricks_flutter/score)

[//]: # ([![Website]&#40;https://img.shields.io/badge/website-wiredash.com-blue.svg&#41;]&#40;https://wiredash.com/&#41;)

**Formbricks Flutter** lets you easily integrate beautiful, customizable, in-product formbricks **micro-surveys** directly into your Flutter apps. Collect user feedback where it matters most — inside your product. 💬📲

Built on top of [Formbricks](https://formbricks.com) — the open-source experience management platform — this SDK offers all the flexibility you need to launch surveys, collect analytics, and adapt the UI to match your brand. 🎯

---

<img width="830" alt="Formbricks_flutter_screenshot" src="https://github.com/ositano/formbricks_flutter/blob/master/screenshot.png">

## ✨ Features

| Feature                          | Description                                                                                                              |
|----------------------------------|--------------------------------------------------------------------------------------------------------------------------|
| 💬 **In-App Micro-Surveys**      | Display beautiful, embeddable surveys inside your app using flutter implementation.                                      |
| 💬 **Webview Micro-Surveys**     | Display beautiful, embeddable surveys inside your app using formbricks browser.                                          |
| 🌐 **Localization Support**      | Built-in support for multiple languages: `en`, `es`, `de`, `fr`, `ja`, `ar`, `pt`, `sw`, `zh`.                           |
| ⚡ **Custom Triggers**            | Trigger surveys based on app events.                                                                                     |
| 🎨 **Theme Customization**       | Use Formbricks styling or fallback to Style surveys using your app’s `ThemeData`. or use a different custom theme for it |
| 🙋‍♂️ **User Targeting**         | Pass `userId` and `userAttributes` to personalize surveys.                                                               |
| 🪟 **Multiple Display Modes**    | Show In-App surveys in `fullScreen`, `dialog`, or `bottomSheet` views.                                                   |
| 🧱 **Custom Question Widgets**   | Override default widgets with your own beautiful UI.                                                                     |
| ⏱ **Estimated Completion Time**  | Automatically calculated time to inform users.                                                                           |
| 🔐 **Secure API Integration**    | Connect with the Formbricks API using your API key and environment ID.                                                   |
| 🧪 **Dev Mode Toggle**           | Enable/disable development mode for previewing surveys.                                                                  |

---

## 🚀 Installation

Add `formbricks_flutter` to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  formbricks_flutter: ^0.0.1 #Replace with the latest version
```

---

## 🛠 Usage

Wrap your app (or section of it) with the `FormbricksProvider`:

```dart
FormbricksProvider(
  client: FormbricksClient(
    apiHost: 'https://app.formbricks.com',
    environmentId: 'your-env-id',
    apiKey: 'your-api-key',
    isDev: false,
    useV2: false
  ),
  userId: 'user-123',
  surveyPlatform: SurveyPlatform.inApp,
  surveyDisplayMode: SurveyDisplayMode.fullScreen,
  child: const HomeScreen(),
);
```

---

## 📦 Customization Options

You can define custom theme or override any survey question widget using FormbricksFlutterConfig.
Note: custom theme works only if _overwriteThemeStyling_ property of the survey is set to false

```dart
FormbricksProvider(
    // required declarations
    ...
    formbricksFlutterConfig: FormbricksFlutterConfig(
        customTheme: ThemeData(
            textTheme: TextTheme(
                headlineMedium: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            )
        ),
        freeTextQuestionBuilder: (key, question, onResponse, response, requiredByLogicCondition, {formbricksClient, surveyId}){
          return CustomFreeTextWidget(question: question, onResponse: onResponse, response: response, requiredByLogicCondition: requiredByLogicCondition);
        },
        // Other overrides: addressQuestionBuilder, dateQuestionBuilder, etc.
        ...
    ),
)
```


Sets the current user’s unique identifier (e.g., user ID or email).
```dart
  Formbricks.instance.setUserId("abc@xyz.com");
```

Sets or replaces the user’s attributes for segment filtering and targeting
```dart
  Formbricks.instance.setAttributes({"first_name": "Green", "last_name": "Onyeji"});
```

Adds or updates specific user attributes without replacing existing ones.
```dart
  Formbricks.instance.setAttribute({"location": "Abuja"});
```

Trigger any survey associated with that action
```dart
  Formbricks.instance.track(action: "download_button");
```

Sets the language code for surveys (e.g., "en", "de", "fr").
```dart
  Formbricks.instance.setLanguage("de");
```

Sets the survey platform (e.g., inApp, webView)
```dart
  Formbricks.instance.setSurveyPlatform(SurveyPlatform.inApp);
```

Sets how surveys should be displayed for inApp (e.g. fullscreen, dialog, bottomSheetModal)
```dart
  Formbricks.instance.setSurveyDisplayMode(SurveyDisplayMode.fullScreen);
```

---

## 🧪 Supported Question Types

Formbricks currently supports the following input types:
- 📍 `address`
- 📅 `cal`
- ✅ `consent`
- 👤 `contact`
- 🪄 `cta`
- 📅 `date`
- 📁 `file upload`
- 📝 `freeText`
- 📊 `matrix`
- 🧩 `multipleChoiceMulti`
- 🔘 `multipleChoiceSingle`
- 📈 `nps`
- 🖼️ `pictureSelection`
- 🔢 `ranking`
- ⭐️ `rating`

And **you can override any of them** for full control.

---

## 📜 License

This SDK is released under the MIT License.

