import '../formbricks_flutter.dart';

/// Singleton class that provides a global interface to interact with Formbricks.
///
/// Use this to initialize and manage survey triggers, user data,
/// and localization settings throughout your app.
class Formbricks {
  // Private singleton instance
  static final Formbricks _instance = Formbricks._internal();

  /// Factory constructor that always returns the same [Formbricks] instance
  factory Formbricks() => _instance;

  // Private named constructor
  Formbricks._internal();

  // The internal trigger manager responsible for survey handling
  late TriggerManager _triggerManager;

  /// Initializes Formbricks with a [TriggerManager] instance.
  ///
  /// This must be called once before using any other methods.
  void init(TriggerManager manager) {
    _triggerManager = manager;
  }

  /// Sets the current user's unique identifier.
  ///
  /// Typically an internal ID or email address.
  void setUserId(String userId) {
    _triggerManager.userId = userId;
  }

  /// Sets additional user attributes used in segment filtering.
  ///
  /// Example: `{"email": "user@example.com", "firstName": "Jane"}`
  void setUserAttribute(Map<String, dynamic> attributes) {
    _triggerManager.userAttributes.clear();
    _triggerManager.userAttributes.addAll(attributes);
  }

  /// Adds application-level triggers to the survey engine.
  ///
  /// These triggers can be matched against survey configurations.
  void addTriggerValues(List<TriggerValue> triggerValues) {
    _triggerManager.triggers.addAll(triggerValues);
  }

  /// Sets the current app locale to control survey language display.
  ///
  /// Example: `"en"`, `"fr"`, `"de"`
  void setLocale(String locale) {
    _triggerManager.setLocale(locale);
  }

  /// Gets the currently active locale.
  String get currentLocale => _triggerManager.currentLocale;
}
