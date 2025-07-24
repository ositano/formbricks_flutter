import 'package:json_annotation/json_annotation.dart';

import 'ending.dart';
import 'question.dart';
import 'segment.dart';
import 'styling.dart';
import 'trigger.dart';

part 'survey.g.dart';

@JsonSerializable()
class Survey {
  final String id;
  final String name;
  final String type;
  final String status;
  final List<Question> questions;
  final List<Trigger>? triggers;
  final Map<String, dynamic>? welcomeCard;
  final List<Ending>? endings;
  final List<Map<String, dynamic>>? variables;
  final double? recontactDays;
  final double? displayLimit;
  final double? delay;
  final double? displayPercentage;
  final String? displayOption;
  final Segment? segment;
  final Styling? styling;
  final List<SurveyLanguage>? languages;
  final List<dynamic>? followUps;
  final bool? isBackButtonHidden;
  final String? runOnDate;
  final String? closeOnDate;
  final Map<String, dynamic>? hiddenFields;
  final int? autoClose;
  final Map<String, dynamic>? singleUse;
  final Map<String, dynamic>? projectOverwrites;

  Survey({
      required this.id,
    required this.name,
    this.triggers,
    this.recontactDays,
    this.displayLimit,
    this.delay,
    this.displayPercentage,
    this.displayOption,
    this.segment,
    this.styling,
    this.languages,
    required this.type,
    required this.status,
    required this.questions,
    this.welcomeCard,
    this.endings,
    this.variables,
    this.followUps,
    this.isBackButtonHidden,
    this.runOnDate,
    this.closeOnDate,
    this.hiddenFields,
    this.autoClose,
    this.singleUse,
    this.projectOverwrites
  });

  factory Survey.fromJson(Map<String, dynamic> json) => _$SurveyFromJson(json);
  Map<String, dynamic> toJson() => _$SurveyToJson(this);

  @override
  String toString(){
    return "{id: $id, name: $name}";
  }
}


@JsonSerializable()
class SurveyLanguage {
  final bool enabled;

  @JsonKey(name: 'default')
  final bool isDefault;

  final LanguageDetail language;

  SurveyLanguage({
    required this.enabled,
    required this.isDefault,
    required this.language,
  });

  factory SurveyLanguage.fromJson(Map<String, dynamic> json) => _$SurveyLanguageFromJson(json);
  Map<String, dynamic> toJson() => _$SurveyLanguageToJson(this);
}

@JsonSerializable()
class LanguageDetail {
  final String id;
  final String code;
  final String? alias;
  final String projectId;

  LanguageDetail({
    required this.id,
    required this.code,
    this.alias,
    required this.projectId,
  });

  factory LanguageDetail.fromJson(Map<String, dynamic> json) => _$LanguageDetailFromJson(json);
  Map<String, dynamic> toJson() => _$LanguageDetailToJson(this);
}

