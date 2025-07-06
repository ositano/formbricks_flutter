import 'package:flutter/material.dart';
import '../../formbricks_flutter.dart';

import 'survey/survey_form.dart';
import 'survey/survey_form_formbricks.dart';

class SurveyWidget extends StatefulWidget {
  final FormBricksClient client;
  final Survey survey;
  final String userId;
  final ThemeData? customTheme;
  final bool? showPoweredBy;
  final SurveyDisplayMode surveyDisplayMode;
  final bool useWrapInRankingQuestion;

  const SurveyWidget({
    super.key,
    required this.client,
    required this.survey,
    required this.userId,
    this.customTheme,
    this.showPoweredBy = true,
    required this.surveyDisplayMode,
    required this.useWrapInRankingQuestion,
  });

  @override
  State<SurveyWidget> createState() => SurveyWidgetState();
}

class SurveyWidgetState extends State<SurveyWidget> {
  int _currentStep =
      0; // 0 = welcome, 1+ = questions, questions.length + 1 = ending
  late Survey survey;
  Map<String, dynamic> responses = {};
  bool isLoading = true;
  String? error;
  String? displayId;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _fetchSurvey();
    _createDisplay();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _fetchSurvey() async {
    try {
      setState(() {
        survey = widget.survey;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _createDisplay() async {
    try {
      displayId = await widget.client.createDisplay(
        surveyId: widget.survey.id,
        userId: widget.userId,
      );
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    }
  }

  void _onResponse(String questionId, dynamic value) {
    setState(() {
      responses[questionId] = value;
    });
  }

  Future<void> _submitSurvey() async {
    setState(() {
      error = null;
    });

    try {
      await widget.client.submitResponse(
        surveyId: widget.survey.id,
        userId: widget.userId,
        data: responses,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Survey submitted successfully!')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    }
  }

  void nextStep() {
    if (_currentStep == 0 && survey.welcomeCard?['enabled'] == true) {
      setState(() => _currentStep++);
    } else if (_currentStep < survey.questions.length &&
        (formKey.currentState?.validate() ?? false)) {
      setState(() => _currentStep++);
    } else {
      if (_currentStep >= survey.questions.length) {
        _showEnding();
        _submitSurvey();
      }
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _showEnding() {
    setState(() => _currentStep = survey.questions.length + 1);
  }

  @override
  Widget build(BuildContext context) {
    return widget.surveyDisplayMode == SurveyDisplayMode.formbricks
        ? SurveyFormFormbricks(
            client: widget.client,
            userId: widget.userId,
            currentStep: _currentStep,
            isLoading: isLoading,
            formKey: formKey,
            nextStep: nextStep,
            previousStep: previousStep,
            onResponse: _onResponse,
            survey: survey,
            responses: responses,
            surveyDisplayMode: widget.surveyDisplayMode,
            useWrapInRankingQuestion: widget.useWrapInRankingQuestion,
          )
        : SurveyForm(
            client: widget.client,
            userId: widget.userId,
            currentStep: _currentStep,
            isLoading: isLoading,
            formKey: formKey,
            nextStep: nextStep,
            previousStep: previousStep,
            onResponse: _onResponse,
            survey: survey,
            responses: responses,
            surveyDisplayMode: widget.surveyDisplayMode,
            useWrapInRankingQuestion: widget.useWrapInRankingQuestion,
          );
  }
}
