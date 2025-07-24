// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'storage_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StorageData _$StorageDataFromJson(Map<String, dynamic> json) => StorageData(
  signedUrl: json['signedUrl'] as String,
  signingData: SigningData.fromJson(
    json['signingData'] as Map<String, dynamic>,
  ),
  updatedFileName: json['updatedFileName'] as String,
  fileUrl: json['fileUrl'] as String,
);

Map<String, dynamic> _$StorageDataToJson(StorageData instance) =>
    <String, dynamic>{
      'signedUrl': instance.signedUrl,
      'signingData': instance.signingData,
      'updatedFileName': instance.updatedFileName,
      'fileUrl': instance.fileUrl,
    };
