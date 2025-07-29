import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formbricks_flutter/formbricks_flutter.dart';
import 'package:formbricks_flutter/src/models/environment/environment_data_holder.dart';
import 'package:formbricks_flutter/src/survey/in_app/question_types/matrix_question.dart';

void main() {
  late String jsonString;
  late EnvironmentDataHolder environmentDataHolder;
  Survey? survey;
  Question? question;
  setUp(() async {
    jsonString = await File('test/data/sample_environment_response.json').readAsString();
    final response = jsonDecode(jsonString);
    environmentDataHolder = EnvironmentDataHolder.fromJson({
      "data": response['data'],
      "originalResponseMap": response
    });
    survey = environmentDataHolder.data?.data.surveys?.first;
    question = survey?.questions.firstWhere((question) => question.type == QuestionType.matrix);
  });

  testWidgets('Presence of row texts', (
      WidgetTester tester,
      ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: const [Locale('en')],
        home: Scaffold(
          body: MatrixQuestion(
            question: question!,
            onResponse: (questionId, response){},
            response: null,
            requiredAnswerByLogicCondition: false,
          ),
        ),
      ),
    );
    expect(find.text('Customer Support'), findsOneWidget);
    expect(find.text('Product Quality '), findsOneWidget);
    expect(find.text('Value for Money'), findsOneWidget);
  });

  testWidgets('Presence of column texts', (
      WidgetTester tester,
      ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: const [Locale('en')],
        home: Scaffold(
          body: MatrixQuestion(
            question: question!,
            onResponse: (questionId, response){},
            response: null,
            requiredAnswerByLogicCondition: false,
          ),
        ),
      ),
    );
    expect(find.text('Excellent '), findsOneWidget);
    expect(find.text('Good'), findsOneWidget);
    expect(find.text('Fair'), findsOneWidget);
  });

}
