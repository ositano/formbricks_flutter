import '../formbricks_flutter.dart';
import 'manager/survey_manager.dart';
import 'manager/user_manager.dart';
import 'utils/logger.dart';
import 'utils/sdk_error.dart';

/// Singleton class that provides a global interface to interact with the Formbricks Flutter SDK.
///
/// This class is responsible for:
/// - SDK initialization
/// - User management (setting user ID and attributes)
/// - Survey tracking
/// - Locale/language control
/// - Logout functionality
class Formbricks {
  /// Flag to indicate whether the SDK has been initialized.
  bool isInitialized = false;

  /// Private singleton instance of the Formbricks SDK.
  static Formbricks? _instance = Formbricks._internal();

  /// Factory constructor that always returns the same [Formbricks] instance.
  factory Formbricks() {
    _instance ??= Formbricks._internal();
    return _instance!;
  }

  /// Static getter to retrieve the existing [Formbricks] instance.
  ///
  /// Throws an exception if the instance hasn't been initialized.
  static Formbricks get instance {
    if (_instance == null) {
      throw Exception("Formbricks has not been initialized.");
    }
    return _instance!;
  }
  /// Private constructor to prevent external instantiation.
  Formbricks._internal();

  /// Internal [SurveyManager] responsible for fetching and handling survey logic.
  late SurveyManager _surveyManager;

  /// Internal [UserManager] responsible for managing user identity and attributes.
  late UserManager _userManager;

  /// Initializes the Formbricks SDK with a [UserManager] and [SurveyManager].
  ///
  /// This must be called **once** before using other methods.
  /// [checkForNewSurveysOnRestart] determines whether to force-refresh environment data at startup.
  void init(UserManager userManager, SurveyManager surveyManager, bool checkForNewSurveysOnRestart) {
    if (isInitialized) {
      var error = SDKError.instance.sdkIsAlreadyInitialized;
      Log.instance.e(error);
      return;
    }

    /// Enforce HTTPS usage for app security
    if (!surveyManager.client.appUrl.toLowerCase().startsWith("https://")) {
      var error = Exception(
          "Only HTTPS URLs are allowed for security reasons. "
              "HTTP URLs are not permitted. Provided URL: ${surveyManager.client.appUrl}"
      );
      Log.instance.e(error);
      return;
    }

    _userManager = userManager;
    _surveyManager = surveyManager;

    /// Refresh environment and sync user data
    _surveyManager.refreshEnvironmentIfNeeded(force: checkForNewSurveysOnRestart);
    _userManager.syncUserIfNeeded();

    isInitialized = true;
  }

  /// Sets the current user’s unique identifier (e.g., user ID or email).
  ///
  /// You must call this method before setting user attributes.
  /// If a user ID is already set, you must call [logout] before setting a new one.
  void setUserId(String userId) {
    if (!isInitialized) {
      var error = SDKError.instance.sdkIsNotInitialized;
      Log.instance.e(error);
      return;
    }

    if (_userManager.userId != null) {
      var error = Exception(
          "A userId is already set (${_userManager.userId}) - "
              "please call logout first before setting a new one."
      );
      Log.instance.e(error);
      return;
    }

    _userManager.setUserId(userId);
  }

  /// Sets or replaces the user’s attributes for segment filtering and targeting.
  ///
  /// Example:
  /// ```dart
  /// setAttribute({"name": "Green Onyeji", "role": "Senior Flutter Engineer"});
  /// ```
  void setAttributes(Map<String, String> attributes) {
    if (!isInitialized) {
      var error = SDKError.instance.sdkIsNotInitialized;
      Log.instance.e(error);
      return;
    }

    if (_userManager.userId == null) {
      var error = Exception(
          "A userId has not been set - please call setUserId or pass a user ID to the provider."
      );
      Log.instance.e(error);
      return;
    }

    _userManager.syncUser(_userManager.userId!, attributes);
  }

  /// Adds or updates specific user attributes without replacing existing ones.
  ///
  /// Example:
  /// ```dart
  /// addAttribute({"location": "Abuja"});
  /// ```
  void addAttribute(Map<String, String> attributes) {
    if (!isInitialized) {
      var error = SDKError.instance.sdkIsNotInitialized;
      Log.instance.e(error);
      return;
    }

    if (_userManager.userId == null) {
      var error = Exception(
          "A userId has not been set - please call setUserId or pass a user ID to the provider."
      );
      Log.instance.e(error);
      return;
    }

    _userManager.addAttribute(attributes);
  }

  /// Sets the language code for surveys (e.g., "en", "de", "fr").
  ///
  /// Affects survey display and localization.
  void setLanguage(String language) {
    if (!isInitialized) {
      var error = SDKError.instance.sdkIsNotInitialized;
      Log.instance.e(error);
      return;
    }

    _userManager.setLanguage(language);
  }

  /// Tracks a specific action.
  /// Note that this SDK works with [code] actionType
  ///
  /// Triggers any surveys associated with that action.
  void track({required String action}) {
    if (!isInitialized) {
      var error = SDKError.instance.sdkIsNotInitialized;
      Log.instance.e(error);
      return;
    }

    _surveyManager.track(action);
  }

  /// Sets the survey platform (e.g., inApp, webview)
  void setSurveyPlatform(SurveyPlatform surveyPlatform) {
    _surveyManager.setSurveyPlatform(surveyPlatform);
  }

  /// Sets how surveys should be displayed for inApp (e.g. fullscreen, dialog, bottomSheetModal)
  void setSurveyDisplayMode(SurveyDisplayMode surveyDisplayMode) {
    _surveyManager.setSurveyDisplayMode(surveyDisplayMode);
  }

  /// Logs out the current user and clears all user attributes.
  ///
  /// Call this when switching accounts or resetting user data.
  void logout() {
    if (!isInitialized) {
      var error = SDKError.instance.sdkIsNotInitialized;
      Log.instance.e(error);
      return;
    }

    _userManager.logout();
  }
}
