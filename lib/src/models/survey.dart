import 'question.dart';

/// Defines the survey model, including questions and styling.
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
  final List<Map<String, dynamic>>? endings;

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
    this.endings,
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
      endings: (json['endings'] as List?)?.cast<Map<String, dynamic>>(),
    );
  }
}