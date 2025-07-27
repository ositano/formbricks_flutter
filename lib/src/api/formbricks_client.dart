import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';

import '../models/environment/environment_data_holder.dart';
import '../models/upload/fetch_storage_url_request_body.dart';
import '../models/upload/fetch_storage_url_response.dart';
import '../models/user/user_response_data.dart';
import '_base_request.dart';

/// A singleton client for interacting with the Formbricks API.
class FormbricksClient {
  final String appUrl;
  final String environmentId;
  final String apiKey;
  final bool isDev;
  final bool useV2;

  String? _userId;
  Map<String, dynamic>? _userAttributes;

  static FormbricksClient? _instance;

  /// Internal constructor for singleton pattern.
  FormbricksClient._internal({
    required this.appUrl,
    required this.environmentId,
    required this.apiKey,
    this.isDev = true,
    this.useV2 = false,
  });

  /// Factory constructor for ensuring only one instance is created.
  factory FormbricksClient({
    required String appUrl,
    required String environmentId,
    required String apiKey,
    bool isDev = true,
    bool useV2 = false,
  }) {
    _instance ??= FormbricksClient._internal(
      appUrl: appUrl,
      environmentId: environmentId,
      apiKey: apiKey,
      isDev: isDev,
      useV2: useV2,
    );
    return _instance!;
  }

  /// Returns the current instance, or throws if not initialized.
  static FormbricksClient get instance {
    if (_instance == null) {
      throw Exception("FormbricksClient has not been initialized.");
    }
    return _instance!;
  }

  /// Builds the base API URL depending on the environment (dev or prod).
  String get baseUrl => isDev ? '$appUrl/dev' : appUrl;

  /// Selects the API version (v1 or v2).
  String get version => useV2 ? 'v2' : 'v1';

  /// Registers or updates a user on Formbricks with optional custom attributes.
  Future<UserResponseData?> createUser(String userId, {Map<String, dynamic>? attributes}) async {
    _userId = userId;
    _userAttributes = attributes ?? {};

    final url = Uri.parse('$baseUrl/api/$version/client/$environmentId/user');

    final response = await baseRequest.post(
      url,
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'userId': _userId , 'attributes': _userAttributes}),
    );

    if (response.statusCode >= 200 && response.statusCode < 300){
      return UserResponseData.fromJson(jsonDecode(response.body)['data']);
    }
    throw Exception('Failed to create user: ${response.toString()}');
  }

  /// Fetches environment configuration and metadata from the API.
  Future<EnvironmentDataHolder?> getEnvironmentData() async {
    final url = Uri.parse('$baseUrl/api/$version/client/$environmentId/environment');
    final response = await baseRequest.get(
      url,
      headers: {'x-api-key': apiKey},
    );

    if (response.statusCode >= 200 && response.statusCode < 300){
      var originalResponseJson = jsonDecode(response.body);
      return EnvironmentDataHolder.fromJson({
        "data": originalResponseJson['data'],
        "originalResponseMap": originalResponseJson
      });
    }
    throw Exception('Failed to fetch environment data: ${response.statusCode} - ${response.body}');
  }

  /// Creates a new survey display session for tracking visibility and interaction.
  Future<String> createDisplay({
    required String surveyId,
    required String userId,
    String? responseId,
  }) async {
    final url = Uri.parse('$baseUrl/api/$version/client/$environmentId/displays');
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

  /// Submits the user's survey responses to Formbricks.
  Future<void> submitResponse({
    required String surveyId,
    required String userId,
    required Map<String, dynamic> data,
    bool finished = true,
  }) async {
    final url = Uri.parse('$baseUrl/api/$version/client/$environmentId/responses');
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

  Future<void> reSubmitResponse({
    required Map<String, dynamic> body,
    required Function() onComplete
  }) async {
    final url = Uri.parse('$baseUrl/api/$version/client/$environmentId/responses');
    final response = await baseRequest.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': apiKey,
      },
      body: jsonEncode(body),
    );

    if (!(response.statusCode >= 200 && response.statusCode < 300)) {
      throw Exception('Failed to resubmit response: ${response.statusCode} - ${response.body}');
    }
    onComplete.call();
  }

  /// Uploads a file to Formbricks storage system. Handles both S3 and fallback (local) uploads.
  Future<String> uploadFile(FetchStorageUrlRequestBody requestBody) async {
    if (requestBody.fileName.isEmpty || requestBody.fileType.isEmpty || requestBody.filePath.isEmpty) {
      throw Exception('Invalid file upload parameters.');
    }

    // Request upload metadata from Formbricks
    final metadataUrl = Uri.parse('$baseUrl/api/$version/client/$environmentId/storage');
    final metadataResponse = await baseRequest.post(
      metadataUrl,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody.toJson()),
    );

    if (!(metadataResponse.statusCode >= 200 && metadataResponse.statusCode < 300)) {
      throw Exception("Failed to get upload metadata: ${metadataResponse.statusCode}");
    }

    final metadata = FetchStorageUrlResponse.fromJson(jsonDecode(metadataResponse.body));
    final storageInfo = metadata.data;

    // S3 Presigned Upload
    if (storageInfo.presignedFields != null) {
      final request = MultipartRequest('POST', Uri.parse(storageInfo.signedUrl));
      storageInfo.presignedFields!.forEach((key, value) => request.fields[key] = value);

      final fileBytes = await File(requestBody.filePath).readAsBytes();
      final media = requestBody.fileType.split('/');
      request.files.add(MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: storageInfo.updatedFileName,
        contentType: MediaType(media[0], media[1]),
      ));

      final response = await baseRequest.multipart(request);

      if (!(response.statusCode >= 200 && response.statusCode < 300)) {
        final error = response.body;
        if (error.contains("EntityTooLarge")) {
          throw Exception("File size exceeds the limit for your plan.");
        }
        throw Exception("Upload failed: $error");
      }
    }
    // Local upload fallback (base64)
    else {
      final fileBase64 = base64Encode(await File(requestBody.filePath).readAsBytes());
      final localUploadPayload = {
        "fileBase64String": fileBase64,
        "fileType": requestBody.fileType,
        if(storageInfo.updatedFileName != null)
        "fileName": Uri.encodeComponent(storageInfo.updatedFileName!),
        "surveyId": requestBody.surveyId,
        if (storageInfo.signingData != null) ...{
          ...storageInfo.signingData!.toJson()
        }
      };

      final localUploadResponse = await baseRequest.post(
        Uri.parse(storageInfo.signedUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(localUploadPayload),
      );

      if (!(localUploadResponse.statusCode >= 200 && localUploadResponse.statusCode < 300)) {
        final message = jsonDecode(localUploadResponse.body)['message'] ?? 'Unknown error';
        throw Exception("Local upload failed: $message");
      }
    }
    return storageInfo.fileUrl;
  }
}
