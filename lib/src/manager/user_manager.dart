import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../formbricks_flutter.dart';
import '../models/user/user_display.dart';
import '../utils/logger.dart';

/// A singleton class to manage the user's data and sync it with the server.
/// Handles storage and retrieval using SharedPreferences.
class UserManager {
  // Keys for SharedPreferences storage
  static const _userIdKey = 'userId';
  static const _contactIdKey = 'contactId';
  static const _segmentsKey = 'segments';
  static const _displaysKey = 'displays';
  static const _responsesKey = 'responses';
  static const _lastDisplayedAtKey = 'lastDisplayedAt';
  static const _expiresAtKey = 'expiresAt';
  static const _attributesKey = 'attributes';
  static const _languageKey = 'language';

  // Singleton instance
  static final UserManager _instance = UserManager._internal();
  factory UserManager() => _instance;
  UserManager._internal();

  // Internal fields
  SharedPreferences? _prefs;
  Timer? _syncTimer;

  String? _userId;
  String? _language;
  Map<String, String>? _attributes;
  String? _contactId;
  List<String>? _segments;
  List<UserDisplay>? _displays;
  List<String>? _responses;
  DateTime? _lastDisplayedAt;
  DateTime? _expiresAt;

  /// Initialize SharedPreferences
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // -------------------------------
  // SETTERS
  // -------------------------------

  /// Save user ID locally and in memory
  Future<void> setUserId(String id) async {
    _userId = id;
    await _prefs?.setString(_userIdKey, id);
  }

  /// Set the user's preferred language and update server with it
  Future<void> setLanguage(String language) async {
    _language = language;
    await _prefs?.setString(_languageKey, language);
    _attributes?["language"] = language;
    syncUser(userId!, attributes);
  }

  /// Replace user attributes and store them
  Future<void> setAttributes(Map<String, String> attributes) async {
    _attributes = attributes;
    await _prefs?.setString(_attributesKey, jsonEncode(attributes));
  }

  /// Merge new attributes with existing ones and sync
  Future<void> addAttribute(Map<String, String> attributes) async {
    _attributes?.addAll(attributes);
    await _prefs?.setString(_attributesKey, jsonEncode(attributes));
    syncUser(userId!, attributes);
  }

  /// Set contact ID
  Future<void> setContactId(String id) async {
    _contactId = id;
    await _prefs?.setString(_contactIdKey, id);
  }

  /// Set segments user belongs to
  Future<void> setSegments(List<String> segments) async {
    _segments = segments;
    await _prefs?.setStringList(_segmentsKey, segments);
  }

  /// Set surveys that have been shown to the user
  Future<void> setDisplays(List<UserDisplay> displays) async {
    _displays = displays;
    final jsonList = jsonEncode(displays.map((e) => e.toJson()).toList());
    await _prefs?.setString(_displaysKey, jsonList);
  }

  /// Set survey responses given by the user
  Future<void> setResponses(List<String> responses) async {
    _responses = responses;
    await _prefs?.setStringList(_responsesKey, responses);
  }

  /// Set the last time a survey was displayed
  Future<void> setLastDisplayedAt(DateTime time) async {
    _lastDisplayedAt = time;
    await _prefs?.setInt(_lastDisplayedAtKey, time.millisecondsSinceEpoch);
  }

  /// Set expiration time for local user session
  Future<void> setExpiresAt(DateTime time) async {
    _expiresAt = time;
    await _prefs?.setInt(_expiresAtKey, time.millisecondsSinceEpoch);
  }

  // -------------------------------
  // GETTERS
  // -------------------------------

  String? get userId => _userId ?? _prefs?.getString(_userIdKey);
  String? get language => _language ?? _prefs?.getString(_languageKey);

  /// Retrieve user attributes from memory or local storage
  Map<String, String>? get attributes {
    if (_attributes != null) return _attributes!;
    final jsonStr = _prefs?.getString(_attributesKey);
    if (jsonStr == null) return {};
    final decoded = jsonDecode(jsonStr) as Map<String, String>;
    return decoded;
  }

  String? get contactId => _contactId ?? _prefs?.getString(_contactIdKey);
  List<String> get segments => _segments ?? _prefs?.getStringList(_segmentsKey) ?? [];

  /// Get list of displayed surveys
  List<UserDisplay> get displays {
    if (_displays != null) return _displays!;
    final jsonStr = _prefs?.getString(_displaysKey);
    if (jsonStr == null) return [];
    final decoded = jsonDecode(jsonStr) as List;
    return decoded.map((e) => UserDisplay.fromJson(e)).toList();
  }

  List<String> get responses => _responses ?? _prefs?.getStringList(_responsesKey) ?? [];

  /// Last time survey was shown to the user
  DateTime? get lastDisplayedAt {
    if (_lastDisplayedAt != null) return _lastDisplayedAt;
    final millis = _prefs?.getInt(_lastDisplayedAtKey);
    return millis != null ? DateTime.fromMillisecondsSinceEpoch(millis) : null;
  }

  /// Session expiration time
  DateTime? get expiresAt {
    if (_expiresAt != null) return _expiresAt;
    final millis = _prefs?.getInt(_expiresAtKey);
    return millis != null ? DateTime.fromMillisecondsSinceEpoch(millis) : null;
  }

  // -------------------------------
  // STATE MODIFIERS
  // -------------------------------

  /// Call when a survey is displayed to the user
  Future<void> onDisplay(String surveyId) async {
    final now = DateTime.now();
    final updated = [
      ...displays,
      UserDisplay(surveyId: surveyId, createdAt: now.toIso8601String())
    ];
    await setDisplays(updated);
    await setLastDisplayedAt(now);
    SurveyManager.instance.filterSurveys();
  }

  /// Call when a user responds to a survey
  Future<void> onResponse(String surveyId) async {
    final updated = [...responses, surveyId];
    await setResponses(updated);
    SurveyManager.instance.filterSurveys();
  }

  /// Sync user state with server if expired
  Future<void> syncUserIfNeeded() async {
    if (userId == null || expiresAt == null) return;
    if (DateTime.now().isAfter(expiresAt!)) {
      await syncUser(userId!);
    }
  }

  /// Force sync user with server (e.g., after update)
  Future<void> syncUser(String userId, [Map<String, String>? attributes]) async {
    try {
      final result = await FormbricksClient.instance.createUser(userId, attributes: attributes);
      final data = result?.state.data;
      if (data == null) return;

      await setUserId(data.userId ?? userId);
      await setContactId(data.contactId ?? '');
      await setSegments(data.segments ?? []);
      await setDisplays(data.displays ?? []);
      await setResponses(data.responses ?? []);
      if (data.lastDisplayAt != null) {
        await setLastDisplayedAt(DateTime.parse(data.lastDisplayAt!));
      }
      if (result?.state.expiresAt != null) {
        await setExpiresAt(DateTime.parse(result!.state.expiresAt!));
      }

      SurveyManager.instance.filterSurveys();
      _startSyncTimer();
    } catch (e, st) {
      Log.instance.e("Failed to sync user state: $e, stackTrace: $st");
    }
  }

  /// Clear user data on logout
  Future<void> logout() async {
    _userId = null;
    _contactId = null;
    _segments = null;
    _displays = null;
    _responses = null;
    _lastDisplayedAt = null;
    _expiresAt = null;
    _syncTimer?.cancel();

    await _prefs?.remove(_userIdKey);
    await _prefs?.remove(_languageKey);
    await _prefs?.remove(_contactIdKey);
    await _prefs?.remove(_segmentsKey);
    await _prefs?.remove(_displaysKey);
    await _prefs?.remove(_responsesKey);
    await _prefs?.remove(_lastDisplayedAtKey);
    await _prefs?.remove(_expiresAtKey);
    await _prefs?.remove(_attributesKey);

    Log.instance.d("User logged out successfully");
  }

  /// Start a timer to automatically sync user state at expiration
  void _startSyncTimer() {
    if (expiresAt == null || userId == null) return;
    _syncTimer?.cancel();
    final delay = expiresAt!.difference(DateTime.now());
    _syncTimer = Timer(delay, () => syncUser(userId!));
  }
}
