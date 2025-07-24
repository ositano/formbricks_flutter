// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'environment_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EnvironmentData _$EnvironmentDataFromJson(Map<String, dynamic> json) =>
    EnvironmentData(
      surveys: (json['surveys'] as List<dynamic>?)
          ?.map((e) => Survey.fromJson(e as Map<String, dynamic>))
          .toList(),
      actionClasses: (json['actionClasses'] as List<dynamic>?)
          ?.map((e) => ActionClass.fromJson(e as Map<String, dynamic>))
          .toList(),
      project: Project.fromJson(json['project'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$EnvironmentDataToJson(EnvironmentData instance) =>
    <String, dynamic>{
      'surveys': instance.surveys,
      'actionClasses': instance.actionClasses,
      'project': instance.project,
    };
