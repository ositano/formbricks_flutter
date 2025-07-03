import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'formbricks_client.dart';
import 'models/survey.dart';
import 'widgets/survey_widget.dart';

class TriggerManager {
  final FormBricksClient client;
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

  bool _shouldDisplaySurvey(double? displayPercentage) {
    if (displayPercentage == null) return true;
    final random = Random().nextDouble() * 100;
    return random <= displayPercentage;
  }

  void trackEvent(String event, BuildContext context) async {
    if (!_isInitialized) await initialize();

    eventCounts[event] = (eventCounts[event] ?? 0) + 1;

    try {
      // Fetch surveys from API where triggers.actionClass.name matches the event
      final surveys = await client.getSurveysByTrigger(event);
      for (var surveyData in surveys) {
        final survey = Survey.fromJson(surveyData);

        // Skip if survey is not inProgress or environmentId doesn't match
        if (survey.status != 'inProgress' || survey.environmentId != client.environmentId) {
          continue;
        }
        debugPrint("just passed status");

        // Skip completed surveys if displayOption is displayOnce
        if (survey.displayOption == 'displayOnce' && completedSurveys[survey.id] == true) {
          continue;
        }

        debugPrint("just passed display option");

        bool shouldTrigger = false;

        // Check triggers
        if (survey.triggers != null) {
          for (var trigger in survey.triggers!) {
            final actionClass = trigger['actionClass'];
            if (actionClass != null &&
                ((actionClass['type'] == 'noCode' && actionClass['name'] == event) ||
                (actionClass['type'] == 'code' && actionClass['key'] == event))) {
              shouldTrigger = true;
              break;
            }
          }
        }
        debugPrint("should trigger is true");
        if (!shouldTrigger) continue;

        // Evaluate segment filters (e.g., deviceType: phone)
        if (survey.segment != null && survey.segment!['filters'] != null) {
          for (var filter in survey.segment!['filters']) {
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
        if (survey.displayPercentage != null && !_shouldDisplaySurvey(survey.displayPercentage!)) {
          shouldTrigger = false;
        }

        if (shouldTrigger) {
          completedSurveys[survey.id] = true;
          await _saveCompletedSurveys();
          onSurveyTriggered?.call(survey.id);
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => Dialog(
              child: SurveyWidget(
                client: client,
                surveyId: survey.id,
                userId: userId,
                customTheme: customTheme, // Handled by SurveyWidget's _buildTheme
              ),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error fetching surveys for event $event: $e');
      // Optionally show a user-friendly error via ScaffoldMessenger
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load survey: $e')),
      );
    }
  }

  Future<void> showSurvey(String surveyId, BuildContext context) async {
    if (!_isInitialized) await initialize();

    try {
      final surveyData = await client.getSurvey(surveyId);
      final survey = Survey.fromJson(surveyData);

      // Skip if survey is not inProgress or environmentId doesn't match
      if (survey.status != 'inProgress' || survey.environmentId != client.environmentId) {
        return;
      }
      debugPrint("just passed status");

      // Skip completed surveys if displayOption is displayOnce
      if (survey.displayOption == 'displayOnce' && completedSurveys[survey.id] == true) {
        return;
      }
      debugPrint("just passed display option");

      bool shouldTrigger = true;

      // Evaluate segment filters (e.g., deviceType: phone)
      if (survey.segment != null && survey.segment!['filters'] != null) {
        for (var filter in survey.segment!['filters']) {
          final resource = filter['resource'];
          if (resource['root']['type'] == 'device' && resource['root']['deviceType'] == 'phone') {
            if (!_isPhoneDevice(context)) {
              shouldTrigger = false;
              break;
            }
          }
        }
      }
      debugPrint("just passed segment filter");

      // Check displayPercentage
      if (!_shouldDisplaySurvey(survey.displayPercentage)) {
        shouldTrigger = false;
      }

      debugPrint("just passed display percentage");

      if (shouldTrigger) {
        completedSurveys[survey.id] = true;
        await _saveCompletedSurveys();
        onSurveyTriggered?.call(survey.id);
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
    } catch (e) {
      debugPrint('Error fetching survey $surveyId: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load survey: $e')),
      );
    }
  }

  void updateAttributes(Map<String, dynamic> newAttributes) {
    userAttributes.addAll(newAttributes);
  }
}