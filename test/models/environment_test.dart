import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:formbricks_flutter/src/models/environment/environment_data_holder.dart';

void main() {
  late String jsonString;
  late EnvironmentDataHolder environmentDataHolder;

  setUp(() async {
    jsonString = await File('test/data/sample_environment_response.json').readAsString();
    final response = jsonDecode(jsonString);
    environmentDataHolder = EnvironmentDataHolder.fromJson({
      "data": response['data'],
      "originalResponseMap": response
    });
  });

  test('should parse EnvironmentDataHolder correctly', () async {
    expect(environmentDataHolder.data?.data.project.clickOutsideClose, true);
    expect(environmentDataHolder.data?.expiresAt, '2025-07-25T19:51:33.455Z');
  });

  test('should parse Survey correctly', () async {
    final survey = environmentDataHolder.data?.data.surveys?.first;
    expect(survey?.name, 'Start from scratch');
  });

}
