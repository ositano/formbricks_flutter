import 'dart:convert';
import 'package:http/http.dart' as http;

/// The core API client for interacting with Formbricks’ Public Client and Management APIs.
class FormbricksClient {
  final String apiHost;
  final String environmentId;
  final String apiKey;

  FormbricksClient({
    required this.apiHost,
    required this.environmentId,
    required this.apiKey,
  });

  Future<Map<String, dynamic>> getSurvey(String surveyId) async {
    final url = Uri.parse('$apiHost/api/v1/management/surveys/$surveyId');
    final response = await http.get(
      url,
      headers: {'x-api-key': apiKey},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    } else {
      throw Exception('Failed to fetch survey: ${response.body}');
    }
  }

  Future<List<Map<String, dynamic>>> getSurveysByTrigger(String event) async {
    final url = Uri.parse('$apiHost/api/v1/management/surveys?trigger=$event');
    final response = await http.get(
      url,
      headers: {'x-api-key': apiKey},
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body)['data']);
    } else {
      throw Exception('Failed to fetch surveys by trigger: ${response.body}');
    }
  }

  Future<String> createDisplay({
    required String surveyId,
    required String userId,
    String? responseId,
  }) async {
    final url = Uri.parse('$apiHost/api/v1/client/$environmentId/displays');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': apiKey,
      },
      body: jsonEncode({
        'surveyId': surveyId,
        'userId': userId,
        if (responseId != null) 'responseId': responseId,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data']['id'];
    } else {
      throw Exception('Failed to create display: ${response.body}');
    }
  }

  Future<void> submitResponse({
    required String surveyId,
    required String userId,
    required Map<String, dynamic> data,
    bool finished = true,
  }) async {
    final url = Uri.parse('$apiHost/api/v1/client/$environmentId/responses');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': apiKey,
      },
      body: jsonEncode({
        'surveyId': surveyId,
        'userId': userId,
        'data': data,
        'finished': finished,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to submit response: ${response.body}');
    }
  }

  Future<String?> uploadFile({
    required String surveyId,
    required String userId,
    required String filePath,
  }) async {
    final url = Uri.parse('$apiHost/api/v1/client/$environmentId/upload-file');
    final request = http.MultipartRequest('POST', url)
      ..headers['x-api-key'] = apiKey
      ..fields['surveyId'] = surveyId
      ..fields['userId'] = userId
      ..files.add(await http.MultipartFile.fromPath('file', filePath));

    final response = await request.send();
    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      return jsonDecode(responseBody)['data']['url'];
    } else {
      throw Exception('Failed to upload file: ${response.reasonPhrase}');
    }
  }
}