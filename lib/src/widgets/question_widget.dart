import 'package:flutter/material.dart';
import '../../formbricks_flutter.dart';
import '../models/question.dart';
import 'question/address_question.dart';
import 'question/consent_question.dart';
import 'question/contact_info_question.dart';
import 'question/cta_question.dart';
import 'question/date_question.dart';
import 'question/file_upload_question.dart';
import 'question/free_text_question.dart';
import 'question/matrix_question.dart';
import 'question/multiple_choice_multi.dart';
import 'question/multiple_choice_single.dart';
import 'question/nps_question.dart';
import 'question/picture_selection_question.dart';
import 'question/ranking_question.dart';
import 'question/rating_question.dart';
import 'question/cal_question.dart';
import 'question/statement_question.dart';

class QuestionWidget extends StatelessWidget {
  final Question question;
  final Function(String, dynamic) onResponse;
  final FormBricksClient client;
  final String surveyId;
  final String userId;
  final dynamic response;
  final GlobalKey<FormState> formKey;

  const QuestionWidget({
    super.key,
    required this.question,
    required this.onResponse,
    required this.client,
    required this.surveyId,
    required this.userId,
    this.response,
    required this.formKey
  });

  @override
  Widget build(BuildContext context) {
    switch (question.type) {
      case 'freeText':
      case 'openText': // Treat openText as freeText
        return FreeTextQuestion(
          key: ValueKey(question.id),
          question: question,
          onResponse: onResponse,
          response: response,
          //textController: textController,
        );
      case 'multipleChoiceSingle':
        return MultipleChoiceSingle(key: ValueKey(question.id), question: question, onResponse: onResponse, response: response);
      case 'multipleChoiceMulti':
        return MultipleChoiceMulti(key: ValueKey(question.id), question: question, onResponse: onResponse, response: response);
      case 'pictureSelection':
        return PictureSelectionQuestion(
            key: ValueKey(question.id),
          question: question,
          onResponse: onResponse, response: response
        );
      case 'rating':
        return RatingQuestion(key: ValueKey(question.id), question: question, onResponse: onResponse, response: response);
      case 'nps':
        return NPSQuestion(key: ValueKey(question.id), question: question, onResponse: onResponse, response: response);
      case 'ranking':
        return RankingQuestion(key: ValueKey(question.id), question: question, onResponse: onResponse, response: response);
      case 'matrix':
        return MatrixQuestion(key: ValueKey(question.id), question: question, onResponse: onResponse, response: response);
      case 'statement':
        return StatementQuestion(key: ValueKey(question.id), question: question, onResponse: onResponse);
      case 'consent':
        return ConsentQuestion(key: ValueKey(question.id), question: question, onResponse: onResponse, response: response);
      case 'fileUpload':
        return FileUploadQuestion(
            key: ValueKey(question.id),
          question: question,
          onResponse: onResponse,
          client: client,
          surveyId: surveyId,
          userId: userId,
            response: response
        );
      case 'date':
        return DateQuestion(key: ValueKey(question.id), question: question, onResponse: onResponse, response: response);
      case 'cal':
      case 'scheduleMeeting':
        return CalQuestion(
          key: ValueKey(question.id),
          question: question,
          onResponse: onResponse,
          response: response,
        );
      case 'address':
        return AddressQuestion(key: ValueKey(question.id), question: question, onResponse: onResponse, response: response);
      case 'contactInfo':
        return ContactInfoQuestion(key: ValueKey(question.id), question: question, onResponse: onResponse, response: response);
      case 'cta':
        return CTAQuestion(key: ValueKey(question.id),question: question, onResponse: onResponse, response: response);
      default:
        return Text(AppLocalizations.of(context)!.unsupported_question_type);
    }
  }
}
