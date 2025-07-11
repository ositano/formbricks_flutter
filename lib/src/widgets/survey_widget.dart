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
  int _currentStep =
      -1; // 0 = welcome, 1+ = questions, questions.length + 1 = ending
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
    //_evaluateLogic(_currentQuestionId!);
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

    if (_currentStep == -1 && survey.welcomeCard?['enabled'] == true) {
      setState(() => _currentStep++); // Move to first question (index 0)
      return; // Exit early, no logic or validation needed for welcome
    }

    final currentQuestion = survey.questions.elementAtOrNull(_currentStep);
    if (currentQuestion == null) {
      if (_currentStep >= survey.questions.length) {
        _showEnding();
        _submitSurvey();
      }
      return; // Exit if no valid question (e.g., end of survey)
    }

    // Evaluate logic for the current question
    if (currentQuestion.logic.isNotEmpty) {
      for (Logic logic in currentQuestion.logic) {
        if (_evaluateConditions(logic.conditions)) {
          debugPrint("passed");
          for (var action in logic.actions) {
            _executeAction(action);
          }
        } else if (currentQuestion.logicFallback != null) {
          debugPrint("not passed");
          _jumpToQuestion(currentQuestion.logicFallback!);
          return; // Exit after jumping
        }else{
          // Check form validity, including dynamic required fields
          if (_requiredAnswers[currentQuestion.id] == true && !responses.containsKey(currentQuestion.id)) {
            //form?.validate();
            return; // Block progression if required but unanswered
          }

          if (_currentStep < survey.questions.length && (form?.validate() ?? false)) {
            setState(() => _currentStep++);
          } else if (_currentStep >= survey.questions.length) {
            _showEnding();
            _submitSurvey();
          }
        }
      }
      return;
    }

    // Check form validity, including dynamic required fields
    if (_requiredAnswers[currentQuestion.id] == true && !responses.containsKey(currentQuestion.id)) {
      //form?.validate();
      return; // Block progression if required but unanswered
    }

    if (_currentStep < survey.questions.length && (form?.validate() ?? false)) {
      setState(() => _currentStep++);
    } else if (_currentStep >= survey.questions.length) {
      _showEnding();
      _submitSurvey();
    }
  }

  // void nextStep() {
  //   debugPrint("clicked next step....");
  //   final form = formKey.currentState;
  //
  //   // Force interaction on all fields
  //   form?.validate();
  //
  //   if (_currentStep == -1 && survey.welcomeCard?['enabled'] == true) {
  //     setState(() => _currentStep++);
  //   } else if (_currentStep < survey.questions.length &&
  //       (form?.validate() ?? false)) {
  //     setState(() => _currentStep++);
  //   } else if (_currentStep >= survey.questions.length) {
  //     _showEnding();
  //     _submitSurvey();
  //   }
  // }

  void previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _showEnding() {
    setState(() => _currentStep = survey.questions.length);
  }

  void _initializeVariables() {
    _variables.addAll({
      for (var v in survey.variables ?? []) v['id']: v['value'],
    });
  }

  // void _evaluateLogic(String questionId) {
  //   final currentQuestion = survey.questions.firstWhere(
  //     (q) => q.id == questionId,
  //   );
  //   if (currentQuestion.logic.isEmpty) {
  //     debugPrint("stopping here...");
  //     return;
  //   }
  //
  //   for (Logic logic in currentQuestion.logic) {
  //     if (_evaluateConditions(logic.conditions)) {
  //
  //       for (var action in logic.actions) {
  //         _executeAction(action);
  //       }
  //     } else if (currentQuestion.logicFallback != null) {
  //       debugPrint("not passed");
  //       _jumpToQuestion(currentQuestion.logicFallback!);
  //     }
  //   }
  // }

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
        debugPrint("equals: $left, $right");
        return left == right;
      case "equalsOneOf":
        return (right as List).contains(left.toString());
      case 'isLessThan':
        debugPrint("isless than::::  left: $left, right: $right");
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
        debugPrint("jumping to question: ${action.target}");
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
    debugPrint("target id: $targetId");
    _currentStep = survey.questions.indexWhere((q) => q.id == targetId);
    debugPrint("jump to index: $_currentStep");
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
            widget.estimatedTimeInSecs, // Pass to SurveyForm for validation
      ),
    );
  }
}
