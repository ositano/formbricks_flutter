import 'package:flutter/material.dart';
import '../../formbricks_flutter.dart';
import '../models/question.dart';
import 'question_types/address_question.dart';
import 'question_types/consent_question.dart';
import 'question_types/contact_info_question.dart';
import 'question_types/cta_question.dart';
import 'question_types/date_question.dart';
import 'question_types/file_upload_question.dart';
import 'question_types/free_text_question.dart';
import 'question_types/matrix_question.dart';
import 'question_types/multiple_choice_multi.dart';
import 'question_types/multiple_choice_single.dart';
import 'question_types/nps_question.dart';
import 'question_types/picture_selection_question.dart';
import 'question_types/ranking_question.dart';
import 'question_types/rating_question.dart';
import 'question_types/schedule_meeting_question.dart';
import 'question_types/single_select_question.dart';
import 'question_types/statement_question.dart';

class QuestionWidget extends StatelessWidget {
  final Question question;
  final Function(String, dynamic) onResponse;
  final FormBricksClient client;
  final String surveyId;
  final String userId;
  final dynamic response;

  const QuestionWidget({
    super.key,
    required this.question,
    required this.onResponse,
    required this.client,
    required this.surveyId,
    required this.userId,
    this.response,
  });

  @override
  Widget build(BuildContext context) {
    switch (question.type) {
      case 'freeText':
      case 'openText': // Treat openText as freeText
        return FreeTextQuestion(
          question: question,
          onResponse: onResponse,
          response: response,
          //textController: textController,
        );
      case 'singleSelect':
        return SingleSelectQuestion(question: question, onResponse: onResponse, response: response);
      case 'multipleChoiceSingle':
        return MultipleChoiceSingle(question: question, onResponse: onResponse, response: response);
      case 'multipleChoiceMulti':
        return MultipleChoiceMulti(question: question, onResponse: onResponse, response: response);
      case 'pictureSelection':
        return PictureSelectionQuestion(
          question: question,
          onResponse: onResponse, response: response
        );
      case 'rating':
        return RatingQuestion(question: question, onResponse: onResponse, response: response);
      case 'nps':
        return NPSQuestion(question: question, onResponse: onResponse, response: response);
      case 'ranking':
        return RankingQuestion(question: question, onResponse: onResponse, response: response);
      case 'matrix':
        return MatrixQuestion(question: question, onResponse: onResponse, response: response);
      case 'statement':
        return StatementQuestion(question: question, onResponse: onResponse);
      case 'consent':
        return ConsentQuestion(question: question, onResponse: onResponse, response: response);
      case 'fileUpload':
        return FileUploadQuestion(
          question: question,
          onResponse: onResponse,
          client: client,
          surveyId: surveyId,
          userId: userId, response: response
        );
      case 'date':
        return DateQuestion(question: question, onResponse: onResponse, response: response);
      case 'scheduleMeeting':
        return ScheduleMeetingQuestion(
          question: question,
          onResponse: onResponse,
        );
      case 'address':
        return AddressQuestion(question: question, onResponse: onResponse, response: response);
      case 'contactInfo':
        return ContactInfoQuestion(question: question, onResponse: onResponse, response: response);
      case 'cta':
        return CTAQuestion(question: question, onResponse: onResponse, response: response);
      default:
        return const Text('Unsupported question type');
    }
  }
}
