import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../formbricks_flutter.dart';
import '../../models/environment/logic.dart';
import '../../utils/helper.dart';
import 'components/error.dart';
import 'components/loading.dart';
import 'survey_form.dart';

/// Main Flutter widget that renders a full survey experience for a user.
class SurveyWidget extends StatefulWidget {

  final FormbricksClient client;
  final Survey survey;
  final String userId;
  final int estimatedTimeInSecs;
  final SurveyDisplayMode surveyDisplayMode;
  final VoidCallback? onComplete;
  final bool clickOutsideClose;

  /// Optional custom question widget builders
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

  const SurveyWidget({
    super.key,
    required this.client,
    required this.survey,
    required this.userId,
    required this.estimatedTimeInSecs,
    required this.surveyDisplayMode,
    required this.onComplete,
    required this.clickOutsideClose,
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
  State<SurveyWidget> createState() => SurveyWidgetState();
}

class SurveyWidgetState extends State<SurveyWidget> {
  /// Tracks current position in the survey.
  int _currentStep = -1;
  int _currentEndingStep = 0;

  /// Tracks if user has interacted with the survey
  bool hasUserInteracted = false;

  /// Track visited question IDs
  final List<String> _visitedQuestionIds = [];


  /// Local instance of survey to allow mutation
  late Survey survey;

  /// Stores user responses keyed by questionId
  Map<String, dynamic> responses = {};

  /// Stores variable values used in condition evaluation or calculation
  final Map<String, dynamic> _variables = {};

  bool isLoading = true;
  String? error;
  String? displayId;


  final formKey = GlobalKey<FormState>();

  /// Tracks which question is required (based on logic conditions)
  final Map<String, bool> _requiredAnswers = {};

  Timer? _inactivityTimer;
  late int _inactivitySecondsRemaining;

  @override
  void initState() {
    _inactivitySecondsRemaining = widget.survey.autoClose ?? 10;
    hasUserInteracted = false;
    /// Skip welcome screen if disabled
    if (widget.survey.welcomeCard?['enabled'] == false) {
      _currentStep++;
    }
    super.initState();
    _fetchSurvey();
    _createDisplay();
    _initializeVariables();
    WidgetsBinding.instance.addPostFrameCallback((_){
      if(widget.survey.autoClose != null) {
        _startInactivityTimer(widget.survey.autoClose!);
      }
    });
  }

  @override
  void dispose() {
    _inactivityTimer?.cancel();
    super.dispose();
  }

  /// Starts the inactivity timer
  void _startInactivityTimer(int seconds) {
    _inactivityTimer?.cancel();
    setState(() => _inactivitySecondsRemaining = seconds);

    _inactivityTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_inactivitySecondsRemaining == 1) {
        timer.cancel();
        if(!hasUserInteracted) {
          _closeSurvey();
        }
      } else {
        setState(() => _inactivitySecondsRemaining--);
      }
    });
  }

  /// Called after survey.autoClose seconds of inactivity
  void _closeSurvey() {
    if(mounted) {
      widget.onComplete?.call(); // notify TriggerManager to show next
      Navigator.of(context).maybePop();
    }
  }

  /// Loads the survey data
  void _fetchSurvey() {
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

  /// Registers a display session for formbricks analytics/tracking
  Future<void> _createDisplay() async {
    try {
      displayId = await widget.client.createDisplay(
        surveyId: widget.survey.id,
        userId: widget.userId,
      );
      if(mounted) {
        context.userManager?.onDisplay(widget.survey.id);
      }
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    }
  }

  /// Callback when a user answers a question
  void _onResponse(String questionId, dynamic value) {
    setState(() {
      responses[questionId] = value;
    });
  }

  /// To avoid multiple submission at a time
  bool _isSubmitting = false;

  /// Submits the survey data to the backend
  Future<void> _submitSurvey() async {
    if (_isSubmitting) return;
    _isSubmitting = true;
    setState(() {
      error = null;
    });

    if (survey.hiddenFields?['enabled'] == true) {
      for (var fieldId in survey.hiddenFields?['fieldIds'] ?? []) {
        if (!responses.containsKey(fieldId)) {
          responses[fieldId] = ''; // or any default value
        }
      }
    }

    try {
      await widget.client.submitResponse(
        surveyId: widget.survey.id,
        userId: widget.userId,
        data: responses,
      );
      if (survey.delay != null) {
        Future.delayed(Duration(seconds: survey.delay!.toInt()), () {
          _closeSurvey();
        });
      }
      if(mounted) {
        context.userManager?.onResponse(widget.survey.id);
        if (kDebugMode) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Survey submitted successfully!')),
          );
        }
      }
    } on SocketException {
      // Internet unavailable
      _cacheUserResponseOnError({
        'surveyId': widget.survey.id,
        'userId': widget.userId,
        'data': responses,
        'finished': true,
      });
    } on HttpException {
      _cacheUserResponseOnError({
        'surveyId': widget.survey.id,
        'userId': widget.userId,
        'data': responses,
        'finished': true,
      });
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    }finally {
      _isSubmitting = false;
    }
  }

  /// caching UserResponse on Internet failure or Server issue
  void _cacheUserResponseOnError(Map<String, dynamic> userResponse){
    context.surveyManager?.setUnSyncUserResponse(userResponse);
  }


  /// Advances to the next question, applying logic if needed
  /// assumptions [there would only be one jump action in a list of actions]
  /// jump action is the only action that takes you to another question and alters the user experience
  /// require answer and calculate basically happens behind the scene
  void nextStep() {
    hasUserInteracted = true;
    final form = formKey.currentState;
    form?.validate();

    /// Show questions if welcome card is enabled
    if (_currentStep == -1 && survey.welcomeCard?['enabled'] == true) {
      setState(() => _currentStep++);
      return;
    }

    final currentQuestion = survey.questions.elementAtOrNull(_currentStep);
    if (currentQuestion == null) {
      if (_currentStep >= survey.questions.length) {
        _showEnding();
        _submitSurvey();
      }
      return;
    }

    _trackVisit(currentQuestion.id);

    /// Evaluate logic, if defined
    if (currentQuestion.logic != null && currentQuestion.logic!.isNotEmpty) {
      bool anyLogicMatched = false;
      String? jumpTarget;

      for (final logic in currentQuestion.logic!) {
        if (_evaluateConditions(logic.conditions)) {
          anyLogicMatched = true;

          for (final action in logic.actions) {
            if (action.objective == LogicActionObjective.jumpToQuestion) {
              jumpTarget = action.target; // Handle jump later
            } else {
              _executeAction(action); // e.g., requireAnswer, calculate
            }
          }
        }
      }

      /// Jump action takes precedence if matched
      if (jumpTarget != null) {
        _jumpToQuestion(jumpTarget);
        return;
      }

      if (anyLogicMatched) {
        /// If answer is required but missing, block next step
        if (_requiredAnswers[currentQuestion.id] == true &&
            !responses.containsKey(currentQuestion.id)) {
          form?.validate();
          return;
        }

        _advanceToNextOrEnd();
        return;
      }

      /// No logic matched, fallback
      if (currentQuestion.logicFallback != null) {
        _jumpToQuestion(currentQuestion.logicFallback!);
        return;
      }
    }

    /// No logic to evaluate
    if (_requiredAnswers[currentQuestion.id] == true &&
        !responses.containsKey(currentQuestion.id)) {
      form?.validate();
      return;
    }

    _advanceToNextOrEnd();
  }

/// Moves to the next step or finishes the survey
  void _advanceToNextOrEnd() {
    if ((formKey.currentState?.validate() ?? false) &&
        _currentStep < survey.questions.length) {
      setState(() => _currentStep++);
    }

    if (_currentStep >= survey.questions.length) {
      _showEnding();
      _submitSurvey();
    }
  }

  /// Record the question ID if it hasn't already been recorded as the last entry in the list.
  void _trackVisit(String questionId) {
    if (_visitedQuestionIds.isEmpty || _visitedQuestionIds.last != questionId) {
      _visitedQuestionIds.add(questionId);
    }
  }

  void goBack() {
    if (_visitedQuestionIds.length > 1) {
      _visitedQuestionIds.removeLast(); // remove current
      final previousId = _visitedQuestionIds.last;

      final index = survey.questions.indexWhere((q) => q.id == previousId);
      if (index != -1) {
        setState(() => _currentStep = index);
      }
    } else if (_visitedQuestionIds.length == 1 && survey.welcomeCard?['enabled'] == true) {
      setState(() => _currentStep = -1); // Back to welcome
    }
  }

  /// Moves one step back
  void previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  /// Shows the ending screen
  void _showEnding() {
    setState(() {
      _currentStep = survey.questions.length;
      _currentEndingStep = 0;
    });
  }

  /// Advances to next part of the ending screen (multi-step ending)
  void _endingStep() {
    setState(() => _currentEndingStep++);
  }

  /// Initializes variables used in logic conditions and calculations
  void _initializeVariables() {
    _variables.addAll({
      for (var v in survey.variables ?? []) v['id']: v['value'],
    });
  }

/// Recursively evaluates a a tree of conditions, that can contain mixed types of condition or conditionDetail
  bool _evaluateConditions(dynamic conditions) {
    if (conditions == null || conditions.conditions == null || conditions.conditions.isEmpty) return true;

    bool result = conditions.connector == ConditionConnector.and;

    for (var condition in conditions.conditions) {
      bool conditionResult;

      /// Handle nested group condition (Condition)
      if (condition is Map<String, dynamic> && condition.containsKey('conditions') || condition is Condition) {
        conditionResult = _evaluateConditions(condition is Condition ? condition : Condition.fromJson(condition));
      }
      /// Handle atomic condition (ConditionDetail)
      else if (condition is Map<String, dynamic> && condition.containsKey('operator') || condition is ConditionDetail) {
        final detail = condition is ConditionDetail ? condition : ConditionDetail.fromJson(condition);
        final leftValue = _getOperandValue(detail.leftOperand);
        final rightValue = detail.rightOperand != null
            ? _getOperandValue(detail.rightOperand!)
            : null;
        conditionResult = _evaluateCondition( leftValue, detail.operator, rightValue);
      }
      /// Fallback true for unexpected cases
      else {
        conditionResult = true;
      }

      /// Combine results using AND / OR logic
      if (conditions.connector == ConditionConnector.and) {
        result = result && conditionResult;
        if (!result) break; // early exit for AND
      } else {
        result = result || conditionResult;
        if (result) break; // early exit for OR
      }
    }

    return result;
  }


  /// Resolves operand values from responses or variables
  dynamic _getOperandValue(Operand operand) {
    switch (operand.type) {
      case OperandType.question: return responses[operand.value] ?? '';
      case OperandType.static: return operand.value;
      case OperandType.variable: return _variables[operand.value] ?? 0;
      }
  }

  /// Applies basic comparison operators for logic conditions
  bool _evaluateCondition(dynamic left, ConditionOperator operator, dynamic right) {

    ///Picks the left id for comparison for multiple choice and pictureSelection questions
    final currentQuestion = survey.questions.elementAtOrNull(_currentStep);
    if(currentQuestion?.type == QuestionType.multipleChoiceSingle || currentQuestion?.type == QuestionType.multipleChoiceMulti || currentQuestion?.type == QuestionType.pictureSelection){
      String? choiceId = getIdFromChoices(currentQuestion?.choices ?? [], left, currentQuestion?.type == QuestionType.pictureSelection);
      if(choiceId != null) {
        left = choiceId;
      }
    }

    switch (operator) {
      case ConditionOperator.equals: return left == right;
      case ConditionOperator.equalsOneOf: return (right as List).contains(left.toString());
      case ConditionOperator.isLessThan: return num.parse(left.toString()) < num.parse(right.toString());
      case ConditionOperator.isLessThanOrEqual: return num.parse(left.toString()) <= num.parse(right.toString());
      case ConditionOperator.isGreaterThan: return num.parse(left.toString()) > num.parse(right.toString());
      case ConditionOperator.isGreaterThanOrEqual: return num.parse(left.toString()) >= num.parse(right.toString());
      case ConditionOperator.doesNotEqual: return left != right;
      case ConditionOperator.contains: return left.toString().contains(right.toString());
      case ConditionOperator.doesNotContain: return !left.toString().contains(right.toString());
      case ConditionOperator.startsWith: return left.toString().startsWith(right.toString());
      case ConditionOperator.doesNotStartWith: return !left.toString().startsWith(right.toString());
      case ConditionOperator.endsWith: return left.toString().endsWith(right.toString());
      case ConditionOperator.doesNotEndWith: return !left.toString().endsWith(right.toString());
      case ConditionOperator.isSubmitted: // Evaluate only at the point of progressing from the specific question
        /// Make sure 'left' refers to a questionId
        if (left is String) {
          return responses.containsKey(left);
        } else if (left is Map && left['value'] is String) {
          return responses.containsKey(left['value']);
        }
        return false;
      default:
        return false;
      }
  }

  /// Extracts ID from choices of MultipleChoice questions
  String? getIdFromChoices(List<Map<String, dynamic>> choices, String value, bool isPictureSelection) {
    if(isPictureSelection){
      for (final choice in choices) {
        if (choice['imageUrl'] == value) {
          return choice['id'];
        }
      }
      return null;
    }else{
      for (final choice in choices) {
        if (translate(choice['label'], context) == value) {
          return choice['id'];
        }
      }
      return null;
    } // Return null if no match found
  }

  /// Executes an action from a logic block
  void _executeAction(LogicAction action) {
    switch (action.objective) {
      case LogicActionObjective.jumpToQuestion:
        _jumpToQuestion(action.target!);
        break;
      case LogicActionObjective.requireAnswer:
        _requireAnswer(action.target ?? action.variableId);
        break;
      case LogicActionObjective.calculate:
        _calculateValue(action);
        break;
    }
  }

  /// Moves to a specific question by ID
  void _jumpToQuestion(String targetId) {
    _currentStep = survey.questions.indexWhere((q) => q.id == targetId);
    if (_currentStep == -1) {
      _showEnding();
      _submitSurvey();
    }else {
      _trackVisit(targetId);
      if (mounted) setState(() {});
    }
  }

  /// Evaluates a calculation and updates the variable value
  void _calculateValue(LogicAction action) {
    final variableId = action.variableId;
    if (variableId == null) return;

    dynamic leftValue = _variables[variableId] ?? 0;
    dynamic rightValue = _getOperandValue(Operand.fromJson(action.value));

    if (leftValue is! num || rightValue is! num) return;

    num result;
    switch (action.operator) {
      case LogicActionOperator.add: result = leftValue + rightValue; break;
      case LogicActionOperator.subtract: result = leftValue - rightValue; break;
      case LogicActionOperator.multiply: result = leftValue * rightValue; break;
      case LogicActionOperator.divide: result = rightValue != 0 ? leftValue / rightValue : leftValue; break;
      case LogicActionOperator.assign: result = rightValue; break;
      default: result = leftValue;
    }
    _variables[variableId] = result;
  }

  /// Marks a question as required and triggers validation
  void _requireAnswer(String? targetId) {
    final targetQuestion = survey.questions.firstWhere(
          (q) => q.id == targetId,
      orElse: () => survey.questions.firstWhere(
            (q) => q.id == _variables.keys.firstWhere((k) => _variables[k] == targetId, orElse: () => ""),
        orElse: () => Question(id: '', type: QuestionType.unSupportedType, headline: {}, required: false, logic: []),
      ),
    );
    if (targetQuestion.id.isNotEmpty) {
      _requiredAnswers[targetQuestion.id] = true;
      formKey.currentState?.validate();
      setState(() {});
    }
  }

  /// Builds the main UI of the survey
  @override
  Widget build(BuildContext context) {
    if (isLoading) return SurveyLoading();
    if (error != null && kDebugMode) return SurveyError(errorMessage: error.toString());

    return Container(
      color: Theme.of(context).cardColor,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SurveyForm(
        client: widget.client,
        userId: widget.userId,
        currentStep: _currentStep,
        isLoading: isLoading,
        formKey: formKey,
        nextStep: nextStep,
        previousStep: goBack,
        onResponse: _onResponse,
        survey: survey,
        responses: responses,
        surveyDisplayMode: widget.surveyDisplayMode,
        requiredAnswers: _requiredAnswers,
        estimatedTimeInSecs: widget.estimatedTimeInSecs,
        currentStepEnding: _currentEndingStep,
        nextStepEnding: _endingStep,
        onComplete: widget.onComplete,
        clickOutsideClose: widget.clickOutsideClose,
        hasUserInteracted: hasUserInteracted,
        inactivitySecondsRemaining: _inactivitySecondsRemaining,
        // Custom widget builders
        calQuestionBuilder: widget.ctaQuestionBuilder,
        consentQuestionBuilder: widget.consentQuestionBuilder,
        contactInfoQuestionBuilder: widget.contactInfoQuestionBuilder,
        ctaQuestionBuilder: widget.ctaQuestionBuilder,
        dateQuestionBuilder: widget.dateQuestionBuilder,
        fileUploadQuestionBuilder: widget.fileUploadQuestionBuilder,
        freeTextQuestionBuilder: widget.freeTextQuestionBuilder,
        matrixQuestionBuilder: widget.matrixQuestionBuilder,
        multipleChoiceMultiQuestionBuilder: widget.multipleChoiceMultiQuestionBuilder,
        multipleChoiceSingleQuestionBuilder: widget.multipleChoiceSingleQuestionBuilder,
        npsQuestionBuilder: widget.npsQuestionBuilder,
        pictureSelectionQuestionBuilder: widget.pictureSelectionQuestionBuilder,
        rankingQuestionBuilder: widget.rankingQuestionBuilder,
        ratingQuestionBuilder: widget.ratingQuestionBuilder,
      ),
    );
  }
}
