import 'package:flutter/material.dart';

import '../../../formbricks_flutter.dart';
import '../../models/question.dart';
import '../../utils/helper.dart';
import '../end_widget.dart';
import '../question_widget.dart';
import '../welcome_widget.dart';
import 'components/content.dart';
import 'components/error.dart';
import 'components/loading.dart';

class SurveyForm extends StatelessWidget {
  final FormbricksClient client;
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
  final Function() previousStep;
  final Function() nextStep;
  final Function() nextStepEnding;
  final Function(String, dynamic) onResponse;
  final Map<String, dynamic> responses;
  final Map<String, bool> requiredAnswers;
  final VoidCallback? onComplete;

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
    required this.onComplete,

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
          requiredAnswerByLogicCondition: requiredAnswers.containsKey(
            question.id,
          ),
          addressQuestionBuilder: addressQuestionBuilder,
          calQuestionBuilder: ctaQuestionBuilder,
          consentQuestionBuilder: consentQuestionBuilder,
          contactInfoQuestionBuilder: contactInfoQuestionBuilder,
          ctaQuestionBuilder: ctaQuestionBuilder,
          dateQuestionBuilder: dateQuestionBuilder,
          fileUploadQuestionBuilder: fileUploadQuestionBuilder,
          freeTextQuestionBuilder: freeTextQuestionBuilder,
          matrixQuestionBuilder: matrixQuestionBuilder,
          multipleChoiceMultiQuestionBuilder:
              multipleChoiceMultiQuestionBuilder,
          multipleChoiceSingleQuestionBuilder:
              multipleChoiceSingleQuestionBuilder,
          npsQuestionBuilder: npsQuestionBuilder,
          pictureSelectionQuestionBuilder: pictureSelectionQuestionBuilder,
          rankingQuestionBuilder: rankingQuestionBuilder,
          ratingQuestionBuilder: ratingQuestionBuilder,
        ),
      );
      nextLabel = question.buttonLabel?['default'];
      previousLabel = question.backButtonLabel?['default'];
    } else {

      nextLabel = currentStepEnding == (survey.endings.length - 1)
          ? AppLocalizations.of(context)!.close
          : AppLocalizations.of(context)!.next;

      content = EndWidget(
        ending: survey.endings[currentStepEnding],
        showCloseButton: currentStepEnding == (survey.endings.length - 1),
        onComplete: onComplete,
        nextLabel: nextLabel );
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
      response: responses[question?.id],
      contentHeight: MediaQuery.of(context).size.height,
      spacerHeight: 0,
      surveyDisplayMode: surveyDisplayMode,
      estimatedTimeInSecs: estimatedTimeInSecs,
      onComplete: onComplete,
      child: content,
    );
  }
}
