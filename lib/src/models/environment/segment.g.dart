// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'segment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Segment _$SegmentFromJson(Map<String, dynamic> json) => Segment(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String?,
  isPrivate: json['isPrivate'] as bool,
  filters: (json['filters'] as List<dynamic>)
      .map((e) => SegmentFilter.fromJson(e as Map<String, dynamic>))
      .toList(),
  environmentId: json['environmentId'] as String,
  createdAt: json['createdAt'] as String,
  updatedAt: json['updatedAt'] as String,
  surveys: (json['surveys'] as List<dynamic>).map((e) => e as String).toList(),
);

Map<String, dynamic> _$SegmentToJson(Segment instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'isPrivate': instance.isPrivate,
  'filters': instance.filters,
  'environmentId': instance.environmentId,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
  'surveys': instance.surveys,
};
