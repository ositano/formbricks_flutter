import 'question.dart';

/// Defines the survey model, including questions and styling.
class Survey {
  final String id;
  final String name;
  final String type;
  final List<Question> questions;
  final Map<String, dynamic>? styling;
  final Map<String, dynamic>? logic;
  final Map<String, dynamic>? triggers;

  Survey({
    required this.id,
    required this.name,
    required this.type,
    required this.questions,
    this.styling,
    this.logic,
    this.triggers,
  });

  factory Survey.fromJson(Map<String, dynamic> json) {
    return Survey(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      questions: (json['questions'] as List)
          .map((q) => Question.fromJson(q))
          .toList(),
      styling: json['styling'],
      logic: json['logic'],
      triggers: json['triggers'],
    );
  }
}