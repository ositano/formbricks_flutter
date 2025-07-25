import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:formbricks_flutter/src/models/user/user_response_data.dart';

void main() {
  late String jsonString;
  late UserResponseData userResponseData;

  setUp(() async {
      jsonString = await File('test/data/sample_user_response.json').readAsString();
      final response = jsonDecode(jsonString);
      userResponseData = UserResponseData.fromJson(response['data']);
  });

  test('should parse UserState correctly', () async {
    expect(userResponseData.state.expiresAt, '2025-07-25T19:20:59.019Z');
  });

  test('should parse UserStateData correctly', () async {
    final userStateData = userResponseData.state.data;
    expect(userStateData.userId, 'gideonvision247');
    expect(userStateData.contactId, 'cmdj0t0il9fl5w101gg7epcvh');
    expect(userStateData.lastDisplayAt, '2025-07-25T16:23:12.006Z');
    expect(userStateData.segments, [
      "cmct8slow0yfmyl01nehyfebn",
      "cmdhoq1ty05yyu401t8nn7925"
    ]);
  });
}
