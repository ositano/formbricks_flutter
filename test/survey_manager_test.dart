import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formbricks_flutter/formbricks_flutter.dart';
import 'package:formbricks_flutter/src/models/question.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'survey_manager_test.mocks.dart';

// Mock classes
@GenerateMocks([FormbricksClient, SharedPreferences])
void main() {
  late MockFormbricksClient mockClient;
  late MockSharedPreferences mockPrefs;
  late SurveyManager surveyManager;
  late BuildContext context;

  // Sample survey data
  final surveyJson = {
    'id': 'survey1',
    'environmentId': 'env1',
    'status': 'inProgress',
    'runOnDate': '2023-01-01T00:00:00Z',
    'closeOnDate': '2025-12-31T23:59:59Z',
    'displayOption': 'displayOnce',
    'triggers': [
      {
        'actionClass': {
          'type': 'code',
          'name': 'event1',
          'key': 'key1',
        }
      }
    ],
    'questions': [
      {
        'id': 'q1',
        'type': 'nps',
        'required': true,
      }
    ],
    'segment': {
      'filters': [
        {
          'resource': {
            'root': {'type': 'attribute', 'contactAttributeKey': 'age'},
            'value': '30',
            'qualifier': {'operator': 'equals'},
          }
        }
      ]
    }
  };

  setUp(() async {
    // Initialize mocks
    mockClient = MockFormbricksClient();
    mockPrefs = MockSharedPreferences();
    context = _MockBuildContext();

    // Mock SharedPreferences behavior
    when(mockPrefs.getString(any)).thenReturn('{}');
    when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);

    // Mock FormbricksClient behavior
    when(mockClient.environmentId).thenReturn('env1');
    when(mockClient.getSurveys()).thenAnswer((_) async => [surveyJson]);

    // Initialize SurveyManager
    surveyManager = SurveyManager(
      client: mockClient,
      userId: 'user1',
      userAttributes: {'age': '30'},
      triggers: [
        TriggerValue(type: TriggerType.code, name: 'event1', key: 'key1'),
      ],
      locale: 'en',
      context: context,
      surveyDisplayMode: SurveyDisplayMode.fullScreen,
      showPoweredBy: false,
    );
  });

  tearDown(() {
    surveyManager.dispose();
  });

  group('SurveyManager', () {
    test('initializes correctly and loads completed surveys', () async {
      await surveyManager.initialize();

      expect(surveyManager.completedSurveys, {});
      verify(mockPrefs.getString('completed_surveys_user1')).called(1);
      expect(surveyManager._isInitialized, true);
    });

    test('adds and handles event correctly', () async {
      surveyManager.addEvent('event1');
      await surveyManager.initialize();

      expect(surveyManager.eventCounts['event1'], 1);
      verify(mockClient.getSurveys()).called(1);
    });

    test('triggers survey when conditions match', () async {
      // Mock navigation
      final navigator = _MockNavigator();
      when(navigator.push(any)).thenAnswer((_) async => null);

      await surveyManager.initialize();
      surveyManager.addEvent('event1');

      verify(mockClient.getSurveys()).called(1);
      expect(surveyManager.completedSurveys['survey1'], true);
      verify(mockPrefs.setString('completed_surveys_user1', any)).called(1);
    });

    test('skips survey when completed and displayOption is displayOnce', () async {
      surveyManager.completedSurveys['survey1'] = true;
      await surveyManager.initialize();
      surveyManager.addEvent('event1');

      expect(surveyManager._displayQueue, isEmpty);
      verify(mockClient.getSurveys()).called(1);
    });

    test('matches segment filters correctly', () async {
      final result = surveyManager._matchesSegment(Survey.fromJson(surveyJson));
      expect(result, true);
    });

    test('does not match segment filters when attribute does not match', () async {
      surveyManager = SurveyManager(
        client: mockClient,
        userId: 'user1',
        userAttributes: {'age': '20'}, // Different age
        triggers: [
          TriggerValue(type: TriggerType.code, name: 'event1', key: 'key1'),
        ],
        locale: 'en',
        context: context,
        surveyDisplayMode: SurveyDisplayMode.fullScreen,
        showPoweredBy: false,
      );

      final result = surveyManager._matchesSegment(Survey.fromJson(surveyJson));
      expect(result, false);
    });

    test('calculates estimated time correctly', () {
      final questions = [
        Question(id: 'q1', type: 'nps', required: true, headline: {}, logic: []),
        Question(id: 'q2', type: 'freeText', required: false, headline: {}, logic: []),
      ];
      final time = surveyManager.calculateEstimatedTime(questions);
      expect(time, 22); // 5 (nps) + 2 (required) + 5 (base) + 10 (freeText) + 5 (base)
    });

    test('updates locale correctly', () {
      surveyManager.setLocale('fr');
      expect(surveyManager.currentLocale, 'fr');
    });

    test('updates userId correctly', () {
      surveyManager.setUserId('user2');
      expect(surveyManager.userId, 'user2');
    });

    test('checks date range correctly', () {
      final survey = Survey.fromJson(surveyJson);
      final result = surveyManager._isWithinDateRange(survey);
      expect(result, true);
    });

    test('skips survey when outside date range', () {
      final outOfRangeSurvey = {
        ...surveyJson,
        'runOnDate': '2026-01-01T00:00:00Z',
      };
      final survey = Survey.fromJson(outOfRangeSurvey);
      final result = surveyManager._isWithinDateRange(survey);
      expect(result, false);
    });
  });
}

// Mock BuildContext for testing
class _MockBuildContext extends Mock implements BuildContext {}

// Mock Navigator for testing navigation
class _MockNavigator extends Mock implements NavigatorState {
  @override
  Future<T?> push<T extends Object?>(Route<T> route) {
    return Future.value(null);
  }
}