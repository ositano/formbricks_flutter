import '../formbricks_flutter.dart';

/// Singleton class that provides a global interface to interact with Formbricks Flutter SDK.
///
/// Used to initialize and manage survey triggers, user data,
/// and localization settings throughout your app.
class Formbricks {

  // Private singleton instance
  static final Formbricks _instance = Formbricks._internal();

  /// Factory constructor that always returns the same [Formbricks] instance
  factory Formbricks() => _instance;

  // Private constructor
  Formbricks._internal();

  // The internal survey manager responsible for survey handling
  late SurveyManager _surveyManager;

  /// Initializes Formbricks with a [SurveyManager] instance.
  ///
  /// called once before using any other methods.
  void init(SurveyManager manager) {
    _surveyManager = manager;
  }

  /// Sets the current user's unique identifier.
  ///
  /// Typically an internal ID or email address.
  void setUserId(String userId) {
    _surveyManager.userId = userId;
  }

  /// Sets additional user attributes used in segment filtering.
  ///
  /// Example: `{"email": "user@example.com", "firstName": "Jane"}`
  void setUserAttribute(Map<String, dynamic> attributes) {
    _surveyManager.userAttributes.clear();
    _surveyManager.userAttributes.addAll(attributes);
  }

  /// Adds application-level triggers to the survey engine.
  ///
  /// These triggers can be matched against survey configurations.
  void addTriggerValues(List<TriggerValue> triggerValues) {
    _surveyManager.triggers.addAll(triggerValues);
  }

  /// Sets the current app locale to control survey language display.
  ///
  /// Example: `"en"`, `"fr"`, `"de"`
  void setLocale(String locale) {
    _surveyManager.setLocale(locale);
  }

  /// Gets the currently active locale.
  String get currentLocale => _surveyManager.currentLocale;
}
