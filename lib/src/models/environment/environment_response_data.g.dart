// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'environment_response_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EnvironmentResponseData _$EnvironmentResponseDataFromJson(
  Map<String, dynamic> json,
) => EnvironmentResponseData(
  data: EnvironmentData.fromJson(json['data'] as Map<String, dynamic>),
  expiresAt: json['expiresAt'] as String?,
);

Map<String, dynamic> _$EnvironmentResponseDataToJson(
  EnvironmentResponseData instance,
) => <String, dynamic>{'data': instance.data, 'expiresAt': instance.expiresAt};
