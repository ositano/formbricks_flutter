import 'package:flutter/material.dart';
import 'package:card_stack_widget/card_stack_widget.dart';

import '../formbricks_client.dart';
import '../models/survey.dart';
import 'end_widget.dart';
import 'question_widget.dart';
import 'welcome_widget.dart';

class SurveyWidget extends StatefulWidget {
  final FormBricksClient client;
  final Survey survey;
  final String userId;
  final ThemeData? customTheme;
  final bool? showPoweredBy;

  const SurveyWidget({
    super.key,
    required this.client,
    required this.survey,
    required this.userId,
    this.customTheme,
    this.showPoweredBy = true,
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

  ThemeData _buildTheme(BuildContext context) {
    final parentTheme = Theme.of(context);
    final formBricksStyling = survey.styling ?? {};
    final baseTheme = widget.customTheme ?? parentTheme;

    return baseTheme.copyWith(
      primaryColor: Color(
        int.parse(
          formBricksStyling['primaryColor']?.replaceFirst('#', '0xFF') ??
              '0xFF${baseTheme.primaryColor.value.toRadixString(16).padLeft(8, '0')}',
        ),
      ),
      textTheme: baseTheme.textTheme.merge(
        formBricksStyling['fontFamily'] != null
            ? TextTheme(
                headlineMedium: TextStyle(
                  fontFamily: formBricksStyling['fontFamily'],
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                bodyMedium: TextStyle(
                  fontFamily: formBricksStyling['fontFamily'],
                ),
              )
            : null,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(
            Color(
              int.parse(
                formBricksStyling['buttonColor']?.replaceFirst('#', '0xFF') ??
                    '0xFF${baseTheme.primaryColor.value.toRadixString(16).padLeft(8, '0')}',
              ),
            ),
          ),
          foregroundColor: WidgetStateProperty.all(
            Color(
              int.parse(
                formBricksStyling['buttonTextColor']?.replaceFirst(
                      '#',
                      '0xFF',
                    ) ??
                    '0xFFFFFFFF',
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<CardModel> _buildCardStack(BuildContext context) {
    final containerWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final twoHeight = screenHeight * (2 / 5); // 2/5 of screen
    final twoFifthsHeight = screenHeight * (2.5 / 5); // 2.5/5 of screen

    final totalSteps =
        survey.questions.length +
        (survey.welcomeCard?['enabled'] == true ? 1 : 0) +
        1;
    final List<CardModel> cardList = [];

    if (isLoading) {
      return [
        CardModel(
          backgroundColor: Colors.grey,
          radius: const Radius.circular(8),
          shadowColor: Colors.black.withOpacity(0.2),
          child: SizedBox(
            height: twoFifthsHeight,
            width: containerWidth,
            child: const Center(child: CircularProgressIndicator()),
          ),
        ),
      ];
    }
    if (error != null) {
      return [
        CardModel(
          backgroundColor: Colors.red,
          radius: const Radius.circular(8),
          shadowColor: Colors.black.withOpacity(0.2),
          margin: EdgeInsets.only(top: twoFifthsHeight - twoHeight),
          child: SizedBox(
            height: twoFifthsHeight,
            width: containerWidth,
            child: Center(child: Text('Error: $error')),
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
    if (_currentStep == 0 && survey.welcomeCard?['enabled'] == true) {
      content = WelcomeWidget(survey: survey);
      nextLabel = survey.welcomeCard!['buttonLabel']['default'] ?? 'Next';
    } else if (_currentStep > 0 && _currentStep <= survey.questions.length) {
      final question = survey.questions[_currentStep - 1];
      content = Form(
        key: formKey,
        child: QuestionWidget(
          question: question,
          onResponse: _onResponse,
          client: widget.client,
          surveyId: widget.survey.id,
          userId: widget.userId,
          response: responses[question.id],
        ),
      );
      nextLabel = question.buttonLabel?['default'];
      previousLabel = question.backButtonLabel?['default'];
    } else {
      content = EndWidget(survey: survey);
      nextLabel = 'Close';
    }

    cardList.add(
      CardModel(
        backgroundColor: Theme.of(context).cardColor,
        radius: const Radius.circular(8),
        margin: EdgeInsets.only(top: twoFifthsHeight - twoHeight),
        shadowColor: Colors.black.withOpacity(0.2),
        child: SizedBox(
          width: containerWidth,
          height: twoFifthsHeight,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                width: containerWidth,
                height: twoFifthsHeight, // Fixed height for the card
                alignment: Alignment.topCenter, // Align card to bottom
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight:
                          0, // Remove fixed minHeight to allow natural overflow
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        24.0,
                        32.0,
                        24.0,
                        50.0,
                      ), // Extra padding at bottom for stack elements
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: content,
                          ), // Allow content to expand and trigger scroll
                          if (error != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                error!,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (_currentStep > 1)
                                  ElevatedButton(
                                    onPressed: previousStep,
                                    child: Text(previousLabel ?? 'Back'),
                                  ),
                                if (nextLabel != null)
                                  if (_currentStep == 0 ||
                                      (_currentStep > 0 &&
                                          !['rating', 'nps'].contains(
                                            survey.questions
                                                .elementAtOrNull(
                                                  _currentStep - 1,
                                                )
                                                ?.type,
                                          )))
                                    ElevatedButton(
                                      onPressed:
                                          _currentStep ==
                                              survey.questions.length + 1
                                          ? () => Navigator.of(context).pop()
                                          : nextStep,
                                      child: Text(nextLabel),
                                    ),
                              ],
                            ),
                          ),
                          SizedBox(height: twoFifthsHeight - twoHeight),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: twoFifthsHeight - twoHeight, // Align to the very bottom
                left: 0,
                right: 0,
                child: Container(
                  color: Theme.of(context).cardColor,
                  width: containerWidth,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 5.0, bottom: 10.0),
                        child: Text.rich(
                          textAlign: TextAlign.center,
                          TextSpan(
                            text: 'Powered by ',
                            style: Theme.of(context).textTheme.bodySmall,
                            children: [
                              TextSpan(
                                text: 'Formbricks',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                      LinearProgressIndicator(
                        value: (_currentStep + 1) / totalSteps,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor,
                        ),
                        minHeight: 5,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return cardList;
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _buildTheme(context),
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
}
