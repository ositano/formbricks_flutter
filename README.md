
# 🧠 Formbricks Flutter

**Formbricks Flutter** lets you easily integrate beautiful, customizable, in-product **micro-surveys** directly into your Flutter apps. Collect user feedback where it matters most — inside your product. 💬📲

Built on top of [Formbricks](https://formbricks.com) — the open-source experience management platform — this SDK offers all the flexibility you need to launch surveys, collect analytics, and adapt the UI to match your brand. 🎯

---

## ✨ Features

| Feature | Description |
|--------|-------------|
| 💬 **In-App Micro-Surveys** | Display beautiful, embeddable surveys inside your app. |
| 🌐 **Localization Support** | Built-in support for multiple languages: `en`, `es`, `fr`, `ja`, `ar`, `pt`, `sw`, `zh`. |
| ⚡ **Custom Triggers** | Trigger surveys based on app events or coded conditions. |
| 🎨 **Theme Customization** | Style surveys using your app’s `ThemeData`. |
| 🙋‍♂️ **User Targeting** | Pass `userId` and `userAttributes` to personalize surveys. |
| 🪟 **Multiple Display Modes** | Show surveys in `fullScreen`, `dialog`, or `bottomSheet` views. |
| 🧱 **Custom Question Widgets** | Override default widgets with your own beautiful UI. |
| 🧠 **Smart Completion Tracking** | Prevent duplicate displays with `displayOnce` logic. |
| ⏱ **Estimated Completion Time** | Automatically calculated time to inform users. |
| 🔐 **Secure API Integration** | Connect with the Formbricks API using your API key and environment ID. |
| 🧪 **Dev Mode Toggle** | Enable/disable development mode for previewing surveys. |

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
  showPoweredBy: true,
  client: FormbricksClient(
    apiHost: 'https://app.formbricks.com',
    environmentId: 'your-env-id',
    apiKey: 'your-api-key',
    isDev: false,
  ),
  userId: 'user-123',
  userAttributes: {
    'isPremium': false,
    'location': 'Nigeria',
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
  freeTextQuestionBuilder: (context, question, onAnswer) {
    return CustomFreeTextWidget(question: question, onAnswer: onAnswer);
  },
  // Other overrides: addressQuestionBuilder, dateQuestionBuilder, etc.
  ...
)
```

---

## 🧪 Supported Question Types

Formbricks currently supports the following input types:
- 📅 `date`
- ⭐️ `rating`, `nps`
- 📝 `freeText`, `contactInfo`, `consent`
- 🔘 `multipleChoiceSingle`
- 🧩 `multipleChoiceMulti`
- 🪪 `address`
- 🪄 `cta`, `matrix`, `fileUpload`, `ranking`, `pictureSelection`, `calculation`

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
