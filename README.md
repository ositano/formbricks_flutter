
# Formbricks Flutter
[![Pub](https://img.shields.io/pub/v/formbricks_flutter.svg)](https://pub.dartlang.org/packages/formbricks_flutter)

[//]: # ([![Build]&#40;https://img.shields.io/github/actions/workflow/status/wiredashio/wiredash-sdk/nightly.yaml?branch=stable&#41;]&#40;https://github.com/wiredashio/wiredash-sdk/actions&#41;)
[![Pub Likes](https://img.shields.io/pub/likes/formbricks_flutter)](https://pub.dev/packages/formbricks_flutter/score)
[![Popularity](https://img.shields.io/pub/popularity/formbricks_flutter)](https://pub.dev/packages/formbricks_flutter/score)
[![Pub points](https://img.shields.io/pub/points/formbricks_flutter)](https://pub.dev/packages/formbricks_flutter/score)

[//]: # ([![Website]&#40;https://img.shields.io/badge/website-wiredash.com-blue.svg&#41;]&#40;https://wiredash.com/&#41;)

**Formbricks Flutter** lets you easily integrate beautiful, customizable, in-product formbricks **micro-surveys** directly into your Flutter apps. Collect user feedback where it matters most — inside your product. 💬📲

Built on top of [Formbricks](https://formbricks.com) — the open-source experience management platform — this SDK offers all the flexibility you need to launch surveys, collect analytics, and adapt the UI to match your brand. 🎯

---

<img width="830" alt="Wiredash Logo" src="https://github.com/wiredashio/wiredash-sdk/assets/1096485/37255958-2954-4fd4-8a43-82d3ba65a393"> <!-- 3x -->

## ✨ Features

| Feature | Description                                                                                                             |
|--------|-------------------------------------------------------------------------------------------------------------------------|
| 💬 **In-App Micro-Surveys** | Display beautiful, embeddable surveys inside your app.                                                                  |
| 🌐 **Localization Support** | Built-in support for multiple languages: `en`, `es`, `de`, `fr`, `ja`, `ar`, `pt`, `sw`, `zh`.                          |
| ⚡ **Custom Triggers** | Trigger surveys based on app events or coded conditions.                                                                |
| 🎨 **Theme Customization** | Use Formbricks styling or fallback to Style surveys using your app’s `ThemeData`. or use a different custom theme for it |
| 🙋‍♂️ **User Targeting** | Pass `userId` and `userAttributes` to personalize surveys.                                                              |
| 🪟 **Multiple Display Modes** | Show surveys in `fullScreen`, `dialog`, or `bottomSheet` views.                                                         |
| 🧱 **Custom Question Widgets** | Override default widgets with your own beautiful UI.                                                                    |
| 🧠 **Smart Completion Tracking** | Prevent duplicate displays with `displayOnce` logic.                                                                    |
| ⏱ **Estimated Completion Time** | Automatically calculated time to inform users.                                                                          |
| 🔐 **Secure API Integration** | Connect with the Formbricks API using your API key and environment ID.                                                  |
| 🧪 **Dev Mode Toggle** | Enable/disable development mode for previewing surveys.                                                                 |

---

## 🚀 Installation

Add `formbricks_flutter` to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  formbricks_flutter: ^x.y.z # 🔁 Replace with the latest version
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
  ),
  userId: 'user-123',
  userAttributes: {
    'isPremium': false,
    'location': 'Abuja',
  },
  surveyDisplayMode: SurveyDisplayMode.fullScreen,
  triggers: [
    TriggerValue(type: TriggerType.noCode, name: 'Green Farmers'),
    TriggerValue(type: TriggerType.code, key: 'myapp_users'),
  ],
  customTheme: ThemeData(
    primaryColor: Colors.teal,
    textTheme: const TextTheme(
      headlineMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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
);
```

---

## 📦 Customization Options

You can override any survey question widget using builder overrides:

```dart
FormbricksProvider(
  freeTextQuestionBuilder: (key, question, onResponse, response, requiredByLogicCondition){
    return CustomFreeTextWidget(question: question, onResponse: onResponse, response: response, requiredByLogicCondition: requiredByLogicCondition);
  },
  // Other overrides: addressQuestionBuilder, dateQuestionBuilder, etc.
  ...
)
```


Define user ID anywhere from your code
```dart
  Formbricks().setUserId(String userId);
```

Optionally, define user attributes anywhere from your code
```dart
  Formbricks().setUserAttribute(Map<String, dynamic> attributes);
```

Optionally, set Trigger Values if you don't want to define from the app level
```dart
  Formbricks().addTriggerValues(List<TriggerValue> triggerValues);
```

Change app locale
```dart
  Formbricks().setLocale(String locale);
```

Gets the currently active locale.
```dart
  Formbricks().currentLocale;
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

This package is licensed under the **AGPLv3** Open Source License.

You can use it **freely** for personal and commercial purposes.  
If you modify the code, you must also publish your changes under AGPLv3.  
See the [LICENSE](LICENSE) file for more details.

---

## 🌐 Learn More

- 📚 [Formbricks Documentation](https://formbricks.com/docs)
- 💬 [Community on Discord](https://discord.com/invite/formbricks)
- 💻 [Source Code on GitHub](https://github.com/ositano/formbricks_flutter)
