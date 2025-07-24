// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ending.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Ending _$EndingFromJson(Map<String, dynamic> json) => Ending(
  id: json['id'] as String,
  type: json['type'] as String,
  headline: Map<String, String>.from(json['headline'] as Map),
  imageUrl: json['imageUrl'] as String?,
  videoUrl: json['videoUrl'] as String?,
  subheader: (json['subheader'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as String),
  ),
);

Map<String, dynamic> _$EndingToJson(Ending instance) => <String, dynamic>{
  'id': instance.id,
  'type': instance.type,
  'headline': instance.headline,
  'subheader': instance.subheader,
  'imageUrl': instance.imageUrl,
  'videoUrl': instance.videoUrl,
};
