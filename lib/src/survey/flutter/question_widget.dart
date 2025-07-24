import 'package:flutter/material.dart';
import '../../../formbricks_flutter.dart';
import '../../models/environment/question.dart';
import '../../utils/helper.dart';
import 'question_types/address_question.dart';
import 'question_types/cal_question.dart';
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
      case 'openText':
        return freeTextQuestionBuilder?.call(ValueKey(question.id), question, onResponse, response, requiredAnswerByLogicCondition, formbricksClient: client, surveyId: surveyId) ?? FreeTextQuestion(
          key: ValueKey(question.id),
          question: question,
          onResponse: onResponse,
          response: response,
          requiredAnswerByLogicCondition: requiredAnswerByLogicCondition,
        );
      case 'multipleChoiceSingle':
        return multipleChoiceSingleQuestionBuilder?.call(ValueKey(question.id), question, onResponse, response, requiredAnswerByLogicCondition, formbricksClient: client, surveyId: surveyId) ?? MultipleChoiceSingleQuestion(key: ValueKey(question.id), question: question, onResponse: onResponse, response: response, requiredAnswerByLogicCondition: requiredAnswerByLogicCondition,);
      case 'multipleChoiceMulti':
        return multipleChoiceSingleQuestionBuilder?.call(ValueKey(question.id), question, onResponse, response, requiredAnswerByLogicCondition, formbricksClient: client, surveyId: surveyId) ?? MultipleChoiceMultiQuestion(key: ValueKey(question.id), question: question, onResponse: onResponse, response: response, requiredAnswerByLogicCondition: requiredAnswerByLogicCondition,);
      case 'pictureSelection':
        return pictureSelectionQuestionBuilder?.call(ValueKey(question.id), question, onResponse, response, requiredAnswerByLogicCondition, formbricksClient: client, surveyId: surveyId) ??  PictureSelectionQuestion(
            key: ValueKey(question.id),
          question: question,
          onResponse: onResponse, response: response, requiredAnswerByLogicCondition: requiredAnswerByLogicCondition
        );
      case 'rating':
        return ratingQuestionBuilder?.call(ValueKey(question.id), question, onResponse, response, requiredAnswerByLogicCondition, formbricksClient: client, surveyId: surveyId) ?? RatingQuestion(key: ValueKey(question.id), question: question, onResponse: onResponse, response: response, requiredAnswerByLogicCondition: requiredAnswerByLogicCondition,);
      case 'nps':
        return npsQuestionBuilder?.call(ValueKey(question.id), question, onResponse, response, requiredAnswerByLogicCondition, formbricksClient: client, surveyId: surveyId) ?? NPSQuestion(key: ValueKey(question.id), question: question, onResponse: onResponse, response: response, requiredAnswerByLogicCondition: requiredAnswerByLogicCondition,);
      case 'ranking':
        return rankingQuestionBuilder?.call(ValueKey(question.id), question, onResponse, response, requiredAnswerByLogicCondition, formbricksClient: client, surveyId: surveyId) ?? RankingQuestion(key: ValueKey(question.id), question: question, onResponse: onResponse, response: response, requiredAnswerByLogicCondition: requiredAnswerByLogicCondition,);
      case 'matrix':
        return matrixQuestionBuilder?.call(ValueKey(question.id), question, onResponse, response, requiredAnswerByLogicCondition, formbricksClient: client, surveyId: surveyId) ?? MatrixQuestion(key: ValueKey(question.id), question: question, onResponse: onResponse, response: response, requiredAnswerByLogicCondition: requiredAnswerByLogicCondition,);
      case 'consent':
        return consentQuestionBuilder?.call(ValueKey(question.id), question, onResponse, response, requiredAnswerByLogicCondition, formbricksClient: client, surveyId: surveyId) ?? ConsentQuestion(key: ValueKey(question.id), question: question, onResponse: onResponse, response: response, requiredAnswerByLogicCondition: requiredAnswerByLogicCondition,);
      case 'fileUpload':
        return fileUploadQuestionBuilder?.call(ValueKey(question.id), question, onResponse, response, requiredAnswerByLogicCondition, formbricksClient: client, surveyId: surveyId) ?? FileUploadQuestion(
            key: ValueKey(question.id),
          question: question,
          onResponse: onResponse,
          client: client,
          surveyId: surveyId,
          response: response,
          requiredAnswerByLogicCondition: requiredAnswerByLogicCondition,
        );
      case 'date':
        return dateQuestionBuilder?.call(ValueKey(question.id), question, onResponse, response, requiredAnswerByLogicCondition, formbricksClient: client, surveyId: surveyId) ?? DateQuestion(key: ValueKey(question.id), question: question, onResponse: onResponse, response: response, requiredAnswerByLogicCondition: requiredAnswerByLogicCondition,);
      case 'cal':
        return calQuestionBuilder?.call(ValueKey(question.id), question, onResponse, response, requiredAnswerByLogicCondition, formbricksClient: client, surveyId: surveyId) ?? CalQuestion(
          key: ValueKey(question.id),
          question: question,
          onResponse: onResponse,
          response: response,
          requiredAnswerByLogicCondition: requiredAnswerByLogicCondition,
        );
      case 'address':
        return addressQuestionBuilder?.call(ValueKey(question.id), question, onResponse, response, requiredAnswerByLogicCondition, formbricksClient: client, surveyId: surveyId) ?? AddressQuestion(key: ValueKey(question.id), question: question, onResponse: onResponse, response: response, requiredAnswerByLogicCondition: requiredAnswerByLogicCondition,);
      case 'contactInfo':
        return contactInfoQuestionBuilder?.call(ValueKey(question.id), question, onResponse, response, requiredAnswerByLogicCondition, formbricksClient: client, surveyId: surveyId) ?? ContactInfoQuestion(key: ValueKey(question.id), question: question, onResponse: onResponse, response: response, requiredAnswerByLogicCondition: requiredAnswerByLogicCondition,);
      case 'cta':
        return ctaQuestionBuilder?.call(ValueKey(question.id), question, onResponse, response, requiredAnswerByLogicCondition, formbricksClient: client, surveyId: surveyId) ?? CTAQuestion(key: ValueKey(question.id),question: question, onResponse: onResponse, response: response, requiredAnswerByLogicCondition: requiredAnswerByLogicCondition,);
      default:
        return Text(AppLocalizations.of(context)!.unsupported_question_type);
    }
  }
}
