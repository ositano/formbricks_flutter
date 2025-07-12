import 'package:flutter/material.dart';
import '../../formbricks_flutter.dart';
import '../models/question.dart';
import '../utils/helper.dart';
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

class QuestionWidget extends StatelessWidget {
  final Question question;
  final Function(String, dynamic) onResponse;
  final FormbricksClient client;
  final String surveyId;
  final String userId;
  final dynamic response;
  final bool requiredAnswerByLogicCondition;

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

  const QuestionWidget({
    super.key,
    required this.question,
    required this.onResponse,
    required this.client,
    required this.surveyId,
    required this.userId,
    this.response,
    required this.requiredAnswerByLogicCondition,
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
    this.ratingQuestionBuilder
  });

  @override
  Widget build(BuildContext context) {
    switch (question.type) {
      case 'freeText':
        return freeTextQuestionBuilder?.call(ValueKey(question.id), question, onResponse, response, requiredAnswerByLogicCondition) ?? FreeTextQuestion(
          key: ValueKey(question.id),
          question: question,
          onResponse: onResponse,
          response: response,
          requiredAnswerByLogicCondition: requiredAnswerByLogicCondition,
        );
      case 'multipleChoiceSingle':
        return multipleChoiceSingleQuestionBuilder?.call(ValueKey(question.id), question, onResponse, response, requiredAnswerByLogicCondition) ?? MultipleChoiceSingle(key: ValueKey(question.id), question: question, onResponse: onResponse, response: response, requiredAnswerByLogicCondition: requiredAnswerByLogicCondition,);
      case 'multipleChoiceMulti':
        return multipleChoiceSingleQuestionBuilder?.call(ValueKey(question.id), question, onResponse, response, requiredAnswerByLogicCondition) ?? MultipleChoiceMulti(key: ValueKey(question.id), question: question, onResponse: onResponse, response: response, requiredAnswerByLogicCondition: requiredAnswerByLogicCondition,);
      case 'pictureSelection':
        return pictureSelectionQuestionBuilder?.call(ValueKey(question.id), question, onResponse, response, requiredAnswerByLogicCondition) ??  PictureSelectionQuestion(
            key: ValueKey(question.id),
          question: question,
          onResponse: onResponse, response: response, requiredAnswerByLogicCondition: requiredAnswerByLogicCondition,
        );
      case 'rating':
        return ratingQuestionBuilder?.call(ValueKey(question.id), question, onResponse, response, requiredAnswerByLogicCondition) ?? RatingQuestion(key: ValueKey(question.id), question: question, onResponse: onResponse, response: response, requiredAnswerByLogicCondition: requiredAnswerByLogicCondition,);
      case 'nps':
        return npsQuestionBuilder?.call(ValueKey(question.id), question, onResponse, response, requiredAnswerByLogicCondition) ?? NPSQuestion(key: ValueKey(question.id), question: question, onResponse: onResponse, response: response, requiredAnswerByLogicCondition: requiredAnswerByLogicCondition,);
      case 'ranking':
        return rankingQuestionBuilder?.call(ValueKey(question.id), question, onResponse, response, requiredAnswerByLogicCondition) ?? RankingQuestion(key: ValueKey(question.id), question: question, onResponse: onResponse, response: response, requiredAnswerByLogicCondition: requiredAnswerByLogicCondition,);
      case 'matrix':
        return matrixQuestionBuilder?.call(ValueKey(question.id), question, onResponse, response, requiredAnswerByLogicCondition) ?? MatrixQuestion(key: ValueKey(question.id), question: question, onResponse: onResponse, response: response, requiredAnswerByLogicCondition: requiredAnswerByLogicCondition,);
      case 'consent':
        return consentQuestionBuilder?.call(ValueKey(question.id), question, onResponse, response, requiredAnswerByLogicCondition) ?? ConsentQuestion(key: ValueKey(question.id), question: question, onResponse: onResponse, response: response, requiredAnswerByLogicCondition: requiredAnswerByLogicCondition,);
      case 'fileUpload':
        return FileUploadQuestion(
            key: ValueKey(question.id),
          question: question,
          onResponse: onResponse,
          client: client,
          surveyId: surveyId,
          userId: userId,
          response: response,
          requiredAnswerByLogicCondition: requiredAnswerByLogicCondition,
        );
      case 'date':
        return dateQuestionBuilder?.call(ValueKey(question.id), question, onResponse, response, requiredAnswerByLogicCondition) ?? DateQuestion(key: ValueKey(question.id), question: question, onResponse: onResponse, response: response, requiredAnswerByLogicCondition: requiredAnswerByLogicCondition,);
      case 'cal':
        return calQuestionBuilder?.call(ValueKey(question.id), question, onResponse, response, requiredAnswerByLogicCondition) ?? CalQuestion(
          key: ValueKey(question.id),
          question: question,
          onResponse: onResponse,
          response: response,
          requiredAnswerByLogicCondition: requiredAnswerByLogicCondition,
        );
      case 'address':
        return addressQuestionBuilder?.call(ValueKey(question.id), question, onResponse, response, requiredAnswerByLogicCondition) ?? AddressQuestion(key: ValueKey(question.id), question: question, onResponse: onResponse, response: response, requiredAnswerByLogicCondition: requiredAnswerByLogicCondition,);
      case 'contactInfo':
        return contactInfoQuestionBuilder?.call(ValueKey(question.id), question, onResponse, response, requiredAnswerByLogicCondition) ?? ContactInfoQuestion(key: ValueKey(question.id), question: question, onResponse: onResponse, response: response, requiredAnswerByLogicCondition: requiredAnswerByLogicCondition,);
      case 'cta':
        return ctaQuestionBuilder?.call(ValueKey(question.id), question, onResponse, response, requiredAnswerByLogicCondition) ?? CTAQuestion(key: ValueKey(question.id),question: question, onResponse: onResponse, response: response, requiredAnswerByLogicCondition: requiredAnswerByLogicCondition,);
      default:
        return Text(AppLocalizations.of(context)!.unsupported_question_type);
    }
  }
}
