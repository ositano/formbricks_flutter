import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pretty_http_logger/pretty_http_logger.dart';

/// The core API client for interacting with Formbricks’ Public Client and Management APIs.
class FormBricksClient {
  final String apiHost;
  final String environmentId;
  final String apiKey;
  String? _userId;
  Map<String, dynamic>? _userAttributes;
  final bool isDev; // 'dev' or 'prod'

  FormBricksClient({
    required this.apiHost,
    required this.environmentId,
    required this.apiKey,
    this.isDev = true,
  });

  String get baseUrl => isDev ? '$apiHost/dev' : apiHost;

  static final HttpWithMiddleware _httpClient = HttpWithMiddleware.build(
    middlewares: [HttpLogger(logLevel: LogLevel.BODY)],
  );

  Future<void> setUser(String userId, {Map<String, dynamic>? attributes}) async {
    _userId = userId;
    _userAttributes = attributes ?? {};
    final url = Uri.parse('$baseUrl/api/v1/management/people/$_userId');
    final response = await _httpClient.put(
      url,
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'attributes': _userAttributes}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to set user: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getSurvey(String surveyId) async {
    final url = Uri.parse('$apiHost/api/v1/management/surveys/$surveyId');
    final response = await _httpClient.get(url, headers: {'x-api-key': apiKey});

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    } else {
      throw Exception(
        'Failed to fetch survey: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<List<Map<String, dynamic>>> getSurveys() async {
    final url = Uri.parse('$apiHost/api/v1/management/surveys');
    final response = await _httpClient.get(url, headers: {'x-api-key': apiKey});

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'] as List;
      // Filter surveys by trigger actionClass.name
      return data
          // .where((survey) {
          //   final triggers = survey['triggers'] as List? ?? [];
          //   return triggers.any(
          //     (trigger) =>
          //         trigger['actionClass'] != null &&
          //         trigger['actionClass']['name'] == event,
          //   );
          // })
          .cast<Map<String, dynamic>>()
          .toList();
    } else {
      throw Exception(
        'Failed to fetch surveys by trigger: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<String> createDisplay({
    required String surveyId,
    required String userId,
    String? responseId,
  }) async {
    final url = Uri.parse('$apiHost/api/v1/client/$environmentId/displays');
    final response = await _httpClient.post(
      url,
      headers: {'Content-Type': 'application/json', 'x-api-key': apiKey},
      body: jsonEncode({
        'surveyId': surveyId,
        'userId': userId,
        if (responseId != null) 'responseId': responseId,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data']['id'];
    } else {
      throw Exception(
        'Failed to create display: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<void> submitResponse({
    required String surveyId,
    required String userId,
    required Map<String, dynamic> data,
    bool finished = true,
  }) async {
    final url = Uri.parse('$apiHost/api/v1/client/$environmentId/responses');
    final response = await _httpClient.post(
      url,
      headers: {'Content-Type': 'application/json', 'x-api-key': apiKey},
      body: jsonEncode({
        'surveyId': surveyId,
        'userId': userId,
        'data': data,
        'finished': finished,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to submit response: ${response.statusCode} - ${response.body}',
      );
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
      throw Exception(
        'Failed to upload file: ${response.statusCode} - ${response.reasonPhrase}',
      );
    }
  }
}
