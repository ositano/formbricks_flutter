import 'ending.dart';
import 'question.dart';

/// Defines the survey model, including questions, endings and styling.
class Survey {
  final String id;
  final String name;
  final String type;
  final String status;
  final String environmentId;
  final List<Question> questions;
  final Map<String, dynamic>? styling;
  final List<dynamic>? triggers;
  final String? displayOption;
  final double? displayPercentage;
  final Map<String, dynamic>? segment;
  final Map<String, dynamic>? welcomeCard;
  final List<Ending> endings;
  final List<Map<String, dynamic>>? variables;
  final List<dynamic>? followUps;
  final bool? isBackButtonHidden;
  final String? runOnDate;
  final String? closeOnDate;
  final Map<String, dynamic>? hiddenFields;
  final int? autoClose;
  final Map<String, dynamic>? singleUse;

  Survey({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    required this.environmentId,
    required this.questions,
    this.styling,
    this.triggers,
    this.displayOption,
    this.displayPercentage,
    this.segment,
    this.welcomeCard,
    required this.endings,
    this.variables,
    this.followUps,
    this.isBackButtonHidden,

    this.runOnDate,
    this.closeOnDate,
    this.hiddenFields,
    this.autoClose,
    this.singleUse,
  });

  factory Survey.fromJson(Map<String, dynamic> json) {
    return Survey(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      status: json['status'],
      environmentId: json['environmentId'],
      questions: (json['questions'] as List)
          .map((q) => Question.fromJson(q))
          .toList(),
      styling: json['styling'],
      triggers: json['triggers'],
      displayOption: json['displayOption'],
      displayPercentage: json['displayPercentage']?.toDouble(),
      segment: json['segment'],
      welcomeCard: json['welcomeCard'],
        endings: json['endings'] != null ? (json['endings'] as List)
            .map((q) => Ending.fromJson(q))
            .toList() : [],
      variables: (json['variables'] as List?)?.cast<Map<String, dynamic>>(),
      followUps: json['followUps'],
      isBackButtonHidden: json['isBackButtonHidden'],
      autoClose: json['autoClose'],
      closeOnDate: json['closeOnDate'],
      hiddenFields: json['hiddenFields'],
      runOnDate: json['runOnDate'],
      singleUse: json['singleUse'],
    );
  }
}