import 'package:flutter/material.dart';

import 'formbricks_client.dart';
import 'models/survey.dart';
import 'widgets/survey_widget.dart';

class TriggerManager {
  final FormbricksClient client;
  final String userId;
  final Map<String, dynamic> userAttributes;
  final Map<String, int> eventCounts = {};
  final Map<String, bool> completedSurveys = {};
  bool _isInitialized = false;
  Function(String)? onSurveyTriggered;
  final ThemeData? customTheme;

  TriggerManager({
    required this.client,
    required this.userId,
    this.userAttributes = const {},
    this.onSurveyTriggered,
    this.customTheme,
  });

  Future<void> initialize() async {
    // Simulate fetching completed surveys (e.g., from local storage or API)
    _isInitialized = true;
  }

  void trackEvent(String event, BuildContext context) async {
    if (!_isInitialized) await initialize();

    eventCounts[event] = (eventCounts[event] ?? 0) + 1;

    final surveys = await client.getSurveysByTrigger(event);
    for (var surveyData in surveys) {
      final survey = Survey.fromJson(surveyData);

      // Skip completed surveys
      if (completedSurveys[survey.id] == true) continue;

      final logic = survey.logic;
      bool shouldTrigger = true;

      // Evaluate trigger conditions
      if (logic != null) {
        if (logic['event'] != null && logic['event']['name'] != event) {
          shouldTrigger = false;
        }

        if (logic['attributes'] != null) {
          for (var attr in logic['attributes']) {
            final key = attr['key'];
            final value = attr['value'];
            if (userAttributes[key] != value) {
              shouldTrigger = false;
              break;
            }
          }
        }

        if (logic['delay'] != null && eventCounts[event]! < logic['delay']['count']) {
          shouldTrigger = false;
        }
      }

      if (shouldTrigger) {
        completedSurveys[survey.id] = true; // Mark as completed to prevent re-display
        onSurveyTriggered?.call(survey.id);
        // Show survey in a dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Dialog(
            child: SurveyWidget(
              client: client,
              surveyId: survey.id,
              userId: userId,
              customTheme: customTheme,
            ),
          ),
        );
      }
    }
  }

  void updateAttributes(Map<String, dynamic> newAttributes) {
    userAttributes.addAll(newAttributes);
  }
}