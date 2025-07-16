import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:pretty_http_logger/pretty_http_logger.dart';

/// Handles all HTTP requests with logging middleware.
class _BaseRequest {
  static final HttpWithMiddleware _httpClient = HttpWithMiddleware.build(
    middlewares: [
      if (kDebugMode) HttpLogger(logLevel: LogLevel.BODY),
    ],
  );

  static final HttpClientWithMiddleware _streamedHttpClient =
  HttpClientWithMiddleware.build(
    middlewares: [
      if (kDebugMode) HttpLogger(logLevel: LogLevel.BODY),
    ],
  );

  Future<Response> get(Uri url, {Map<String, String>? headers}) =>
      _httpClient.get(url, headers: headers);

  Future<Response> post(Uri url,
      {Map<String, String>? headers, Object? body}) =>
      _httpClient.post(url, headers: headers, body: body);

  Future<Response> put(Uri url,
      {Map<String, String>? headers, Object? body}) =>
      _httpClient.put(url, headers: headers, body: body);

  Future<Response> patch(Uri url,
      {Map<String, String>? headers, Object? body}) =>
      _httpClient.patch(url, headers: headers, body: body);

  Future<Response> delete(Uri url,
      {Map<String, String>? headers, Object? body}) =>
      _httpClient.delete(url, headers: headers, body: body);

  Future<StreamedResponse> send(BaseRequest request) =>
      _streamedHttpClient.send(request);

  Future<Response> multipart(MultipartRequest request) async {
    final streamed = await _streamedHttpClient.send(request);
    final body = await Response.fromStream(streamed);
    return body;
  }
}

/// Global singleton instance
final baseRequest = _BaseRequest();
