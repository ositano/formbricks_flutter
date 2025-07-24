// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fetch_storage_url_request_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FetchStorageUrlRequestBody _$FetchStorageUrlRequestBodyFromJson(
  Map<String, dynamic> json,
) => FetchStorageUrlRequestBody(
  fileName: json['fileName'] as String,
  fileType: json['fileType'] as String,
  allowedFileExtensions: (json['allowedFileExtensions'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  surveyId: json['surveyId'] as String,
  accessType: json['accessType'] as String? ?? "public",
);

Map<String, dynamic> _$FetchStorageUrlRequestBodyToJson(
  FetchStorageUrlRequestBody instance,
) => <String, dynamic>{
  'fileName': instance.fileName,
  'fileType': instance.fileType,
  'allowedFileExtensions': instance.allowedFileExtensions,
  'surveyId': instance.surveyId,
  'accessType': instance.accessType,
};
