import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../formbricks_flutter.dart';
import '../formbricks_flutter_config.dart';
import '../models/environment/environment_data_holder.dart';
import '../models/user/user_display.dart';
import '../utils/logger.dart';
import '../utils/sdk_error.dart';
import 'user_manager.dart';
import 'view_manager.dart';

/// Manages the lifecycle of surveys including fetching, filtering, triggering,
/// and tracking survey responses.
class SurveyManager {
  static const _refreshStateOnErrorTimeoutInMinutes = 10;
  static const _prefFormbricksDataHolder = 'formbricksDataHolder';

  final FormbricksClient client;
  late final SurveyDisplayMode surveyDisplayMode;
  late final SurveyPlatform surveyPlatform;
  final BuildContext context;
  final FormbricksFlutterConfig? formbricksFlutterConfig;

  static SurveyManager? _instance;

  /// Returns the existing instance or creates a new one if it hasn't been initialized.
  factory SurveyManager({
    required FormbricksClient client,
    required SurveyDisplayMode surveyDisplayMode,
    required SurveyPlatform surveyPlatform,
    required BuildContext context,
    FormbricksFlutterConfig? formbricksFlutterConfig,
  }) {
    _instance ??= SurveyManager._internal(
      context: context,
      client: client,
      surveyDisplayMode: surveyDisplayMode,
      surveyPlatform: surveyPlatform,
      formbricksFlutterConfig: formbricksFlutterConfig,
    );
    return _instance!;
  }

  /// Access the current SurveyManager instance.
  static SurveyManager get instance {
    if (_instance == null) {
      throw Exception("SurveyManager has not been initialized.");
    }
    return _instance!;
  }

  SurveyManager._internal({
    required this.client,
    required this.surveyDisplayMode,
    required this.surveyPlatform,
    required this.context,
    this.formbricksFlutterConfig,
  });

  Timer? _refreshTimer;
  Timer? _displayTimer;
  bool hasApiError = false;
  bool isShowingSurvey = false;

  /// Holds surveys that match filtering conditions and are ready to be shown.
  final List<Survey> filteredSurveys = [];

  /// Cached environment data received from backend.
  EnvironmentDataHolder? _environmentDataHolder;

  /// Stores environment data to local storage.
  Future<void> _saveEnvironmentDataHolder(EnvironmentDataHolder? holder) async {
    final prefs = await SharedPreferences.getInstance();
    if (holder == null) {
      await prefs.remove(_prefFormbricksDataHolder);
    } else {
      await prefs.setString(_prefFormbricksDataHolder, jsonEncode(holder.toJson()));
    }
  }

  /// Loads environment data from local storage.
  Future<void> _loadEnvironmentDataHolder() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_prefFormbricksDataHolder);
    if (jsonString != null && jsonString.isNotEmpty) {
      try {
        _environmentDataHolder = EnvironmentDataHolder.fromJson(jsonDecode(jsonString));
      } catch (_) {
        Log.instance.e('Failed to load environment data from local storage');
      }
    }
  }

  /// Returns cached environment data, loading from storage if necessary.
  Future<EnvironmentDataHolder?> get environmentDataHolder async {
    if (_environmentDataHolder == null) {
      await _loadEnvironmentDataHolder();
    }
    return _environmentDataHolder;
  }

  /// Updates and caches the environment data.
  set environmentData(EnvironmentDataHolder? value) {
    _environmentDataHolder = value;
    _saveEnvironmentDataHolder(value);
  }

  /// Refreshes the environment from the backend if expired or forced.
  Future<void> refreshEnvironmentIfNeeded({bool force = false}) async {
    final holder = await environmentDataHolder;
    if (!force) {
      final expiresAt = DateTime.tryParse(holder?.data?.expiresAt ?? '');
      if (expiresAt != null && DateTime.now().isBefore(expiresAt)) {
        Log.instance.d("Environment is still valid until $expiresAt");
        await filterSurveys();
        return;
      }
    }

    try {
      final newHolder = await client.getEnvironmentData();
      environmentData = newHolder;
      final expiresAt = DateTime.tryParse(newHolder?.data?.expiresAt ?? '');
      _startRefreshTimer(expiresAt);
      await filterSurveys();
      hasApiError = false;
    } catch (e, st) {
      Log.instance.e(SDKError.instance.unableToRefreshEnvironment);
      hasApiError = true;
      _startErrorTimer();
    }
  }

  /// Filters surveys based on segment, display rules, and user interaction.
  Future<void> filterSurveys() async {
    final holder = await environmentDataHolder;
    if (holder == null) return;

    final surveys = holder.data?.data.surveys ?? [];
    final displays = UserManager().displays;
    final responses = UserManager().responses;
    final segments = UserManager().segments;

    List<Survey> result = _filterSurveysBasedOnDisplayType(surveys, displays, responses);
    result = _filterSurveysBasedOnRecontactDays(result, holder.data?.data.project.recontactDays?.toInt());

    if (UserManager().userId != null) {
      if (segments.isEmpty) {
        filteredSurveys.clear();
        return;
      }
      result = _filterSurveysBasedOnSegments(result, segments);
    }

    filteredSurveys
      ..clear()
      ..addAll(result);
  }

  /// Triggers a survey based on a tracked action if all filters pass.
  Future<void> track(String action) async {
    final holder = await environmentDataHolder;
    final actionClasses = holder?.data?.data.actionClasses ?? [];

    final actionClass = actionClasses.firstWhereOrNull(
          (ac) => ac.type == 'code' && ac.key == action,
    );

    final targetSurvey = filteredSurveys.firstWhereOrNull(
          (survey) => survey.triggers?.any((trigger) => trigger.actionClass?.name == actionClass?.name) ?? false,
    );

    if (targetSurvey == null) {
      Log.instance.e(SDKError.instance.surveyNotFoundError);
      return;
    }

    final shouldDisplay = _shouldDisplayBasedOnPercentage(targetSurvey.displayPercentage);
    if (!shouldDisplay) {
      Log.instance.e(SDKError.instance.surveyNotDisplayedError);
      return;
    }

    final timeout = (targetSurvey.delay ?? 0).toDouble();

    isShowingSurvey = true;
    _displayTimer?.cancel();
    _displayTimer = Timer(Duration(milliseconds: (timeout * 1000).toInt()), () {
      if (surveyPlatform == SurveyPlatform.inApp) {
        int estimatedTimeInSecs = calculateEstimatedTime(targetSurvey.questions);
        ViewManager.showSurveyInApp(
          context,
          client,
          UserManager().userId!,
          targetSurvey,
          surveyDisplayMode,
          estimatedTimeInSecs,
          formbricksFlutterConfig: formbricksFlutterConfig,
        );
      } else {
        String platform = Platform.isIOS ? "ios" : "android";
        var environmentData = holder?.originalResponseMap['data']['data'] ?? {};
        ViewManager.showSurveyWeb(
          context,
          client,
          UserManager().userId!,
          targetSurvey,
          "",
          platform,
          environmentData,
        );
      }
    });
  }

  /// Records a completed survey response.
  void postResponse(String surveyId) {
    if (surveyId.isEmpty) {
      Log.instance.e(SDKError.instance.missingSurveyId);
      return;
    }
    UserManager().onResponse(surveyId);
  }

  /// Records that a survey was shown to the user.
  void onNewDisplay(String surveyId) {
    if (surveyId.isEmpty) {
      Log.instance.e(SDKError.instance.missingSurveyId);
      return;
    }
    UserManager().onDisplay(surveyId);
  }

  /// Starts a timer to refresh environment data before expiration.
  void _startRefreshTimer(DateTime? expiresAt) {
    if (expiresAt == null) return;
    _refreshTimer?.cancel();
    _refreshTimer = Timer(expiresAt.difference(DateTime.now()), () {
      Log.instance.d('Refreshing environment from timer');
      refreshEnvironmentIfNeeded();
    });
  }

  /// Starts a retry timer if environment refresh failed.
  void _startErrorTimer() {
    final retryTime = Duration(minutes: _refreshStateOnErrorTimeoutInMinutes);
    _refreshTimer?.cancel();
    _refreshTimer = Timer(retryTime, () {
      Log.instance.d('Retrying refresh after error');
      refreshEnvironmentIfNeeded();
    });
  }

  /// Filters surveys based on their display rules and past interactions.
  List<Survey> _filterSurveysBasedOnDisplayType(
      List<Survey> surveys,
      List<UserDisplay> displays,
      List<String> responses,
      ) {
    return surveys.where((survey) {
      switch (survey.displayOption) {
        case 'respondMultiple':
          return true;
        case 'displayOnce':
          return displays.every((d) => d.surveyId != survey.id);
        case 'displayMultiple':
          return !responses.contains(survey.id);
        case 'displaySome':
          final limit = survey.displayLimit;
          if (limit == null) return true;
          final displayCount = displays.where((d) => d.surveyId == survey.id).length;
          return displayCount < limit;
        default:
          Log.instance.e(SDKError.instance.invalidDisplayOption);
          return false;
      }
    }).toList();
  }

  /// Filters surveys based on minimum recontact days since last display.
  List<Survey> _filterSurveysBasedOnRecontactDays(
      List<Survey> surveys,
      int? defaultRecontactDays,
      ) {
    return surveys.where((survey) {
      final lastDisplayedAt = UserManager().lastDisplayedAt;
      if (lastDisplayedAt == null) return true;

      final recontactDays = survey.recontactDays ?? defaultRecontactDays;
      if (recontactDays == null) return true;

      final daysSince = DateTime.now().difference(lastDisplayedAt).inDays;
      return daysSince >= recontactDays;
    }).toList();
  }

  /// Filters surveys based on whether the user's segments match.
  List<Survey> _filterSurveysBasedOnSegments(List<Survey> surveys, List<String> segments) {
    return surveys.where((survey) {
      final segmentId = survey.segment?.id;
      return segmentId != null && segments.contains(segmentId);
    }).toList();
  }

  /// Randomly decides if a survey should be shown based on display percentage.
  bool _shouldDisplayBasedOnPercentage(double? percentage) {
    if (percentage == null) return true;
    final random = (10000 * (DateTime.now().microsecond / 1000000)).round() / 100;
    return random <= percentage;
  }

  /// Estimates the time needed to complete the given questions.
  int calculateEstimatedTime(List<Question> questions) {
    int total = 0;
    for (final q in questions) {
      total += (q.type == 'nps' || q.type == 'rating') ? 5 : 10;
      total += 5; // time to read and think
      if (q.required == true) total += 2; // extra time for mandatory
    }
    return total;
  }

  /// Sets the survey platform (e.g., inApp, webView)
  void setSurveyPlatform(SurveyPlatform platform){
    surveyPlatform = platform;
  }

  /// Sets how surveys should be displayed for inApp (e.g., fullscreen, dialog, bottomSheetModal)
  void setSurveyDisplayMode(SurveyDisplayMode mode){
    surveyDisplayMode = mode;
  }
}
