import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formbricks_flutter/formbricks_flutter.dart';
import 'package:formbricks_flutter/src/models/environment/environment_data_holder.dart';
import 'package:formbricks_flutter/src/survey/in_app/question_types/free_text_question.dart';

void main() {
  late String jsonString;
  late EnvironmentDataHolder environmentDataHolder;
  Survey? survey;
  Question? question;
  final formKey = GlobalKey<FormState>();

  setUp(() async {
    jsonString = await File(
      'test/data/sample_environment_response.json',
    ).readAsString();
    final response = jsonDecode(jsonString);
    environmentDataHolder = EnvironmentDataHolder.fromJson({
      "data": response['data'],
      "originalResponseMap": response,
    });
    survey = environmentDataHolder.data?.data.surveys?.first;
    question = survey?.questions.firstWhere(
      (question) => question.type == QuestionType.openText,
    );
  });

  testWidgets('Presence of File Upload Button', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: const [Locale('en')],
        home: Scaffold(
          body: Form(
            key: formKey,
            child: FreeTextQuestion(
              question: question!,
              onResponse: (questionId, response) {},
              response: null,
              requiredAnswerByLogicCondition: true,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Why is your score that low? '), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), 'Bad UX experience');
    await tester.pump();

    expect(find.text('Bad UX experience'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), '');
    await tester.pump();

    formKey.currentState!.validate();
    await tester.pump();

    // Verify the error message is displayed
    expect(find.text('Field is required'), findsOneWidget);
  });
}
