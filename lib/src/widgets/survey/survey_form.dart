import 'package:flutter/material.dart';

import '../../../formbricks_flutter.dart';
import '../../models/question.dart';
import '../end_widget.dart';
import '../question_widget.dart';
import '../welcome_widget.dart';
import 'components/content.dart';
import 'components/error.dart';
import 'components/loading.dart';

class SurveyForm extends StatelessWidget {
  final FormBricksClient client;
  final Survey survey;
  final String userId;
  final ThemeData? customTheme;
  final int estimatedTimeInSecs;
  final int currentStep;
  final int currentStepEnding;
  final bool isLoading;
  final String? error;
  final String? displayId;
  final GlobalKey<FormState> formKey;
  final SurveyDisplayMode surveyDisplayMode;
  final bool showPoweredBy;
  final Function() previousStep;
  final Function() nextStep;
  final Function() nextStepEnding;
  final Function(String, dynamic) onResponse;
  final Map<String, dynamic> responses;
  final Map<String, bool> requiredAnswers;

  const SurveyForm({
    super.key,
    required this.client,
    required this.survey,
    required this.userId,
    this.customTheme,
    required this.currentStep,
    required this.currentStepEnding,
    required this.isLoading,
    this.error,
    this.displayId,
    required this.estimatedTimeInSecs,
    required this.formKey,
    required this.nextStep,
    required this.nextStepEnding,
    required this.previousStep,
    required this.onResponse,
    required this.responses,
    required this.surveyDisplayMode,
    required this.requiredAnswers,
    required this.showPoweredBy
  });


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: _buildSurvey(context),
    );
  }

  Widget _buildSurvey(BuildContext context) {
    final totalSteps = survey.questions.length;

    if (isLoading) {
      return SurveyLoading();
    }
    if (error != null) {
      return SurveyError(errorMessage: error.toString());
    }

    // Add the front interactive card
    Widget content;
    String? nextLabel;
    String? previousLabel;
    Question? question;
    if (currentStep == -1 && survey.welcomeCard?['enabled'] == true) {
      content = WelcomeWidget(survey: survey);
      nextLabel = survey.welcomeCard!['buttonLabel']['default'] ?? 'Next';
    } else if (currentStep < survey.questions.length) {
      question = survey.questions[currentStep];
      question.styleRoundness = styleRoundness(survey);
      content = Form(
        key: formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: QuestionWidget(
          question: question,
          onResponse: onResponse,
          client: client,
          surveyId: survey.id,
          userId: userId,
          response: responses[question.id],
          requiredAnswerByLogicCondition: requiredAnswers.containsKey(question.id),
        ),
      );
      nextLabel = question.buttonLabel?['default'];
      previousLabel = question.backButtonLabel?['default'];
    } else {
      content = EndWidget(ending: survey.endings[currentStepEnding]);
      nextLabel = currentStepEnding == (survey.endings.length - 1) ? AppLocalizations.of(context)!.close : AppLocalizations.of(context)!.next;
    }

    return SurveyContent(
      progress: (currentStep + 1) / totalSteps,
      currentStep: currentStep,
      nextStep: nextStep,
      previousStep: previousStep,
      nextLabel: nextLabel,
      previousLabel: previousLabel,
      onResponse: onResponse,
      survey: survey,
      showPoweredBy: showPoweredBy,
      response: responses[question?.id],
      contentHeight: MediaQuery.of(context).size.height,
      spacerHeight: 0,
      surveyDisplayMode: surveyDisplayMode,
      estimatedTimeInSecs: estimatedTimeInSecs,
      child: content,
    );
  }
}
