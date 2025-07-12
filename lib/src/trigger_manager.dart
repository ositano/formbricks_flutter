import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../formbricks_flutter.dart';
import 'models/question.dart';
import 'utils/helper.dart';

// TriggerManager listens for app events and decides when to display surveys
// based on conditions like triggers, completion state, and percentage chance.
class TriggerManager {

  // Dependencies and configuration
  final FormbricksClient client;
  final String userId;
  final Map<String, dynamic> userAttributes;

  // Tracks how many times each event has occurred
  final Map<String, int> eventCounts = {};

  // Tracks whether surveys have been completed (cached locally)
  late Map<String, bool> completedSurveys = {};

  // Tracks whether `initialize` has run to avoid duplicate loading
  bool _isInitialized = false;

  // Optional callback when a survey is triggered
  Function(String)? onSurveyTriggered;

  // Custom theming and display options
  final ThemeData? customTheme;
  final SurveyDisplayMode surveyDisplayMode;
  final bool showPoweredBy;

  // Handles async event tracking
  final StreamController<String> _eventStream = StreamController<String>.broadcast();
  late StreamSubscription _eventSubscription;

  // List of configured app-level triggers
  final List<TriggerValue>? triggers;

  // Locale for internationalization
  late final String locale;

  // Used to show surveys in current context
  final BuildContext context;

  // Optional custom question widget builders
  final QuestionWidgetBuilder? addressQuestionBuilder;
  final QuestionWidgetBuilder? calQuestionBuilder;
  final QuestionWidgetBuilder? consentQuestionBuilder;
  final QuestionWidgetBuilder? contactInfoQuestionBuilder;
  final QuestionWidgetBuilder? ctaQuestionBuilder;
  final QuestionWidgetBuilder? dateQuestionBuilder;
  final QuestionWidgetBuilder? fileUploadQuestionBuilder;
  final QuestionWidgetBuilder? freeTextQuestionBuilder;
  final QuestionWidgetBuilder? matrixQuestionBuilder;
  final QuestionWidgetBuilder? multipleChoiceMultiQuestionBuilder;
  final QuestionWidgetBuilder? multipleChoiceSingleQuestionBuilder;
  final QuestionWidgetBuilder? npsQuestionBuilder;
  final QuestionWidgetBuilder? pictureSelectionQuestionBuilder;
  final QuestionWidgetBuilder? rankingQuestionBuilder;
  final QuestionWidgetBuilder? ratingQuestionBuilder;

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
    this.addressQuestionBuilder,
    this.calQuestionBuilder,
    this.consentQuestionBuilder,
    this.contactInfoQuestionBuilder,
    this.ctaQuestionBuilder,
    this.dateQuestionBuilder,
    this.fileUploadQuestionBuilder,
    this.freeTextQuestionBuilder,
    this.matrixQuestionBuilder,
    this.multipleChoiceMultiQuestionBuilder,
    this.multipleChoiceSingleQuestionBuilder,
    this.npsQuestionBuilder,
    this.pictureSelectionQuestionBuilder,
    this.rankingQuestionBuilder,
    this.ratingQuestionBuilder,
  }) {
    // Listen to incoming event stream
    _eventSubscription = _eventStream.stream.listen(_handleEvent);
  }

  // Getter for current locale
  String get currentLocale => locale;

  // Update locale and notify UI if needed
  void setLocale(String newLocale, {VoidCallback? onLocaleChanged}) {
    if (newLocale.isEmpty) {
      throw ArgumentError('Locale cannot be empty');
    }
    if (locale != newLocale) {
      locale = newLocale;
      onLocaleChanged?.call();
      debugPrint('TriggerManager: Locale changed to $newLocale');
    }
  }

  // Loads completed surveys from SharedPreferences
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final completedSurveysJson = prefs.getString('completed_surveys_$userId') ?? '{}';
    completedSurveys = Map<String, bool>.from(
      (jsonDecode(completedSurveysJson) as Map).map(
            (key, value) => MapEntry(key, value as bool),
      ),
    );
    _isInitialized = true;
    await _loadAndTriggerSurveys(); // Immediately check for trigger
  }

  // Saves updated completed survey state to SharedPreferences
  Future<void> _saveCompletedSurveys() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'completed_surveys_$userId',
      jsonEncode(completedSurveys),
    );
  }

  // Determines if a survey should be shown randomly based on displayPercentage
  bool _shouldDisplaySurvey(double? displayPercentage) {
    if (displayPercentage == null) return true;
    final random = Random().nextDouble() * 100;
    debugPrint("random value $random ....");
    return random <= displayPercentage;
  }

  // Event handler: increments count and rechecks all surveys
  void _handleEvent(String event) async {
    eventCounts[event] = (eventCounts[event] ?? 0) + 1;
    await _loadAndTriggerSurveys();
  }

  // Main method to fetch and decide whether to show any surveys
  Future<void> _loadAndTriggerSurveys() async {
    if (!_isInitialized) await initialize();

    try {
      final surveys = await client.getSurveys();
      for (var surveyData in surveys) {
        final survey = Survey.fromJson(surveyData);

        // Skip surveys that are inactive or from another environment
        if (survey.status != 'inProgress' || survey.environmentId != client.environmentId) {
          continue;
        }

        // Skip if marked completed and only supposed to display once
        if (survey.displayOption == 'displayOnce' && completedSurveys[survey.id] == true) {
          continue;
        }

        // Evaluate whether any trigger conditions match
        bool shouldTrigger = false;
        if (survey.triggers != null && triggers != null) {
          for (var surveyTrigger in survey.triggers!) {
            final actionClass = surveyTrigger['actionClass'];
            if (actionClass != null) {
              final type = actionClass['type'] as String?;
              final name = actionClass['name'] as String?;
              final key = actionClass['key'] as String?;
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

        // Display percentage control
        if (!_shouldDisplaySurvey(survey.displayPercentage)) {
          shouldTrigger = false;
        }

        // If it passes all checks, mark as completed and show
        if (shouldTrigger) {
          completedSurveys[survey.id] = true;
          await _saveCompletedSurveys();
          _showSurvey(survey);
          onSurveyTriggered?.call(survey.id);
        }
      }
    } catch (e, st) {
      debugPrint('Failed to load survey: $e, stackTrace: $st');
      //ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load survey: $e')));
    }
  }

  // Displays the survey in the selected display mode
  void _showSurvey(Survey survey) {
    int estimatedTimeInSecs = calculateEstimatedTime(survey.questions);

    // Full-screen modal
    if (surveyDisplayMode == SurveyDisplayMode.fullScreen) {
      Navigator.push(
        context,
        Platform.isIOS
            ? CupertinoPageRoute(builder: (context) => _buildSurveyScreen(survey, estimatedTimeInSecs))
            : MaterialPageRoute(builder: (context) => _buildSurveyScreen(survey, estimatedTimeInSecs)),
      );

      // Dialog mode
    } else if (surveyDisplayMode == SurveyDisplayMode.dialog) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          titlePadding: EdgeInsets.zero,
          contentPadding: EdgeInsets.zero,
          actionsPadding: EdgeInsets.zero,
          content: Theme(
            data: buildTheme(context, customTheme, survey),
            child: _buildSurveyWidget(survey, estimatedTimeInSecs),
          ),
        ),
      );

      // Bottom sheet mode
    } else {
      showModalBottomSheet(
        context: context,
        isDismissible: false,
        backgroundColor: Theme.of(context).cardColor,
        builder: (context) => Theme(
          data: buildTheme(context, customTheme, survey),
          child: _buildSurveyWidget(survey, estimatedTimeInSecs),
        ),
      );
    }
  }

  // Builds themed full-screen survey view
  Widget _buildSurveyScreen(Survey survey, int estimatedTimeInSecs) {
    return Theme(
      data: buildTheme(context, customTheme, survey),
      child: Scaffold(
        backgroundColor: Theme.of(context).cardColor,
        body: _buildSurveyWidget(survey, estimatedTimeInSecs),
      ),
    );
  }

  // Creates the SurveyWidget with all required props and builders
  SurveyWidget _buildSurveyWidget(Survey survey, int estimatedTimeInSecs) {
    return SurveyWidget(
      client: client,
      survey: survey,
      userId: userId,
      showPoweredBy: showPoweredBy,
      surveyDisplayMode: surveyDisplayMode,
      estimatedTimeInSecs: estimatedTimeInSecs,
      addressQuestionBuilder: addressQuestionBuilder,
      calQuestionBuilder: ctaQuestionBuilder,
      consentQuestionBuilder: consentQuestionBuilder,
      contactInfoQuestionBuilder: contactInfoQuestionBuilder,
      ctaQuestionBuilder: ctaQuestionBuilder,
      dateQuestionBuilder: dateQuestionBuilder,
      fileUploadQuestionBuilder: fileUploadQuestionBuilder,
      freeTextQuestionBuilder: freeTextQuestionBuilder,
      matrixQuestionBuilder: matrixQuestionBuilder,
      multipleChoiceMultiQuestionBuilder: multipleChoiceMultiQuestionBuilder,
      multipleChoiceSingleQuestionBuilder: multipleChoiceSingleQuestionBuilder,
      npsQuestionBuilder: npsQuestionBuilder,
      pictureSelectionQuestionBuilder: pictureSelectionQuestionBuilder,
      rankingQuestionBuilder: rankingQuestionBuilder,
      ratingQuestionBuilder: ratingQuestionBuilder,
    );
  }

  // Cleanup method to be called from outside
  void dispose() {
    _eventSubscription.cancel();
    _eventStream.close();
  }

  // Triggers an event manually (e.g. from UI or user interaction)
  void addEvent(String event) {
    _eventStream.add(event);
  }

  // Estimation logic for timing UX progress bar or estimation
  int calculateEstimatedTime(List<Question> questions) {
    int totalSeconds = 0;
    for (var question in questions) {
      switch (question.type) {
        case 'date':
          totalSeconds += 10;
          break;
        case 'rating':
        case 'nps':
          totalSeconds += 5;
          break;
        default:
          totalSeconds += 10;
      }

      totalSeconds += 5; // Buffer per question

      if (question.required ?? false) {
        totalSeconds += 2; // Extra for mandatory fields
      }
    }

    return totalSeconds;
  }
}
