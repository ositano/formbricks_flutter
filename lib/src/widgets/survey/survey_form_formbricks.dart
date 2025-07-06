import 'package:flutter/material.dart';
import 'package:card_stack_widget/card_stack_widget.dart';
import 'package:formbricks_flutter/src/models/question.dart';

import '../../../formbricks_flutter.dart';
import '../end_widget.dart';
import '../question_widget.dart';
import '../welcome_widget.dart';
import 'components/content.dart';
import 'components/error.dart';
import 'components/loading.dart';

class SurveyFormFormbricks extends StatefulWidget {
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

  final Function() previousStep;
  final Function() nextStep;
  final Function(String, dynamic) onResponse;
  final Map<String, dynamic> responses;
  final SurveyDisplayMode surveyDisplayMode;

  const SurveyFormFormbricks({
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
  State<SurveyFormFormbricks> createState() => SurveyFormFormbricksState();
}

class SurveyFormFormbricksState extends State<SurveyFormFormbricks> {
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
      child: CardStackWidget(
        opacityChangeOnDrag: true,
        swipeOrientation: CardOrientation.none,
        cardDismissOrientation: CardOrientation.none,
        positionFactor: 1.0,
        scaleFactor: 1.7,
        alignment: Alignment.bottomCenter,
        reverseOrder: false,
        animateCardScale: true,
        dismissedCardDuration: const Duration(milliseconds: 150),
        cardList: _buildCardStack(context),
      ),
    );
  }

  List<CardModel> _buildCardStack(BuildContext context) {
    final containerWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final twoHeight = screenHeight * (2 / 5); // 2/5 of screen
    final twoFifthsHeight = screenHeight * (2.5 / 5); // 2.5/5 of screen

    final totalSteps =
        widget.survey.questions.length +
            (widget.survey.welcomeCard?['enabled'] == true ? 1 : 0) +
            1;
    final List<CardModel> cardList = [];

    if (widget.isLoading) {
      return [
        CardModel(
          backgroundColor: Colors.grey,
          radius: const Radius.circular(8),
          shadowColor: Colors.black.withOpacity(0.2),
          child: SurveyLoading(height: twoFifthsHeight, width: containerWidth),
        ),
      ];
    }
    if (widget.error != null) {
      return [
        CardModel(
          backgroundColor: Colors.red,
          radius: const Radius.circular(8),
          shadowColor: Colors.black.withOpacity(0.2),
          margin: EdgeInsets.only(top: twoFifthsHeight - twoHeight),
          child: SurveyError(
            height: twoFifthsHeight,
            width: containerWidth,
            errorMessage: widget.error.toString(),
          ),
        ),
      ];
    }

    // Add dummy cards for the stack
    for (int i = 0; i < 3; i++) {
      cardList.add(
        CardModel(
          backgroundColor: Theme.of(context).cardColor,
          radius: const Radius.circular(8),
          margin: EdgeInsets.only(top: twoFifthsHeight - twoHeight),
          shadowColor: Colors.black.withOpacity(0.2),
          child: SizedBox(
            height: twoFifthsHeight,
            width: containerWidth,
            child: const Center(child: Text('Dummy Card')),
          ),
        ),
      );
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

    cardList.add(
      CardModel(
        backgroundColor: Theme.of(context).cardColor,
        radius: const Radius.circular(8),
        margin: EdgeInsets.only(top: twoFifthsHeight - twoHeight),
        shadowColor: Colors.black.withOpacity(0.2),
        child: SurveyContent(
          widgetWidth: containerWidth,
          widgetHeight: twoFifthsHeight,
          contentHeight: twoFifthsHeight,
          spacerHeight: twoFifthsHeight - twoHeight,
          bottom: twoFifthsHeight - twoHeight,
          progress: (widget.currentStep + 1) / totalSteps,
          currentStep: widget.currentStep,
          nextStep: widget.nextStep,
          previousStep: widget.previousStep,
          nextLabel: nextLabel,
          previousLabel: previousLabel,
          onResponse: widget.onResponse,
          survey: widget.survey,
          response: widget.responses[question?.id],
          surveyDisplayMode: widget.surveyDisplayMode,
          child: content,
        ),
      ),
    );

    return cardList;
  }
}
