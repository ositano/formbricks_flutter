// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'survey.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Survey _$SurveyFromJson(Map<String, dynamic> json) => Survey(
  id: json['id'] as String,
  name: json['name'] as String,
  triggers: (json['triggers'] as List<dynamic>?)
      ?.map((e) => Trigger.fromJson(e as Map<String, dynamic>))
      .toList(),
  recontactDays: (json['recontactDays'] as num?)?.toDouble(),
  displayLimit: (json['displayLimit'] as num?)?.toDouble(),
  delay: (json['delay'] as num?)?.toDouble(),
  displayPercentage: (json['displayPercentage'] as num?)?.toDouble(),
  displayOption: json['displayOption'] as String?,
  segment: json['segment'] == null
      ? null
      : Segment.fromJson(json['segment'] as Map<String, dynamic>),
  styling: json['styling'] == null
      ? null
      : Styling.fromJson(json['styling'] as Map<String, dynamic>),
  languages: (json['languages'] as List<dynamic>?)
      ?.map((e) => SurveyLanguage.fromJson(e as Map<String, dynamic>))
      .toList(),
  type: json['type'] as String,
  status: json['status'] as String,
  questions: (json['questions'] as List<dynamic>)
      .map((e) => Question.fromJson(e as Map<String, dynamic>))
      .toList(),
  welcomeCard: json['welcomeCard'] as Map<String, dynamic>?,
  endings: (json['endings'] as List<dynamic>?)
      ?.map((e) => Ending.fromJson(e as Map<String, dynamic>))
      .toList(),
  variables: (json['variables'] as List<dynamic>?)
      ?.map((e) => e as Map<String, dynamic>)
      .toList(),
  followUps: json['followUps'] as List<dynamic>?,
  isBackButtonHidden: json['isBackButtonHidden'] as bool?,
  runOnDate: json['runOnDate'] as String?,
  closeOnDate: json['closeOnDate'] as String?,
  hiddenFields: json['hiddenFields'] as Map<String, dynamic>?,
  autoClose: (json['autoClose'] as num?)?.toInt(),
  singleUse: json['singleUse'] as Map<String, dynamic>?,
  projectOverwrites: json['projectOverwrites'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$SurveyToJson(Survey instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'type': instance.type,
  'status': instance.status,
  'questions': instance.questions,
  'triggers': instance.triggers,
  'welcomeCard': instance.welcomeCard,
  'endings': instance.endings,
  'variables': instance.variables,
  'recontactDays': instance.recontactDays,
  'displayLimit': instance.displayLimit,
  'delay': instance.delay,
  'displayPercentage': instance.displayPercentage,
  'displayOption': instance.displayOption,
  'segment': instance.segment,
  'styling': instance.styling,
  'languages': instance.languages,
  'followUps': instance.followUps,
  'isBackButtonHidden': instance.isBackButtonHidden,
  'runOnDate': instance.runOnDate,
  'closeOnDate': instance.closeOnDate,
  'hiddenFields': instance.hiddenFields,
  'autoClose': instance.autoClose,
  'singleUse': instance.singleUse,
  'projectOverwrites': instance.projectOverwrites,
};

SurveyLanguage _$SurveyLanguageFromJson(Map<String, dynamic> json) =>
    SurveyLanguage(
      enabled: json['enabled'] as bool,
      isDefault: json['default'] as bool,
      language: LanguageDetail.fromJson(
        json['language'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$SurveyLanguageToJson(SurveyLanguage instance) =>
    <String, dynamic>{
      'enabled': instance.enabled,
      'default': instance.isDefault,
      'language': instance.language,
    };

LanguageDetail _$LanguageDetailFromJson(Map<String, dynamic> json) =>
    LanguageDetail(
      id: json['id'] as String,
      code: json['code'] as String,
      alias: json['alias'] as String?,
      projectId: json['projectId'] as String,
    );

Map<String, dynamic> _$LanguageDetailToJson(LanguageDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'alias': instance.alias,
      'projectId': instance.projectId,
    };
