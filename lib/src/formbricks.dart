import '../formbricks_flutter.dart';

class Formbricks {
  static final Formbricks _instance = Formbricks._internal();

  factory Formbricks() => _instance;

  Formbricks._internal();

  late TriggerManager _triggerManager;

  void init(TriggerManager manager) {
    _triggerManager = manager;
  }

  /// Defines the user identifier value for the user
  /// [userId] - can be unique id or an email address
  void setUserId(String userId) {
    _triggerManager.userId = userId;
  }

  /// Defines the extra user information of the user
  /// [attributes] - additional user information
  void setAttribute(Map<String, dynamic> attributes) {
    _triggerManager.userAttributes.clear();
    _triggerManager.userAttributes.addAll(attributes);
  }


  /// Add app-level triggers
  /// [triggerValues] - trigger values
  void addTriggerValues(List<TriggerValue> triggerValues){
    _triggerManager.triggers.addAll(triggerValues);
  }

  /// Sets the app locale
  /// [locale] - the language code. e.g en, fr, es
  void setLocale(String locale) {
    _triggerManager.setLocale(locale);
  }

  String get currentLocale => _triggerManager.currentLocale;
}
