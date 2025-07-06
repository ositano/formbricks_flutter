import 'package:flutter/material.dart';

import '../../../formbricks_flutter.dart';
import '../../models/question.dart';
import '../end_widget.dart';
import '../question_widget.dart';
import '../welcome_widget.dart';
import 'components/content.dart';
import 'components/error.dart';
import 'components/loading.dart';

class SurveyForm extends StatefulWidget {
  final FormBricksClient client;
  final Survey survey;
  final String userId;
  final ThemeData? customTheme;
  final bool? showPoweredBy;
  final bool useWrapInRankingQuestion;

  final int currentStep;
  final bool isLoading;
  final String? error;
  final String? displayId;
  final GlobalKey<FormState> formKey;
  final SurveyDisplayMode surveyDisplayMode;

  final Function() previousStep;
  final Function() nextStep;
  final Function(String, dynamic) onResponse;
  final Map<String, dynamic> responses;

  const SurveyForm({
    super.key,
    required this.client,
    required this.survey,
    required this.userId,
    this.customTheme,
    this.showPoweredBy,
    required this.currentStep,
    required this.isLoading,
    this.error,
    this.displayId,
    required this.formKey,
    required this.nextStep,
    required this.previousStep,
    required this.onResponse,
    required this.responses,
    required this.surveyDisplayMode,
    required this.useWrapInRankingQuestion
  });

  @override
  State<SurveyForm> createState() => SurveyFormState();
}

class SurveyFormState extends State<SurveyForm> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: buildTheme(context, widget.customTheme, widget.survey),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: _buildSurvey(context),
      ),
    );
  }

  Widget _buildSurvey(BuildContext context) {
    final totalSteps =
        widget.survey.questions.length +
        (widget.survey.welcomeCard?['enabled'] == true ? 1 : 0) +
        1;

    if (widget.isLoading) {
      return SurveyLoading();
    }
    if (widget.error != null) {
      return SurveyError(errorMessage: widget.error.toString());
    }

    // Add the front interactive card
    Widget content;
    String? nextLabel;
    String? previousLabel;
    Question? question;
    if (widget.currentStep == 0 &&
        widget.survey.welcomeCard?['enabled'] == true) {
      content = WelcomeWidget(survey: widget.survey);
      nextLabel =
          widget.survey.welcomeCard!['buttonLabel']['default'] ?? 'Next';
    } else if (widget.currentStep > 0 &&
        widget.currentStep <= widget.survey.questions.length) {
      question = widget.survey.questions[widget.currentStep - 1];
      content = Form(
        key: widget.formKey,
        child: QuestionWidget(
          question: question,
          onResponse: widget.onResponse,
          client: widget.client,
          surveyId: widget.survey.id,
          userId: widget.userId,
          response: widget.responses[question.id],
          surveyDisplayMode: widget.surveyDisplayMode,
          useWrapInRankingQuestion: widget.useWrapInRankingQuestion,
        ),
      );
      nextLabel = question.buttonLabel?['default'];
      previousLabel = question.backButtonLabel?['default'];
    } else {
      content = EndWidget(survey: widget.survey);
      nextLabel = 'Close';
    }

    return SurveyContent(
      progress: (widget.currentStep + 1) / totalSteps,
      currentStep: widget.currentStep,
      nextStep: widget.nextStep,
      previousStep: widget.previousStep,
      nextLabel: nextLabel,
      previousLabel: previousLabel,
      onResponse: widget.onResponse,
      survey: widget.survey,
      response: widget.responses[question?.id],
      contentHeight: MediaQuery.of(context).size.height,
      spacerHeight: 0,
      surveyDisplayMode: widget.surveyDisplayMode,
      child: content,
    );
  }
}
