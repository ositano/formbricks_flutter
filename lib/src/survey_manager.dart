// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'dart:math';
//
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../formbricks_flutter.dart';
// import 'models/environment/question.dart';
// import 'survey/webview/survey_webview.dart';
// import 'utils/helper.dart';
//
// // SurveyManager listens for app events and decides when to display surveys
// // based on conditions like triggers, completion state, and percentage chance.
// class SurveyManager {
//   // Dependencies and configuration
//   final FormbricksClient client;
//   late String userId;
//   late Map<String, dynamic> userAttributes;
//
//   // Tracks how many times each event has occurred
//   final Map<String, int> eventCounts = {};
//
//   // Tracks whether surveys have been completed (cached locally)
//   late Map<String, bool> completedSurveys = {};
//
//   // Tracks whether `initialize` has run to avoid duplicate loading
//   bool _isInitialized = false;
//
//   // Optional callback when a survey is triggered
//   Function(String)? onSurveyTriggered;
//
//   // Custom theming and display options
//   final ThemeData? customTheme;
//   final SurveyDisplayMode surveyDisplayMode;
//   final SurveyPlatform surveyPlatform;
//
//   // Handles async event tracking
//   final StreamController<TriggerValue> _eventStream =
//       StreamController<TriggerValue>.broadcast();
//   late StreamSubscription _eventSubscription;
//
//   // List of configured app-level triggers
//   late List<TriggerValue> triggers;
//
//   // Language for internationalization
//   late String language;
//
//   // Used to show surveys in current context
//   final BuildContext context;
//
//   // Optional custom question widget builders
//   final QuestionWidgetBuilder? addressQuestionBuilder;
//   final QuestionWidgetBuilder? calQuestionBuilder;
//   final QuestionWidgetBuilder? consentQuestionBuilder;
//   final QuestionWidgetBuilder? contactInfoQuestionBuilder;
//   final QuestionWidgetBuilder? ctaQuestionBuilder;
//   final QuestionWidgetBuilder? dateQuestionBuilder;
//   final QuestionWidgetBuilder? fileUploadQuestionBuilder;
//   final QuestionWidgetBuilder? freeTextQuestionBuilder;
//   final QuestionWidgetBuilder? matrixQuestionBuilder;
//   final QuestionWidgetBuilder? multipleChoiceMultiQuestionBuilder;
//   final QuestionWidgetBuilder? multipleChoiceSingleQuestionBuilder;
//   final QuestionWidgetBuilder? npsQuestionBuilder;
//   final QuestionWidgetBuilder? pictureSelectionQuestionBuilder;
//   final QuestionWidgetBuilder? rankingQuestionBuilder;
//   final QuestionWidgetBuilder? ratingQuestionBuilder;
//
//   SurveyManager({
//     required this.client,
//     required this.userId,
//     required this.userAttributes,
//     this.onSurveyTriggered,
//     this.customTheme,
//     required this.surveyDisplayMode,
//     required this.surveyPlatform,
//     required this.triggers,
//     required this.language,
//     required this.context,
//     this.addressQuestionBuilder,
//     this.calQuestionBuilder,
//     this.consentQuestionBuilder,
//     this.contactInfoQuestionBuilder,
//     this.ctaQuestionBuilder,
//     this.dateQuestionBuilder,
//     this.fileUploadQuestionBuilder,
//     this.freeTextQuestionBuilder,
//     this.matrixQuestionBuilder,
//     this.multipleChoiceMultiQuestionBuilder,
//     this.multipleChoiceSingleQuestionBuilder,
//     this.npsQuestionBuilder,
//     this.pictureSelectionQuestionBuilder,
//     this.rankingQuestionBuilder,
//     this.ratingQuestionBuilder,
//   }) {
//     // Listen to incoming event stream
//     _eventSubscription = _eventStream.stream.listen(_handleEvent);
//   }
//
//   final List<Survey> _displayQueue = [];
//   final Set<String> _queuedSurveyIds = {};
//   bool _isSurveyDisplaying = false;
//
//   // Getter for current locale
//   String get currentLanguage => language;
//
//   // Update language
//   void setLanguage(String newLanguage) {
//     if (newLanguage.isNotEmpty && newLanguage != language) {
//       language = newLanguage;
//     }
//   }
//
//   void setUserId(String newUserId) {
//     userId = newUserId;
//   }
//
//   // Triggers an event manually (e.g. from UI or user interaction)
//   void addEvent(TriggerValue event) {
//     _eventStream.add(event);
//   }
//
//   // Event handler: increments count and rechecks all surveys
//   void _handleEvent(TriggerValue event) async {
//     eventCounts[event.name] = (eventCounts[event.name] ?? 0) + 1;
//     triggers.add(event);
//     await _loadAndTriggerSurveys();
//   }
//
//   // Cleanup method to be called from outside
//   void dispose() {
//     _eventSubscription.cancel();
//     _eventStream.close();
//   }
//
//   // Loads completed surveys from SharedPreferences
//   Future<void> initialize() async {
//     _displayQueue.clear();
//     _queuedSurveyIds.clear();
//     final prefs = await SharedPreferences.getInstance();
//     final completedSurveysJson =
//         prefs.getString('completed_surveys_$userId') ?? '{}';
//     completedSurveys = Map<String, bool>.from(
//       (jsonDecode(completedSurveysJson) as Map).map(
//         (key, value) => MapEntry(key, value as bool),
//       ),
//     );
//     _isInitialized = true;
//     await _loadAndTriggerSurveys(); // Immediately check for trigger
//   }
//
//   // Saves updated completed survey state to SharedPreferences
//   Future<void> _saveCompletedSurveys() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString(
//       'completed_surveys_$userId',
//       jsonEncode(completedSurveys),
//     );
//   }
//
//   // Determines if a survey should be shown randomly based on displayPercentage
//   bool shouldDisplaySurvey(double? displayPercentage) {
//     if (displayPercentage == null) return true;
//     final random = Random().nextDouble() * 100;
//     return random <= displayPercentage;
//   }
//
//   // Main method to fetch and decide whether to show any surveys
//   Future<void> _loadAndTriggerSurveys() async {
//     if (!_isInitialized) await initialize();
//
//     try {
//       //final surveys = await client.getSurveys();
//       final environmentData = await client.getEnvironmentData();
//       final surveys = environmentData['surveys'] as List;
//       for (var surveyData in surveys) {
//         final survey = Survey.fromJson(surveyData);
//
//         // Skip surveys that are inactive or from another environment
//         if (survey.status != 'inProgress') {
//           continue;
//         }
//
//         //skip surveys that are not within the desired date range
//         if (!isWithinDateRange(survey)) continue;
//
//         final isCompleted = completedSurveys[survey.id] == true;
//
//         // Skip if should run once after completed
//         if (survey.singleUse?['enabled'] == true && isCompleted) continue;
//
//         // Skip if marked completed and only supposed to display once
//         if (survey.displayOption == 'displayOnce' && isCompleted) continue;
//
//         // Evaluate whether any trigger conditions match
//         if (matchesTrigger(survey) == false) continue;
//
//         bool shouldTrigger = true;
//         // Segment filter matching
//         if (survey.segment != null) {
//           shouldTrigger = matchesSegment(survey);
//         }
//
//         // Display percentage control
//         //if (!shouldTrigger || !_shouldDisplaySurvey(survey.displayPercentage)) continue;
//
//         // If it passes all checks, mark as completed and show
//         completedSurveys[survey.id] = true;
//         await _saveCompletedSurveys();
//
//         if (!_queuedSurveyIds.contains(survey.id)) {
//           _displayQueue.add(survey);
//           _queuedSurveyIds.add(survey.id);
//         }
//       }
//       _processSurveyQueue(environmentData);
//     } catch (e, st) {
//       debugPrint('Failed to load survey: $e, stackTrace: $st');
//       //ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load survey: $e')));
//     }
//   }
//
//   bool isWithinDateRange(Survey survey) {
//     final now = DateTime.now();
//     final runOn = DateTime.tryParse(survey.runOnDate ?? '');
//     final closeOn = DateTime.tryParse(survey.closeOnDate ?? '');
//
//     if (runOn != null && now.isBefore(runOn)) return false;
//     if (closeOn != null && now.isAfter(closeOn)) return false;
//
//     return true;
//   }
//
//   bool matchesTrigger(Survey survey) {
//     //don't show survey if there are no triggers either from the dev or Formbricks
//     bool hasDefinedTriggers =
//         triggers.isNotEmpty; //checks if triggers are defined from the user app
//     bool hasSystemTriggers =
//         survey.triggers != null &&
//         survey
//             .triggers!
//             .isNotEmpty; //check if triggers are defined from formbricks interface
//     bool canTrigger = hasDefinedTriggers && hasSystemTriggers;
//     if (canTrigger == false) {
//       return false; //no matches when there are no triggers
//     }
//
//     final surveyTriggers = survey.triggers;
//     for (final t in surveyTriggers!) {
//       final actionClass = t['actionClass'];
//       final surveyTrigger = TriggerValue(name: actionClass?['name']);
//
//       for (final userTrigger in triggers) {
//         if (userTrigger.name == surveyTrigger.name) {
//           return true;
//         }
//       }
//     }
//     return false;
//   }
//
//   bool matchesSegment(Survey survey) {
//     final filters = survey.segment?['filters'] ?? [];
//     return _evaluateSegmentFilters(filters);
//   }
//
//   bool _evaluateSegmentFilters(List<dynamic> filters) {
//     if (filters.isEmpty) return true;
//
//     bool evaluateSingle(Map<String, dynamic> f) {
//       final resource = f['resource'] ?? {};
//       final root = resource['root'] ?? {};
//       final value = resource['value'];
//       final operator = (resource['qualifier']?['operator'] ?? '')
//           .toString()
//           .toLowerCase();
//
//       switch (root['type']) {
//         case 'device':
//           final device = Platform.isAndroid || Platform.isIOS
//               ? 'phone'
//               : 'desktop';
//           return operator == 'equals'
//               ? device == root['deviceType']
//               : operator == 'notEquals'
//               ? device != root['deviceType']
//               : false;
//
//         case 'attribute':
//         case 'person':
//           final key = root['contactAttributeKey'] ?? root['personIdentifier'];
//           final userValue = userAttributes[key];
//           switch (operator) {
//             case 'equals':
//               return userValue?.toString() == value.toString();
//             case 'notEquals':
//               return userValue?.toString() != value.toString();
//             case 'isSet':
//               return userValue != null && userValue.toString().isNotEmpty;
//             case 'isNotSet':
//               return userValue == null || userValue.toString().isEmpty;
//             case 'lessThan':
//               return _toDouble(userValue) < _toDouble(value);
//             case 'lessEqual':
//               return _toDouble(userValue) <= _toDouble(value);
//             case 'greaterThan':
//               return _toDouble(userValue) > _toDouble(value);
//             case 'greaterEqual':
//               return _toDouble(userValue) >= _toDouble(value);
//             case 'contains':
//               return userValue?.toString().contains(value.toString()) ?? false;
//             case 'doesNotContain':
//               return !(userValue?.toString().contains(value.toString()) ??
//                   false);
//             case 'startsWith':
//               return userValue?.toString().startsWith(value.toString()) ??
//                   false;
//             case 'endsWith':
//               return userValue?.toString().endsWith(value.toString()) ?? false;
//             default:
//               return false;
//           }
//         case 'segment':
//           final userSegment = userAttributes['segmentId'];
//           if (operator == 'userIsIn') return userSegment == value;
//           if (operator == 'userIsNotIn') return userSegment != value;
//           return false;
//         default:
//           return false;
//       }
//     }
//
//     bool result = evaluateSingle(filters.first);
//     for (int i = 1; i < filters.length; i++) {
//       final connector = filters[i]['connector']?.toString().toLowerCase();
//       final nextResult = evaluateSingle(filters[i]);
//
//       result = (connector == 'or')
//           ? result || nextResult
//           : result && nextResult;
//     }
//
//     return result;
//   }
//
//   double _toDouble(dynamic value) {
//     try {
//       return double.parse(value.toString());
//     } catch (_) {
//       return 0.0;
//     }
//   }
//
//   Future<void> _processSurveyQueue(Map<String, dynamic> environmentData) async {
//     if (_isSurveyDisplaying || _displayQueue.isEmpty) return;
//
//     _isSurveyDisplaying = true;
//     final survey = _displayQueue.removeAt(0);
//     _queuedSurveyIds.remove(survey.id);
//
//     if (surveyPlatform == SurveyPlatform.flutter) {
//       await showSurveyAsync(survey); // wait for survey to complete
//     } else {
//       await showSurveyWeb(survey, environmentData);
//     }
//     _isSurveyDisplaying = false;
//     _processSurveyQueue(environmentData); // move to next
//   }
//
//   // Displays the survey in the selected display mode
//   Future<void> showSurveyWeb(
//     Survey survey,
//     Map<String, dynamic> environmentData,
//   ) async {
//     onSurveyTriggered?.call(survey.id);
//     String platform = Platform.isIOS ? "iOS" : "android";
//     final completer = Completer<void>();
//     final widget = Container(
//       color: Colors.white,
//       child: SurveyWebview(
//         client: client,
//         survey: survey,
//         userId: userId,
//         surveyDisplayMode: surveyDisplayMode,
//         language: language,
//         environmentData: environmentData,
//         onComplete: () {
//           completer.complete();
//         },
//         platform: platform,
//       ),
//     );
//
//     // bottom sheet mode
//     showModalBottomSheet(
//       context: context,
//       isDismissible: survey.projectOverwrites?['clickOutsideClose'] ?? false,
//       backgroundColor: Colors.transparent,
//       builder: (context) => DraggableScrollableSheet(
//         initialChildSize: 1.0,
//         minChildSize: 0.3,
//         maxChildSize: 1.0,
//         builder: (context, scrollController) => widget,
//       ),
//     );
//
//     return completer.future;
//   }
//
//   // Displays the survey in the selected display mode
//   Future<void> showSurveyAsync(Survey survey) async {
//     onSurveyTriggered?.call(survey.id);
//     int estimatedTimeInSecs = calculateEstimatedTime(survey.questions);
//
//     final completer = Completer<void>();
//     final widget = surveyDisplayMode == SurveyDisplayMode.fullScreen
//         ? _buildSurveyScreen(
//             survey,
//             estimatedTimeInSecs,
//             onComplete: () {
//               completer.complete();
//             },
//           )
//         : Theme(
//             data: buildTheme(context, customTheme, survey),
//             child: _buildSurveyWidget(
//               survey,
//               estimatedTimeInSecs,
//               onComplete: () {
//                 completer.complete();
//               },
//             ),
//           );
//
//     // Full-screen modal
//     if (surveyDisplayMode == SurveyDisplayMode.fullScreen) {
//       Navigator.push(
//         context,
//         Platform.isIOS
//             ? CupertinoPageRoute(builder: (context) => widget)
//             : MaterialPageRoute(builder: (context) => widget),
//       );
//
//       // Dialog mode
//     } else if (surveyDisplayMode == SurveyDisplayMode.dialog) {
//       showDialog(
//         context: context,
//         barrierDismissible:
//             survey.projectOverwrites?['clickOutsideClose'] ?? false,
//         builder: (context) => AlertDialog(
//           backgroundColor: Theme.of(context).cardColor,
//           titlePadding: EdgeInsets.zero,
//           contentPadding: EdgeInsets.zero,
//           actionsPadding: EdgeInsets.zero,
//           content: widget,
//         ),
//       );
//       // Bottom sheet mode
//     } else {
//       showModalBottomSheet(
//         context: context,
//         isDismissible: survey.projectOverwrites?['clickOutsideClose'] ?? false,
//         backgroundColor: Theme.of(context).cardColor,
//         builder: (context) => widget,
//       );
//     }
//     return completer.future;
//   }
//
//   // Builds themed full-screen survey view
//   Widget _buildSurveyScreen(
//     Survey survey,
//     int estimatedTimeInSecs, {
//     VoidCallback? onComplete,
//   }) {
//     return Theme(
//       data: buildTheme(context, customTheme, survey),
//       child: Scaffold(
//         backgroundColor: Theme.of(context).cardColor,
//         body: _buildSurveyWidget(
//           survey,
//           estimatedTimeInSecs,
//           onComplete: onComplete,
//         ),
//       ),
//     );
//   }
//
//   // Creates the SurveyWidget with all required props and builders
//   SurveyWidget _buildSurveyWidget(
//     Survey survey,
//     int estimatedTimeInSecs, {
//     VoidCallback? onComplete,
//   }) {
//     return SurveyWidget(
//       client: client,
//       survey: survey,
//       userId: userId,
//       surveyDisplayMode: surveyDisplayMode,
//       estimatedTimeInSecs: estimatedTimeInSecs,
//       addressQuestionBuilder: addressQuestionBuilder,
//       calQuestionBuilder: ctaQuestionBuilder,
//       consentQuestionBuilder: consentQuestionBuilder,
//       contactInfoQuestionBuilder: contactInfoQuestionBuilder,
//       ctaQuestionBuilder: ctaQuestionBuilder,
//       dateQuestionBuilder: dateQuestionBuilder,
//       fileUploadQuestionBuilder: fileUploadQuestionBuilder,
//       freeTextQuestionBuilder: freeTextQuestionBuilder,
//       matrixQuestionBuilder: matrixQuestionBuilder,
//       multipleChoiceMultiQuestionBuilder: multipleChoiceMultiQuestionBuilder,
//       multipleChoiceSingleQuestionBuilder: multipleChoiceSingleQuestionBuilder,
//       npsQuestionBuilder: npsQuestionBuilder,
//       pictureSelectionQuestionBuilder: pictureSelectionQuestionBuilder,
//       rankingQuestionBuilder: rankingQuestionBuilder,
//       ratingQuestionBuilder: ratingQuestionBuilder,
//       onComplete: onComplete,
//     );
//   }
//
//   // Estimation logic for timing questions
//   int calculateEstimatedTime(List<Question> questions) {
//     int total = 0;
//     for (final q in questions) {
//       total += (q.type == 'nps' || q.type == 'rating') ? 5 : 10;
//       total += 5;
//       if (q.required == true) total += 2;
//     }
//     return total;
//   }
// }
