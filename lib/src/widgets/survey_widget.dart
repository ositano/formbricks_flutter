import 'package:flutter/material.dart';

import '../formbricks_client.dart';
import '../models/question.dart';
import '../models/survey.dart';
import 'question_types/address_question.dart';
import 'question_types/consent_question.dart';
import 'question_types/contact_info_question.dart';
import 'question_types/date_question.dart';
import 'question_types/file_upload_question.dart';
import 'question_types/free_text_question.dart';
import 'question_types/matrix_question.dart';
import 'question_types/multi_select_question.dart';
import 'question_types/nps_question.dart';
import 'question_types/picture_selection_question.dart';
import 'question_types/ranking_question.dart';
import 'question_types/rating_question.dart';
import 'question_types/schedule_meeting_question.dart';
import 'question_types/single_select_question.dart';
import 'question_types/statement_question.dart';


class SurveyWidget extends StatefulWidget {
  final FormBricksClient client;
  final String surveyId;
  final String userId;
  final ThemeData? customTheme;

  const SurveyWidget({
    super.key,
    required this.client,
    required this.surveyId,
    required this.userId,
    this.customTheme,
  });

  @override
  State<SurveyWidget> createState() => _SurveyWidgetState();
}

class _SurveyWidgetState extends State<SurveyWidget> {
  Survey? survey;
  int currentQuestionIndex = 0;
  Map<String, dynamic> responses = {};
  bool isLoading = true;
  String? error;
  String? displayId;

  @override
  void initState() {
    super.initState();
    _fetchSurvey();
    _createDisplay();
  }

  Future<void> _fetchSurvey() async {
    try {
      final surveyData = await widget.client.getSurvey(widget.surveyId);
      setState(() {
        survey = Survey.fromJson(surveyData);
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
        surveyId: widget.surveyId,
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
    if (survey == null) return;

    setState(() {
      error = null;
    });

    try {
      await widget.client.submitResponse(
        surveyId: widget.surveyId,
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

  void _nextQuestion() {
    if (survey == null || currentQuestionIndex >= survey!.questions.length - 1) {
      _submitSurvey();
    } else {
      setState(() {
        currentQuestionIndex++;
      });
    }
  }

  void _previousQuestion() {
    if (currentQuestionIndex > 0) {
      setState(() {
        currentQuestionIndex--;
      });
    }
  }

  ThemeData _buildTheme(BuildContext context) {
    final parentTheme = Theme.of(context);
    final formbricksStyling = survey?.styling ?? {};
    final baseTheme = widget.customTheme ?? parentTheme;

    return baseTheme.copyWith(
      primaryColor: Color(int.parse(formbricksStyling['primaryColor']?.replaceFirst('#', '0xFF') ?? '0xFF${baseTheme.primaryColor.value.toRadixString(16).padLeft(8, '0')}')),
      textTheme: baseTheme.textTheme.merge(
        formbricksStyling['fontFamily'] != null
            ? TextTheme(
          headlineMedium: TextStyle(
            fontFamily: formbricksStyling['fontFamily'],
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          bodyMedium: TextStyle(
            fontFamily: formbricksStyling['fontFamily'],
          ),
        )
            : null,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(
            Color(int.parse(formbricksStyling['buttonColor']?.replaceFirst('#', '0xFF') ?? '0xFF${baseTheme.primaryColor.value.toRadixString(16).padLeft(8, '0')}')),
          ),
          foregroundColor: WidgetStateProperty.all(
            Color(int.parse(formbricksStyling['buttonTextColor']?.replaceFirst('#', '0xFF') ?? '0xFFFFFFFF')),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestion(Question question) {
    switch (question.type) {
      case 'freeText':
        return FreeTextQuestion(question: question, onResponse: _onResponse);
      case 'singleSelect':
        return SingleSelectQuestion(question: question, onResponse: _onResponse);
      case 'multiSelect':
        return MultiSelectQuestion(question: question, onResponse: _onResponse);
      case 'pictureSelection':
        return PictureSelectionQuestion(question: question, onResponse: _onResponse);
      case 'rating':
        return RatingQuestion(question: question, onResponse: _onResponse);
      case 'nps':
        return NPSQuestion(question: question, onResponse: _onResponse);
      case 'ranking':
        return RankingQuestion(question: question, onResponse: _onResponse);
      case 'matrix':
        return MatrixQuestion(question: question, onResponse: _onResponse);
      case 'statement':
        return StatementQuestion(question: question, onResponse: _onResponse);
      case 'consent':
        return ConsentQuestion(question: question, onResponse: _onResponse);
      case 'fileUpload':
        return FileUploadQuestion(
          question: question,
          onResponse: _onResponse,
          client: widget.client,
          surveyId: widget.surveyId,
          userId: widget.userId,
        );
      case 'date':
        return DateQuestion(question: question, onResponse: _onResponse);
      case 'scheduleMeeting':
        return ScheduleMeetingQuestion(question: question, onResponse: _onResponse);
      case 'address':
        return AddressQuestion(question: question, onResponse: _onResponse);
      case 'contactInfo':
        return ContactInfoQuestion(question: question, onResponse: _onResponse);
      default:
        return const Text('Unsupported question type');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null) {
      return Center(child: Text('Error: $error'));
    }
    if (survey == null) {
      return const Center(child: Text('No survey data'));
    }

    final question = survey!.questions[currentQuestionIndex];
    final progress = (currentQuestionIndex + 1) / survey!.questions.length;

    return Theme(
      data: _buildTheme(context),
      child: Scaffold(
        appBar: AppBar(
          title: Text(survey!.name),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4.0),
            child: LinearProgressIndicator(value: progress),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildQuestion(question),
              if (error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (currentQuestionIndex > 0)
                    ElevatedButton(
                      onPressed: _previousQuestion,
                      child: const Text('Previous'),
                    ),
                  ElevatedButton(
                    onPressed: question.required && responses[question.id] == null
                        ? null
                        : _nextQuestion,
                    child: Text(currentQuestionIndex == survey!.questions.length - 1
                        ? 'Submit'
                        : 'Next'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}