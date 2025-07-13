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
  late String userId;
  late Map<String, dynamic> userAttributes;

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
  late String locale;

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

  final List<Survey> _displayQueue = [];
  final Set<String> _queuedSurveyIds = {};
  bool _isSurveyDisplaying = false;

  // Getter for current locale
  String get currentLocale => locale;

  // Update locale
  void setLocale(String newLocale) {
    if (newLocale.isNotEmpty && newLocale != locale) {
      locale = newLocale;
    }
  }

  void setUserId(String newUserId) {
    userId = newUserId;
  }

  // Triggers an event manually (e.g. from UI or user interaction)
  void addEvent(String event) {
    _eventStream.add(event);
  }

  // Event handler: increments count and rechecks all surveys
  void _handleEvent(String event) async {
    eventCounts[event] = (eventCounts[event] ?? 0) + 1;
    await _loadAndTriggerSurveys();
  }

  // Cleanup method to be called from outside
  void dispose() {
    _eventSubscription.cancel();
    _eventStream.close();
  }

  // Loads completed surveys from SharedPreferences
  Future<void> initialize() async {
    _displayQueue.clear();
    _queuedSurveyIds.clear();
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
    return random <= displayPercentage;
  }

  // Main method to fetch and decide whether to show any surveys
  Future<void> _loadAndTriggerSurveys() async {
    if (!_isInitialized) await initialize();

    try {
      final surveys = await client.getSurveys();
      for (var surveyData in surveys) {
        final survey = Survey.fromJson(surveyData);

        // Skip surveys that are inactive or from another environment
        if (survey.environmentId != client.environmentId || survey.status != 'inProgress') continue;

        //skip surveys that are not within the desired date range
        if (!_isWithinDateRange(survey)) continue;

        final isCompleted = completedSurveys[survey.id] == true;

        // Skip if should run once after completed
        if (survey.singleUse?['enabled'] == true && isCompleted) continue;

        // Skip if marked completed and only supposed to display once
        if (survey.displayOption == 'displayOnce' && isCompleted) continue;

        // Evaluate whether any trigger conditions match
        if(_matchesTrigger(survey) == false) continue;


        bool shouldTrigger = true;
        // Segment filter matching
        if (survey.segment != null) {
          shouldTrigger = _matchesSegment(survey);
        }

        // Display percentage control
        //if (!shouldTrigger || !_shouldDisplaySurvey(survey.displayPercentage)) continue;

        // If it passes all checks, mark as completed and show
        completedSurveys[survey.id] = true;
        await _saveCompletedSurveys();

        if (!_queuedSurveyIds.contains(survey.id)) {
          _displayQueue.add(survey);
          _queuedSurveyIds.add(survey.id);
        }
        //_showSurvey(survey);
      }
      _processSurveyQueue();
    } catch (e, st) {
      debugPrint('Failed to load survey: $e, stackTrace: $st');
      //ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load survey: $e')));
    }
  }

  bool _isWithinDateRange(Survey survey) {
    final now = DateTime.now();
    final runOn = DateTime.tryParse(survey.runOnDate ?? '');
    final closeOn = DateTime.tryParse(survey.closeOnDate ?? '');

    if (runOn != null && now.isBefore(runOn)) return false;
    if (closeOn != null && now.isAfter(closeOn)) return false;

    return true;
  }

  bool _matchesTrigger(Survey survey) {
    //don't show survey if there are no triggers either from the dev or Formbricks
    bool hasDefinedTriggers = triggers != null && triggers!.isNotEmpty;
    bool hasSystemTriggers = survey.triggers != null && survey.triggers!.isNotEmpty;
    bool canTrigger = hasDefinedTriggers && hasSystemTriggers;
    if (canTrigger == false) return false;

    final surveyTriggers = survey.triggers;
    for (final t in surveyTriggers!) {
      final actionClass = t['actionClass'];
      final surveyTrigger = TriggerValue(type: actionClass?['type'] == TriggerType.code.name ? TriggerType.code : TriggerType.noCode, name: actionClass?['name'], key: actionClass?['key']);

      for (final userTrigger in triggers!) {
        if (surveyTrigger.type == TriggerType.noCode && userTrigger.type == surveyTrigger.type && userTrigger.name == surveyTrigger.name){
          return true;
        }
        if (surveyTrigger.type == TriggerType.code && userTrigger.type == surveyTrigger.type && userTrigger.key == surveyTrigger.key) {
          return true;
        }
      }
    }
    return false;
  }

  bool _matchesSegment(Survey survey) {
    final filters = survey.segment?['filters'] ?? [];
    return _evaluateSegmentFilters(filters);
  }

  bool _evaluateSegmentFilters(List<dynamic> filters) {
    if (filters.isEmpty) return true;

    bool evaluateSingle(Map<String, dynamic> f) {
      final resource = f['resource'] ?? {};
      final root = resource['root'] ?? {};
      final value = resource['value'];
      final operator = (resource['qualifier']?['operator'] ?? '').toString().toLowerCase();

      switch (root['type']) {
        case 'device':
          final device = Platform.isAndroid || Platform.isIOS ? 'phone' : 'desktop';
          return operator == 'equals'
              ? device == root['deviceType']
              : operator == 'notEquals'
              ? device != root['deviceType']
              : false;

        case 'attribute':
        case 'person':
          final key = root['contactAttributeKey'] ?? root['personIdentifier'];
          final userValue = userAttributes[key];
          switch (operator) {
            case 'equals':
              return userValue?.toString() == value.toString();
            case 'notEquals':
              return userValue?.toString() != value.toString();
            case 'isSet':
              return userValue != null && userValue.toString().isNotEmpty;
            case 'isNotSet':
              return userValue == null || userValue.toString().isEmpty;
            case 'lessThan':
              return _toDouble(userValue) < _toDouble(value);
            case 'lessEqual':
              return _toDouble(userValue) <= _toDouble(value);
            case 'greaterThan':
              return _toDouble(userValue) > _toDouble(value);
            case 'greaterEqual':
              return _toDouble(userValue) >= _toDouble(value);
            case 'contains':
              return userValue?.toString().contains(value.toString()) ?? false;
            case 'doesNotContain':
              return !(userValue?.toString().contains(value.toString()) ?? false);
            case 'startsWith':
              return userValue?.toString().startsWith(value.toString()) ?? false;
            case 'endsWith':
              return userValue?.toString().endsWith(value.toString()) ?? false;
            default:
              return false;
          }

        case 'segment':
          final userSegment = userAttributes['segmentId'];
          if (operator == 'userIsIn') return userSegment == value;
          if (operator == 'userIsNotIn') return userSegment != value;
          return false;

        default:
          return false;
      }
    }

    bool result = evaluateSingle(filters.first);
    for (int i = 1; i < filters.length; i++) {
      final connector = filters[i]['connector']?.toString().toLowerCase();
      final nextResult = evaluateSingle(filters[i]);

      result = (connector == 'or') ? result || nextResult : result && nextResult;
    }

    return result;
  }

  double _toDouble(dynamic value) {
    try {
      return double.parse(value.toString());
    } catch (_) {
      return 0.0;
    }
  }

  Future<void> _processSurveyQueue() async {
    if (_isSurveyDisplaying || _displayQueue.isEmpty) return;

    _isSurveyDisplaying = true;
    final survey = _displayQueue.removeAt(0);
    _queuedSurveyIds.remove(survey.id);

    await _showSurveyAsync(survey); // wait for survey to complete
    _isSurveyDisplaying = false;
    _processSurveyQueue(); // move to next
  }


  // Displays the survey in the selected display mode
  Future<void> _showSurveyAsync(Survey survey) async{
    onSurveyTriggered?.call(survey.id);
    int estimatedTimeInSecs = calculateEstimatedTime(survey.questions);

    final completer = Completer<void>();
    final widget = surveyDisplayMode == SurveyDisplayMode.fullScreen ? _buildSurveyScreen(survey, estimatedTimeInSecs, onComplete: (){
      completer.complete();
    }) : Theme(
      data: buildTheme(context, customTheme, survey),
      child: _buildSurveyWidget(survey, estimatedTimeInSecs, onComplete: (){
        completer.complete();
      }),
    );

    // Full-screen modal
    if (surveyDisplayMode == SurveyDisplayMode.fullScreen) {
      Navigator.push(
        context,
        Platform.isIOS
            ? CupertinoPageRoute(builder: (context) => widget)
            : MaterialPageRoute(builder: (context) => widget),
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
          content: widget,
        ),
      );

      // Bottom sheet mode
    } else {
      showModalBottomSheet(
        context: context,
        isDismissible: false,
        backgroundColor: Theme.of(context).cardColor,
        builder: (context) => widget,
      );
    }
    return completer.future;
  }

  // Builds themed full-screen survey view
  Widget _buildSurveyScreen(Survey survey, int estimatedTimeInSecs, {VoidCallback? onComplete}) {
    return Theme(
      data: buildTheme(context, customTheme, survey),
      child: Scaffold(
        backgroundColor: Theme.of(context).cardColor,
        body: _buildSurveyWidget(survey, estimatedTimeInSecs, onComplete: onComplete),
      ),
    );
  }

  // Creates the SurveyWidget with all required props and builders
  SurveyWidget _buildSurveyWidget(Survey survey, int estimatedTimeInSecs, {VoidCallback? onComplete}) {
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
      onComplete: onComplete,
    );
  }

  // Estimation logic for timing UX progress bar or estimation
  int calculateEstimatedTime(List<Question> questions) {
    int total = 0;
    for (final q in questions) {
      total += (q.type == 'nps' || q.type == 'rating') ? 5 : 10;
      total += 5;
      if (q.required == true) total += 2;
    }
    return total;
  }
}
