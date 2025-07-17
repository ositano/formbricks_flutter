import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '_base_request.dart';

/// A client for interacting with the Formbricks Public & Management API.
class FormbricksClient {
  final String apiHost;
  final String environmentId;
  final String apiKey;
  final bool isDev;

  String? _userId;
  Map<String, dynamic>? _userAttributes;

  FormbricksClient({
    required this.apiHost,
    required this.environmentId,
    required this.apiKey,
    this.isDev = true,
  });

  /// Returns the base API URL, using `/dev` if in development mode.
  String get baseUrl => isDev ? '$apiHost/dev' : apiHost;

  /// Registers or updates a user with optional attributes.
  Future<void> setUser(String userId, {Map<String, dynamic>? attributes}) async {
    _userId = userId;
    _userAttributes = attributes ?? {};

    final url = Uri.parse('$baseUrl/api/v1/management/people/$_userId');
    final response = await baseRequest.put(
      url,
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'attributes': _userAttributes}),
    );

    if (!(response.statusCode >= 200 && response.statusCode < 300)){
      throw Exception('Failed to set user: ${response.body}');
    }
  }

  /// Fetches all surveys available in the environment.
  Future<List<Map<String, dynamic>>> getSurveys() async {
    final url = Uri.parse('$apiHost/api/v1/management/surveys');
    final response = await baseRequest.get(
      url,
      headers: {'x-api-key': apiKey},
    );

    if (response.statusCode >= 200 && response.statusCode < 300){
      final data = jsonDecode(response.body)['data'] as List;
      return data.cast<Map<String, dynamic>>();
    }
    throw Exception('Failed to fetch surveys: ${response.statusCode} - ${response.body}');
  }

  /// Creates a display session for a survey.
  Future<String> createDisplay({
    required String surveyId,
    required String userId,
    String? responseId,
  }) async {
    final url = Uri.parse('$apiHost/api/v1/client/$environmentId/displays');
    final body = {
      'surveyId': surveyId,
      'userId': userId,
      if (responseId != null) 'responseId': responseId,
    };

    final response = await baseRequest.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': apiKey,
      },
      body: jsonEncode(body),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body)['data']['id'];
    }
    throw Exception('Failed to create display: ${response.statusCode} - ${response.body}');
  }

  /// Submits a survey response.
  Future<void> submitResponse({
    required String surveyId,
    required String userId,
    required Map<String, dynamic> data,
    bool finished = true,
  }) async {
    debugPrint("responses: $data");
    final url = Uri.parse('$apiHost/api/v1/client/$environmentId/responses');
    final body = {
      'surveyId': surveyId,
      'userId': userId,
      'data': data,
      'finished': finished,
    };

    final response = await baseRequest.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': apiKey,
      },
      body: jsonEncode(body),
    );

    if (!(response.statusCode >= 200 && response.statusCode < 300)) {
      throw Exception('Failed to submit response: ${response.statusCode} - ${response.body}');
    }
  }

  /// Uploads a file and returns its final URL.
  Future<String> uploadFile({
    required String name,
    required String mime,
    required String filePath,
    String? surveyId,
    List<String>? allowedFileExtensions,
  }) async {
    if (name.isEmpty || mime.isEmpty || filePath.isEmpty) {
      throw Exception('Invalid file upload parameters.');
    }

    // Step 1: Request signed upload metadata
    final metadataUrl = Uri.parse('$apiHost/api/v1/client/$environmentId/storage');
    final metadataPayload = {
      'fileName': name,
      'fileType': mime,
      if (surveyId != null) 'surveyId': surveyId,
      if (allowedFileExtensions != null) 'allowedFileExtensions': allowedFileExtensions,
    };

    final metadataResponse = await baseRequest.post(
      metadataUrl,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(metadataPayload),
    );

    if (!(metadataResponse.statusCode >= 200 && metadataResponse.statusCode < 300)) {
      throw Exception("Failed to get upload metadata: ${metadataResponse.statusCode}");
    }

    final metadata = jsonDecode(metadataResponse.body)['data'];
    final signedUrl = metadata['signedUrl'];
    final fileUrl = metadata['fileUrl'];
    final presignedFields = metadata['presignedFields'];
    final updatedFileName = metadata['updatedFileName'];
    final signingData = metadata['signingData'];

    // Step 2: Perform upload (multipart or base64)
    if (presignedFields != null) {
      // Multipart S3-style upload
      final request = MultipartRequest('POST', Uri.parse(signedUrl));
      presignedFields.forEach((key, value) {
        request.fields[key] = value;
      });

      final fileBytes = await File(filePath).readAsBytes();
      final media = mime.split('/');
      request.files.add(MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: updatedFileName,
        contentType: MediaType(media[0], media[1]),
      ));

      final response = await baseRequest.multipart(request);
      debugPrint("sent up till here .... ${response.statusCode}");
      if (!(response.statusCode >= 200 && response.statusCode < 300)) {
        final error = response.body;
        if (error.contains("EntityTooLarge")) {
          throw Exception("File size exceeds the limit for your plan.");
        }
        throw Exception("Upload failed: $error");
      }
    } else {
      // Local upload via base64 fallback
      final fileBase64 = base64Encode(await File(filePath).readAsBytes());
      final localUploadPayload = {
        "fileBase64String": fileBase64,
        "fileType": mime,
        "fileName": Uri.encodeComponent(updatedFileName),
        "surveyId": surveyId ?? "",
        if (signingData != null) ...{
          "signature": signingData["signature"],
          "timestamp": signingData["timestamp"].toString(),
          "uuid": signingData["uuid"],
        }
      };

      final localUploadResponse = await baseRequest.post(
        Uri.parse(signedUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(localUploadPayload),
      );

      if (!(localUploadResponse.statusCode >= 200 && localUploadResponse.statusCode < 300)) {
        final message = jsonDecode(localUploadResponse.body)['message'] ?? 'Unknown error';
        throw Exception("Local upload failed: $message");
      }
    }

    return fileUrl;
  }
}
