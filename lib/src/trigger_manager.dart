import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../formbricks_flutter.dart';
import 'models/question.dart';

class TriggerManager {
  final FormBricksClient client;
  final String userId;
  final Map<String, dynamic> userAttributes;
  final Map<String, int> eventCounts = {};
  late Map<String, bool> completedSurveys = {};
  bool _isInitialized = false;
  Function(String)? onSurveyTriggered;
  final ThemeData? customTheme;
  final SurveyDisplayMode surveyDisplayMode; // 'bottomSheet' or 'dialog'
  final bool showPoweredBy;
  final StreamController<String> _eventStream =
      StreamController<String>.broadcast();
  late StreamSubscription _eventSubscription;
  final List<TriggerValue>? triggers; // Updated to use Trigger model
  late final String locale; // Default locale
  final BuildContext context;

  TriggerManager({
    required this.client,
    required this.userId,
    this.userAttributes = const {},
    this.onSurveyTriggered,
    this.customTheme,
    required this.surveyDisplayMode,
    required this.showPoweredBy,
    this.triggers,
    required this.locale,
    required this.context,
  }) {
    _eventSubscription = _eventStream.stream.listen(_handleEvent);
  }

  String get currentLocale => locale;

  void setLocale(String newLocale, {VoidCallback? onLocaleChanged}) {
    locale = newLocale;
    if (newLocale.isEmpty) {
      throw ArgumentError('Locale cannot be empty');
    }
    // Check if the locale is different to avoid unnecessary updates
    if (locale != newLocale) {
      locale = newLocale; // Update the internal locale state

      // Notify any registered callback to trigger a rebuild
      if (onLocaleChanged != null) {
        onLocaleChanged();
      }

      // Optional: Log the locale change for debugging
      print('TriggerManager: Locale changed to $newLocale');
    }
  }

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final completedSurveysJson =
        prefs.getString('completed_surveys_$userId') ?? '{}';
    completedSurveys = Map<String, bool>.from(
      (jsonDecode(completedSurveysJson) as Map).map(
        (key, value) => MapEntry(key, value as bool),
      ),
    );
    _isInitialized = true;
    await _loadAndTriggerSurveys(); // Trigger survey check on app launch
  }

  Future<void> _saveCompletedSurveys() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'completed_surveys_$userId',
      jsonEncode(completedSurveys),
    );
  }

  bool _isPhoneDevice() {
    final screenWidth = MediaQuery.of(context).size.width;
    return Platform.isAndroid || Platform.isIOS && screenWidth < 600;
  }

  bool _shouldDisplaySurvey(double? displayPercentage) {
    if (displayPercentage == null) return true;
    final random = Random().nextDouble() * 100;
    debugPrint("random value $random ....");
    return random <= displayPercentage;
  }

  void _handleEvent(String event) async {
    eventCounts[event] = (eventCounts[event] ?? 0) + 1;
    await _loadAndTriggerSurveys(); // Trigger check for all surveys on any event
  }

  Future<void> _loadAndTriggerSurveys() async {
    if (!_isInitialized) await initialize();

    try {
      // Fetch all surveys based on apiKey and environmentId
      final surveys = await client
          .getSurveys(); // Assuming getSurveys() exists or adjust to your API call
      for (var surveyData in surveys) {
        final survey = Survey.fromJson(surveyData);

        if (survey.status != 'inProgress' ||
            survey.environmentId != client.environmentId) {
          continue;
        }
        debugPrint("pass in progress....");
        // if (survey.displayOption == 'displayOnce' && completedSurveys[survey.id] == true) {
        //   continue;
        // }
        debugPrint("pass display option....");

        debugPrint("survey triggers ${survey.triggers} ....");
        bool shouldTrigger = false;
        if (survey.triggers != null && triggers != null) {
          for (var surveyTrigger in survey.triggers!) {
            final actionClass = surveyTrigger['actionClass'];
            if (actionClass != null) {
              final type = actionClass['type'] as String?;
              final name = actionClass['name'] as String?;
              final key = actionClass['key'] as String?;
              // Match against predefined triggers
              for (var predefinedTrigger in triggers!) {
                if (predefinedTrigger.type == TriggerType.noCode &&
                    type == 'noCode' &&
                    name == predefinedTrigger.name) {
                  shouldTrigger = true;
                } else if (predefinedTrigger.type == TriggerType.code &&
                    type == 'code' &&
                    key == predefinedTrigger.key) {
                  shouldTrigger = true;
                }
                if (shouldTrigger) break;
              }
              if (shouldTrigger) break;
            }
          }
        }
        debugPrint("pass trigger checks ....");

        if (survey.segment != null && survey.segment!['filters'] != null) {
          for (var filter in survey.segment!['filters']) {
            final resource = filter['resource'];
            if (resource['root']['type'] == 'device' &&
                resource['root']['deviceType'] == 'phone') {
              if (!_isPhoneDevice()) {
                shouldTrigger = false;
                break;
              }
            }
          }
        }

        debugPrint(
          "pass survey segment checks .... ${survey.displayPercentage}",
        );

        // if (!_shouldDisplaySurvey(survey.displayPercentage)) {
        //   shouldTrigger = false;
        // }

        debugPrint("pass display percent .... $shouldTrigger");

        if (shouldTrigger) {
          completedSurveys[survey.id] = true;
          await _saveCompletedSurveys();
          _showSurvey(survey);
          if (onSurveyTriggered != null) {
            onSurveyTriggered!(survey.id);
          }
        }
      }
    } catch (e, st) {
      debugPrint('Error fetching surveys: $st');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load survey: $e')));
    }
  }

  void _showSurvey(Survey survey) {
    int estimatedTimeInSecs = calculateEstimatedTime(survey.questions);
    if (surveyDisplayMode == SurveyDisplayMode.fullScreen) {
      Navigator.push(
        context,
        Platform.isIOS
            ? CupertinoPageRoute(
                builder: (context) => Theme(
                  data: buildTheme(context, customTheme, survey),
                  child: Scaffold(
                    backgroundColor: Theme.of(context).cardColor,
                    //backgroundColor: Color.from(alpha: 1.0000, red: 0.9490, green: 0.8902, blue: 0.8902, colorSpace: ColorSpace.sRGB),
                    body: SurveyWidget(
                      client: client,
                      survey: survey,
                      userId: userId,
                      showPoweredBy: showPoweredBy,
                      surveyDisplayMode: surveyDisplayMode,
                      estimatedTimeInSecs: estimatedTimeInSecs,
                    ),
                  ),
                ),
              )
            : MaterialPageRoute(
                builder: (context) => Theme(
                  data: buildTheme(context, customTheme, survey),
                  child: Scaffold(
                    backgroundColor: Theme.of(context).cardColor,
                    body: SurveyWidget(
                      client: client,
                      survey: survey,
                      userId: userId,
                      showPoweredBy: showPoweredBy,
                      surveyDisplayMode: surveyDisplayMode,
                      estimatedTimeInSecs: estimatedTimeInSecs,
                    ),
                  ),
                ),
              ),
      );
    } else if (surveyDisplayMode == SurveyDisplayMode.dialog) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          titlePadding: EdgeInsets.zero,
          contentPadding: EdgeInsets.zero,
          //insetPadding: EdgeInsets.zero,
          actionsPadding: EdgeInsets.zero,
          content: Theme(
            data: buildTheme(context, customTheme, survey),
            child: SurveyWidget(
              client: client,
              survey: survey,
              userId: userId,
              showPoweredBy: showPoweredBy,
              surveyDisplayMode: surveyDisplayMode,
              estimatedTimeInSecs: estimatedTimeInSecs,
            ),
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isDismissible: false,
        backgroundColor: Theme.of(context).cardColor,
        builder: (context) => Theme(
          data: buildTheme(context, customTheme, survey),
          child: SurveyWidget(
            client: client,
            survey: survey,
            userId: userId,
            showPoweredBy: showPoweredBy,
            surveyDisplayMode: surveyDisplayMode,
            estimatedTimeInSecs: estimatedTimeInSecs,
          ),
        ),
      );
    }
  }

  void dispose() {
    _eventSubscription.cancel();
    _eventStream.close();
  }

  void addEvent(String event) {
    _eventStream.add(event);
  }

  int calculateEstimatedTime(List<Question> questions) {
    int totalSeconds = 0;
    for (var question in questions) {
      switch (question.type) {
        case 'date':
          totalSeconds += 10; // Base time for date selection
          break;
        case 'rating':
        case 'nps':
          totalSeconds += 5; // Quick score selection
          break;
        default:
          totalSeconds += 10; // Default for unsupported types
      }

      // Add buffer time per question
      totalSeconds += 5;

      // Add extra time if required
      if (question.required ?? false) {
        totalSeconds += 2; // Slight increase for mandatory questions
      }
    }

    return totalSeconds;
  }

}
