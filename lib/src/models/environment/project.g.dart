// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Project _$ProjectFromJson(Map<String, dynamic> json) => Project(
  id: json['id'] as String?,
  recontactDays: (json['recontactDays'] as num?)?.toDouble(),
  clickOutsideClose: json['clickOutsideClose'] as bool?,
  darkOverlay: json['darkOverlay'] as bool?,
  placement: json['placement'] as String?,
  inAppSurveyBranding: json['inAppSurveyBranding'] as bool?,
  styling: json['styling'] == null
      ? null
      : Styling.fromJson(json['styling'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ProjectToJson(Project instance) => <String, dynamic>{
  'id': instance.id,
  'recontactDays': instance.recontactDays,
  'clickOutsideClose': instance.clickOutsideClose,
  'darkOverlay': instance.darkOverlay,
  'placement': instance.placement,
  'inAppSurveyBranding': instance.inAppSurveyBranding,
  'styling': instance.styling,
};
