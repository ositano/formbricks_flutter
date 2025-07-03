import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'formbricks_client.dart';
import 'models/survey.dart';
import 'widgets/survey_widget.dart';

class TriggerManager {
  final FormbricksClient client;
  final String userId;
  final Map<String, dynamic> userAttributes;
  final Map<String, int> eventCounts = {};
  late Map<String, bool> completedSurveys = {};
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
    final prefs = await SharedPreferences.getInstance();
    final completedSurveysJson = prefs.getString('completed_surveys_$userId') ?? '{}';
    completedSurveys = Map<String, bool>.from(
      (jsonDecode(completedSurveysJson) as Map).map((key, value) => MapEntry(key, value as bool)),
    );
    _isInitialized = true;
  }

  Future<void> _saveCompletedSurveys() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('completed_surveys_$userId', jsonEncode(completedSurveys));
  }

  bool _isPhoneDevice(BuildContext context) {
    // Check if device is a phone based on screen size or platform
    final screenWidth = MediaQuery.of(context).size.width;
    return Platform.isAndroid || Platform.isIOS && screenWidth < 600; // Phones typically < 600px
  }

  bool _shouldDisplaySurvey(double displayPercentage) {
    final random = Random().nextDouble() * 100;
    return random <= displayPercentage;
  }

  void trackEvent(String event, BuildContext context) async {
    if (!_isInitialized) await initialize();

    eventCounts[event] = (eventCounts[event] ?? 0) + 1;

    final surveys = await client.getSurveysByTrigger(event);
    for (var surveyData in surveys) {
      final survey = Survey.fromJson(surveyData);

      // Skip completed surveys if displayOption is displayOnce
      if (survey.displayOption == 'displayOnce' && completedSurveys[survey.id] == true) {
        continue;
      }

      final logic = survey.logic;
      final segment = survey.segment;
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

      // Evaluate segment filters (e.g., deviceType: phone)
      if (segment != null && segment['filters'] != null) {
        for (var filter in segment['filters']) {
          final resource = filter['resource'];
          if (resource['root']['type'] == 'device' && resource['root']['deviceType'] == 'phone') {
            if (!_isPhoneDevice(context)) {
              shouldTrigger = false;
              break;
            }
          }
        }
      }

      // Check displayPercentage
      if (survey.displayPercentage != null && !_shouldDisplaySurvey(survey.displayPercentage ?? 0.0)) {
        shouldTrigger = false;
      }

      if (shouldTrigger) {
        completedSurveys[survey.id] = true;
        await _saveCompletedSurveys(); // Persist completed surveys
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
              customTheme: null, // Handled by SurveyWidget's _buildTheme
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