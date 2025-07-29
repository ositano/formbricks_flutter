import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formbricks_flutter/formbricks_flutter.dart';
import 'package:formbricks_flutter/src/models/environment/environment_data_holder.dart';
import 'package:formbricks_flutter/src/survey/in_app/question_types/file_upload_question.dart';

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
    question = survey?.questions.firstWhere((question) => question.type == QuestionType.fileUpload);
  });

  testWidgets('Presence of File Upload Button', (
      WidgetTester tester,
      ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: const [Locale('en')],
        home: Scaffold(
          body: FileUploadQuestion(
            question: question!,
            onResponse: (questionId, response){},
            response: null,
            requiredAnswerByLogicCondition: false,
            client: FormbricksClient(appUrl: '', environmentId: '', apiKey: ''),
            surveyId: '',
          ),
        ),
      ),
    );
    expect(find.text('Click to upload files'), findsOneWidget);
    expect(find.byType(Icon), findsOneWidget);
    expect(find.byType(GestureDetector), findsOneWidget);
  });

}
