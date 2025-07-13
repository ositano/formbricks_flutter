import '../formbricks_flutter.dart';

class Formbricks {
  static final Formbricks _instance = Formbricks._internal();

  factory Formbricks() => _instance;

  Formbricks._internal();

  late TriggerManager _triggerManager;

  void init(TriggerManager manager) {
    _triggerManager = manager;
  }

  void setUserId(String userId) {
    _triggerManager.userId = userId;
  }

  void setAttribute(Map<String, dynamic> attributes) {
    _triggerManager.userAttributes.clear();
    _triggerManager.userAttributes.addAll(attributes);
  }

  void track(String eventName) {
    _triggerManager.addEvent(eventName);
  }

  void setLocale(String locale) {
    _triggerManager.setLocale(locale);
  }

  String get currentLocale => _triggerManager.currentLocale;
}
