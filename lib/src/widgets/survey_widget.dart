import 'package:flutter/material.dart';

import '../../formbricks_flutter.dart';
import '../models/logic.dart';
import '../models/question.dart';
import 'survey/survey_form.dart';

class SurveyWidget extends StatefulWidget {
  final FormBricksClient client;
  final Survey survey;
  final String userId;
  final int estimatedTimeInSecs;
  final SurveyDisplayMode surveyDisplayMode;
  final bool showPoweredBy;

  const SurveyWidget({
    super.key,
    required this.client,
    required this.survey,
    required this.userId,
    required this.estimatedTimeInSecs,
    required this.surveyDisplayMode,
    required this.showPoweredBy,
  });

  @override
  State<SurveyWidget> createState() => SurveyWidgetState();
}

class SurveyWidgetState extends State<SurveyWidget> {
  int _currentStep = -1; // -1 = welcome, 0+ = questions, questions.length >= ending
  int _currentEndingStep = 0;

  late Survey survey;
  Map<String, dynamic> responses = {}; // User responses
  final Map<String, dynamic> _variables = {}; // Store calculated variables
  bool isLoading = true;
  String? error;
  String? displayId;
  String? _currentQuestionId;
  final formKey = GlobalKey<FormState>();
  final Map<String, bool> _requiredAnswers =
      {}; // Track required answers from logic

  @override
  void initState() {
    super.initState();
    _fetchSurvey();
    _createDisplay();
    _initializeVariables();
    WidgetsBinding.instance.addPostFrameCallback((_){
      if(survey.welcomeCard?['enabled'] == false){
        setState(() => _currentStep++);
      }
    });
  }

  @override
  void dispose() {
    // Clean up if needed (e.g., cancel any ongoing requests)
    super.dispose();
  }

  Future<void> _fetchSurvey() async {
    try {
      setState(() {
        survey = widget
            .survey; // Assume survey is pre-loaded; adjust if fetched asynchronously
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
      _currentQuestionId = questionId;
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
    final form = formKey.currentState;
    form?.validate();

    // Handle welcome screen
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

    // Evaluate logic
    if (currentQuestion.logic.isNotEmpty) {
      bool anyLogicMatched = false;

      for (Logic logic in currentQuestion.logic) {
        if (_evaluateConditions(logic.conditions)) {
          debugPrint("✅ logic condition matched");

          anyLogicMatched = true;
          for (var action in logic.actions) {
            _executeAction(action);

            // Exit if jump occurs
            if (action.objective == 'jumpToQuestion') {
              return;
            }
          }
        }
      }

      if (!anyLogicMatched && currentQuestion.logicFallback != null) {
        debugPrint("↪️ logic not matched, jumping to fallback");
        _jumpToQuestion(currentQuestion.logicFallback!);
        return;
      }

      // If logic evaluated but no jump occurred and no fallback, continue normally
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

    // If no logic, validate and proceed normally
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


  void previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _showEnding() {
    setState(() {
      _currentStep = survey.questions.length;
      _currentEndingStep = 0;
    });
  }

  void _endingStep(){
    setState(() => _currentEndingStep++);
  }

  void _initializeVariables() {
    _variables.addAll({
      for (var v in survey.variables ?? []) v['id']: v['value'],
    });
  }

  bool _evaluateConditions(dynamic conditions) {
    if (conditions == null) return true;
    if (conditions.conditions.isEmpty) return true;

    bool result = conditions.connector == 'and';
    for (var condition in conditions.conditions) {
      bool conditionResult;
      if (condition is ConditionDetail) {
        final leftValue = _getOperandValue(condition.leftOperand);
        final rightValue = condition.rightOperand != null
            ? _getOperandValue(condition.rightOperand!)
            : null;
        conditionResult = _evaluateCondition(
          leftValue,
          condition.operator,
          rightValue,
        );
      } else if (condition is Condition) {
        conditionResult = _evaluateConditions(condition);
      } else {
        conditionResult = true; // Fallback for unexpected structure
      }

      if (conditions.connector == 'and') {
        result = result && conditionResult;
      } else {
        result = result || conditionResult;
      }
    }
    return result;
  }

  dynamic _getOperandValue(Operand operand) {
    if (operand.type == 'question') {
      return responses[operand.value] ?? '';
    } else if (operand.type == 'static') {
      return operand.value;
    } else if (operand.type == 'variable') {
      return _variables[operand.value] ?? 0;
    }
    return '';
  }

  bool _evaluateCondition(dynamic left, String operator, dynamic right) {
    switch (operator) {
      case 'equals':
        return left == right;
      case "equalsOneOf":
        return (right as List).contains(left.toString());
      case 'isLessThan':
        return num.parse(left.toString()) < num.parse(right.toString());
      case 'isLessThanOrEqual':
        return num.parse(left.toString()) <= num.parse(right.toString());
      case 'isGreaterThan':
        return num.parse(left.toString()) > num.parse(right.toString());
      case 'isGreaterThanOrEqual':
        return num.parse(left.toString()) >= num.parse(right.toString());
      case 'doesNotEqual':
        return left != right;
      case 'contains':
        debugPrint("left: $left, right: $right");
        return left.toString().contains(right.toString());
      case 'doesNotContain':
        return !left.toString().contains(right.toString());
      case 'startsWith':
        return left.toString().startsWith(right.toString());
      case 'doesNotStartWith':
        return !left.toString().startsWith(right.toString());
      case 'endsWith':
        return left.toString().endsWith(right.toString());
      case 'doesNotEndWith':
        return !left.toString().endsWith(right.toString());
      case 'isSubmitted':
        return responses.containsKey(left['value']);
      default:
        return false;
    }
  }

  void _executeAction(LogicAction action) {
    switch (action.objective) {
      case 'jumpToQuestion':
        _jumpToQuestion(action.target!);
        break;
      case 'requireAnswer':
        _requireAnswer(
          action.target ?? action.variableId,
        ); // Target or variableId as context
        break;
      case 'calculate':
        _calculateValue(action);
        break;
    }
  }

  void _jumpToQuestion(String targetId) {
    _currentStep = survey.questions.indexWhere((q) => q.id == targetId);
    if(_currentStep == -1){
      _currentStep = survey.questions.length;
    }
    if (mounted) {
      setState(() {});
    }
    return;
  }

  void _calculateValue(LogicAction action) {
    final variableId = action.variableId;
    if (variableId == null) return;

    dynamic leftValue = _variables[variableId] ?? 0;
    dynamic rightValue = _getOperandValue(action.value as Operand);

    if (leftValue is! num || rightValue is! num) {
      debugPrint('Invalid numeric values for calculation');
      return;
    }

    num result;
    switch (action.operator) {
      case 'Add':
        result = leftValue + rightValue;
        break;
      case 'Subtract':
        result = leftValue - rightValue;
        break;
      case 'Multiply':
        result = leftValue * rightValue;
        break;
      case 'Divide':
        result = rightValue != 0 ? leftValue / rightValue : leftValue;
        break;
      case 'Assign':
        result = rightValue;
        break;
      default:
        result = leftValue;
    }
    _variables[variableId] = result;
    debugPrint('Calculated $variableId: ${_variables[variableId]}');
  }

  void _requireAnswer(String? targetId) {
    final targetQuestion = survey.questions.firstWhere(
      (q) => q.id == targetId,
      orElse: () => survey.questions.firstWhere(
        (q) =>
            q.id ==
            _variables.keys.firstWhere(
              (k) => _variables[k] == targetId,
              orElse: () => "",
            ),
        orElse: () => Question(
          id: '',
          type: '',
          headline: {},
          required: false,
          logic: [],
        ),
      ),
    );
    if (targetQuestion.id.isNotEmpty) {
      // Mark as required and trigger validation
      _requiredAnswers[targetQuestion.id] = true;
      // Trigger form validation for the specific field (requires SurveyForm integration)
      formKey.currentState?.validate();
      setState(() {}); // Refresh UI to reflect validation state
    }
  }

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
        estimatedTimeInSecs:
            widget.estimatedTimeInSecs,
        currentStepEnding: _currentEndingStep,
        nextStepEnding: _endingStep, // Pass to SurveyForm for validation
      ),
    );
  }
}
