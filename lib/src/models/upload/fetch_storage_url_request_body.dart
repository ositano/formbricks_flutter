import 'package:json_annotation/json_annotation.dart';
part 'fetch_storage_url_request_body.g.dart';

@JsonSerializable()
class FetchStorageUrlRequestBody {
  final String fileName;
  final String fileType;
  final List<String>? allowedFileExtensions;
  final String surveyId;
  final String accessType;
  final String filePath;

  FetchStorageUrlRequestBody({
    required this.fileName,
    required this.fileType,
    this.allowedFileExtensions,
    required this.surveyId,
    required this.filePath,
    this.accessType = "public",
  });

  factory FetchStorageUrlRequestBody.fromJson(Map<String, dynamic> json) =>
      _$FetchStorageUrlRequestBodyFromJson(json);

  Map<String, dynamic> toJson() => _$FetchStorageUrlRequestBodyToJson(this);
}
