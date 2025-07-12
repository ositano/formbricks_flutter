import 'package:flutter/material.dart';

import '../../formbricks_flutter.dart';
import '../models/logic.dart';
import '../models/question.dart';
import '../utils/helper.dart';
import 'survey/survey_form.dart';

// Main widget that renders a full survey experience for a user.
class SurveyWidget extends StatefulWidget {

  final FormbricksClient client;
  final Survey survey;
  final String userId;
  final int estimatedTimeInSecs;
  final SurveyDisplayMode surveyDisplayMode;
  final bool showPoweredBy;

  // Optional custom question widget builders
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
    required this.showPoweredBy,
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
  // Tracks current position in the survey.
  int _currentStep = -1;
  int _currentEndingStep = 0;

  // Local instance of survey to allow mutation
  late Survey survey;

  // Stores user responses keyed by questionId
  Map<String, dynamic> responses = {};

  // Stores variable values used in condition evaluation or calculation
  final Map<String, dynamic> _variables = {};

  bool isLoading = true;
  String? error;
  String? displayId;
  String? _currentQuestionId;

  final formKey = GlobalKey<FormState>();

  // Tracks which question is required (based on logic conditions)
  final Map<String, bool> _requiredAnswers = {};

  @override
  void initState() {
    super.initState();
    _fetchSurvey();
    _createDisplay();
    _initializeVariables();

    // Skip welcome screen if disabled
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (survey.welcomeCard?['enabled'] == false) {
        setState(() => _currentStep++);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Loads the survey data
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

  // Registers a display session for formbricks analytics/tracking
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

  // Callback when a user answers a question
  void _onResponse(String questionId, dynamic value) {
    setState(() {
      _currentQuestionId = questionId;
      responses[questionId] = value;
    });
  }

  // Submits the survey data to the backend
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

  // Advances to the next question, applying logic if needed
  void nextStep() {
    final form = formKey.currentState;
    form?.validate();

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

    // Logic evaluation
    if (currentQuestion.logic.isNotEmpty) {
      bool anyLogicMatched = false;

      for (Logic logic in currentQuestion.logic) {
        if (_evaluateConditions(logic.conditions)) {
          anyLogicMatched = true;
          for (var action in logic.actions) {
            _executeAction(action);
            if (action.objective == 'jumpToQuestion') return;
          }
        }
      }

      // Jump to fallback if no logic matched
      if (!anyLogicMatched && currentQuestion.logicFallback != null) {
        _jumpToQuestion(currentQuestion.logicFallback!);
        return;
      }

      // Continue normally
      if (!anyLogicMatched) {
        if (_requiredAnswers[currentQuestion.id] == true &&
            !responses.containsKey(currentQuestion.id)) {
          form?.validate();
          return;
        }

        if (_currentStep < survey.questions.length &&
            (form?.validate() ?? false)) {
          setState(() => _currentStep++);
        } else if (_currentStep >= survey.questions.length) {
          _showEnding();
          _submitSurvey();
        }
      }

      return;
    }

    // No logic present, proceed normally
    if (_requiredAnswers[currentQuestion.id] == true &&
        !responses.containsKey(currentQuestion.id)) {
      form?.validate();
      return;
    }

    if (_currentStep < survey.questions.length &&
        (form?.validate() ?? false)) {
      setState(() => _currentStep++);
    } else if (_currentStep >= survey.questions.length) {
      _showEnding();
      _submitSurvey();
    }
  }

  // Moves one step back
  void previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  // Shows the ending screen
  void _showEnding() {
    setState(() {
      _currentStep = survey.questions.length;
      _currentEndingStep = 0;
    });
  }

  // Advances to next part of the ending screen (multi-step ending)
  void _endingStep() {
    setState(() => _currentEndingStep++);
  }

  // Initializes variables used in logic conditions and calculations
  void _initializeVariables() {
    _variables.addAll({
      for (var v in survey.variables ?? []) v['id']: v['value'],
    });
  }

  // Recursively evaluates a tree of conditions
  bool _evaluateConditions(dynamic conditions) {
    if (conditions == null || conditions.conditions.isEmpty) return true;

    bool result = conditions.connector == 'and';
    for (var condition in conditions.conditions) {
      bool conditionResult;

      if (condition is ConditionDetail) {
        final leftValue = _getOperandValue(condition.leftOperand);
        final rightValue = condition.rightOperand != null
            ? _getOperandValue(condition.rightOperand!)
            : null;
        conditionResult = _evaluateCondition(leftValue, condition.operator, rightValue);
      } else if (condition is Condition) {
        conditionResult = _evaluateConditions(condition);
      } else {
        conditionResult = true;
      }

      result = conditions.connector == 'and'
          ? result && conditionResult
          : result || conditionResult;
    }

    return result;
  }

  // Resolves operand values from responses or variables
  dynamic _getOperandValue(Operand operand) {
    switch (operand.type) {
      case 'question': return responses[operand.value] ?? '';
      case 'static': return operand.value;
      case 'variable': return _variables[operand.value] ?? 0;
      default: return '';
    }
  }

  // Applies basic comparison operators for logic conditions
  bool _evaluateCondition(dynamic left, String operator, dynamic right) {
    switch (operator) {
      case 'equals': return left == right;
      case 'equalsOneOf': return (right as List).contains(left.toString());
      case 'isLessThan': return num.parse(left.toString()) < num.parse(right.toString());
      case 'isLessThanOrEqual': return num.parse(left.toString()) <= num.parse(right.toString());
      case 'isGreaterThan': return num.parse(left.toString()) > num.parse(right.toString());
      case 'isGreaterThanOrEqual': return num.parse(left.toString()) >= num.parse(right.toString());
      case 'doesNotEqual': return left != right;
      case 'contains': return left.toString().contains(right.toString());
      case 'doesNotContain': return !left.toString().contains(right.toString());
      case 'startsWith': return left.toString().startsWith(right.toString());
      case 'doesNotStartWith': return !left.toString().startsWith(right.toString());
      case 'endsWith': return left.toString().endsWith(right.toString());
      case 'doesNotEndWith': return !left.toString().endsWith(right.toString());
      case 'isSubmitted': return responses.containsKey(left['value']);
      default: return false;
    }
  }

  // Executes an action from a logic block
  void _executeAction(LogicAction action) {
    switch (action.objective) {
      case 'jumpToQuestion':
        _jumpToQuestion(action.target!);
        break;
      case 'requireAnswer':
        _requireAnswer(action.target ?? action.variableId);
        break;
      case 'calculate':
        _calculateValue(action);
        break;
    }
  }

  // Moves to a specific question by ID
  void _jumpToQuestion(String targetId) {
    _currentStep = survey.questions.indexWhere((q) => q.id == targetId);
    if (_currentStep == -1) {
      _currentStep = survey.questions.length;
    }
    if (mounted) setState(() {});
  }

  // Evaluates a calculation and updates the variable value
  void _calculateValue(LogicAction action) {
    final variableId = action.variableId;
    if (variableId == null) return;

    dynamic leftValue = _variables[variableId] ?? 0;
    dynamic rightValue = _getOperandValue(action.value as Operand);

    if (leftValue is! num || rightValue is! num) return;

    num result;
    switch (action.operator) {
      case 'add': result = leftValue + rightValue; break;
      case 'subtract': result = leftValue - rightValue; break;
      case 'multiply': result = leftValue * rightValue; break;
      case 'divide': result = rightValue != 0 ? leftValue / rightValue : leftValue; break;
      case 'assign': result = rightValue; break;
      default: result = leftValue;
    }
    _variables[variableId] = result;
  }

  // Marks a question as required and triggers validation
  void _requireAnswer(String? targetId) {
    final targetQuestion = survey.questions.firstWhere(
          (q) => q.id == targetId,
      orElse: () => survey.questions.firstWhere(
            (q) => q.id == _variables.keys.firstWhere((k) => _variables[k] == targetId, orElse: () => ""),
        orElse: () => Question(id: '', type: '', headline: {}, required: false, logic: []),
      ),
    );
    if (targetQuestion.id.isNotEmpty) {
      _requiredAnswers[targetQuestion.id] = true;
      formKey.currentState?.validate();
      setState(() {});
    }
  }

  // Builds the main UI of the survey
  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (error != null) return Center(child: Text('Error: $error'));

    return Container(
      color: Theme.of(context).cardColor,
      child: SurveyForm(
        client: widget.client,
        userId: widget.userId,
        currentStep: _currentStep,
        isLoading: isLoading,
        formKey: formKey,
        showPoweredBy: widget.showPoweredBy,
        nextStep: nextStep,
        previousStep: previousStep,
        onResponse: _onResponse,
        survey: survey,
        responses: responses,
        surveyDisplayMode: widget.surveyDisplayMode,
        requiredAnswers: _requiredAnswers,
        estimatedTimeInSecs: widget.estimatedTimeInSecs,
        currentStepEnding: _currentEndingStep,
        nextStepEnding: _endingStep,

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
