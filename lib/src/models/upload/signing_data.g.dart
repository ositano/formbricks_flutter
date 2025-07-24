// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'signing_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SigningData _$SigningDataFromJson(Map<String, dynamic> json) => SigningData(
  signature: json['signature'] as String,
  timestamp: (json['timestamp'] as num).toInt(),
  uuid: json['uuid'] as String,
);

Map<String, dynamic> _$SigningDataToJson(SigningData instance) =>
    <String, dynamic>{
      'signature': instance.signature,
      'timestamp': instance.timestamp,
      'uuid': instance.uuid,
    };
