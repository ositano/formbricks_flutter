import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pretty_http_logger/pretty_http_logger.dart';

/// The core API client for interacting with Formbricks’ Public Client and Management APIs.
class FormbricksClient {
  final String apiHost;
  final String environmentId;
  final String apiKey;
  String? _userId;
  Map<String, dynamic>? _userAttributes;
  final bool isDev;

  /// Constructs a FormbricksClient with required configuration.
  /// [apiHost] - Base URL of the Formbricks API.
  /// [environmentId] - Identifier for the environment.
  /// [apiKey] - API key for authentication.
  /// [isDev] - Whether to use the /dev path in the base URL.
  FormbricksClient({
    required this.apiHost,
    required this.environmentId,
    required this.apiKey,
    this.isDev = true,
  });

  /// Computes the base URL, optionally prefixed with /dev for development mode.
  String get baseUrl => isDev ? '$apiHost/dev' : apiHost;

  /// HTTP client with middleware to pretty-print requests and responses.
  static final HttpWithMiddleware _httpClient = HttpWithMiddleware.build(
    middlewares: [HttpLogger(logLevel: LogLevel.BODY)],
  );

  /// Registers or updates the current user along with optional attributes.
  /// Sends a PUT request to Formbricks Management API to set user info.
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

    // Throw if request fails
    if (response.statusCode >= 200 && response.statusCode < 300) {
      throw Exception('Failed to set user: ${response.body}');
    }
  }

  /// Fetches a specific survey by its [surveyId] from the Management API.
  /// Returns the survey's data as a map.
  Future<Map<String, dynamic>> getSurvey(String surveyId) async {
    final url = Uri.parse('$apiHost/api/v1/management/surveys/$surveyId');
    final response = await _httpClient.get(
      url,
      headers: {'x-api-key': apiKey},
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body)['data'];
    } else {
      throw Exception('Failed to fetch survey: ${response.statusCode} - ${response.body}');
    }
  }

  /// Fetches all surveys available in the Management API.
  /// Returns a list of surveys.
  Future<List<Map<String, dynamic>>> getSurveys() async {
    final url = Uri.parse('$apiHost/api/v1/management/surveys');
    final response = await _httpClient.get(
      url,
      headers: {'x-api-key': apiKey},
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body)['data'] as List;
      return data.cast<Map<String, dynamic>>().toList();
    } else {
      throw Exception('Failed to fetch surveys: ${response.statusCode} - ${response.body}');
    }
  }

  /// Creates a survey display session on the client API.
  /// Returns the display ID as a string.
  Future<String> createDisplay({
    required String surveyId,
    required String userId,
    String? responseId,
  }) async {
    final url = Uri.parse('$apiHost/api/v1/client/$environmentId/displays');
    final response = await _httpClient.post(
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

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body)['data']['id'];
    } else {
      throw Exception('Failed to create display: ${response.statusCode} - ${response.body}');
    }
  }

  /// Submits user responses for a survey.
  /// [finished] indicates whether the survey is completed or still in progress.
  Future<void> submitResponse({
    required String surveyId,
    required String userId,
    required Map<String, dynamic> data,
    bool finished = true,
  }) async {
    final url = Uri.parse('$apiHost/api/v1/client/$environmentId/responses');
    final response = await _httpClient.post(
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

    if (response.statusCode >= 200 && response.statusCode < 300) {
      throw Exception('Failed to submit response: ${response.statusCode} - ${response.body}');
    }
  }

  /// Uploads a file to the Formbricks API and associates it with a survey and user.
  /// Returns the uploaded file's URL on success.
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

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final responseBody = await response.stream.bytesToString();
      return jsonDecode(responseBody)['data']['url'];
    } else {
      throw Exception('Failed to upload file: ${response.statusCode} - ${response.reasonPhrase}');
    }
  }
}
