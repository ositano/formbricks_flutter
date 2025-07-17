import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:formbricks_flutter/formbricks_flutter.dart';
import 'formbricks_test.mocks.dart';

// Mock classes
@GenerateMocks([SurveyManager])
void main() {
  late MockSurveyManager mockSurveyManager;
  late Formbricks formbricks;

  setUp(() {
    mockSurveyManager = MockSurveyManager();
    formbricks = Formbricks();
  });

  group('Formbricks Singleton', () {
    test('returns the same instance when called multiple times', () {
      final instance1 = Formbricks();
      final instance2 = Formbricks();
      expect(identical(instance1, instance2), true);
    });

    test('initializes with a SurveyManager instance', () {
      formbricks.init(mockSurveyManager);
      expect(formbricks, isNotNull);
      // Verify internal survey manager is set
      expect(() => formbricks.currentLocale, returnsNormally);
    });

    test('sets userId on SurveyManager', () {
      formbricks.init(mockSurveyManager);
      formbricks.setUserId('user123');

      verify(mockSurveyManager.setUserId('user123')).called(1);
    });

    test('sets user attributes on SurveyManager', () {
      formbricks.init(mockSurveyManager);
      final attributes = {'email': 'test@example.com', 'name': 'Test User'};
      formbricks.setUserAttribute(attributes);

      verify(mockSurveyManager.userAttributes.clear()).called(1);
      verify(mockSurveyManager.userAttributes.addAll(attributes)).called(1);
    });

    test('adds trigger values to SurveyManager', () {
      formbricks.init(mockSurveyManager);
      final triggers = [
        TriggerValue(type: TriggerType.code, name: 'event1', key: 'key1'),
        TriggerValue(type: TriggerType.noCode, name: 'event2', key: 'key2'),
      ];
      formbricks.addTriggerValues(triggers);

      verify(mockSurveyManager.triggers.addAll(triggers)).called(1);
    });

    test('sets locale on SurveyManager', () {
      formbricks.init(mockSurveyManager);
      formbricks.setLocale('fr');

      verify(mockSurveyManager.setLocale('fr')).called(1);
    });

    test('gets current locale from SurveyManager', () {
      formbricks.init(mockSurveyManager);
      when(mockSurveyManager.currentLocale).thenReturn('en');

      expect(formbricks.currentLocale, 'en');
      verify(mockSurveyManager.currentLocale).called(1);
    });

    test('throws when accessing currentLocale before initialization', () {
      expect(() => formbricks.currentLocale, throwsA(isA<NoSuchMethodError>()));
    });
  });
}