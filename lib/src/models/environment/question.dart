
import 'package:json_annotation/json_annotation.dart';

import 'logic.dart';
part 'question.g.dart';
/// Defines the survey question model.
@JsonSerializable()
class Question {
  final String id;
  final String type;
  final Map<String, String> headline;
  final Map<String, String>? html;
  final Map<String, String>? subheader;
  final bool? required;
  //final Map<String, dynamic>? inputConfig;
  final Map<String, String>? lowerLabel;
  final Map<String, String>? upperLabel;
  final Map<String, String>? buttonLabel;
  final Map<String, String>? backButtonLabel;
  final Map<String, String>? dismissButtonLabel;
  final Map<String, String>? label;
  final Map<String, String>? placeholder;
  final String? imageUrl;
  final String? videoUrl;
  final String? inputType;
  final bool? longAnswer;
  final Map<String, dynamic>? charLimit;
  final List<Map<String, dynamic>>? choices;
  final bool? allowMulti;
  final List<Map<String, String>>? rows;
  final List<Map<String, String>>? columns;
  final String? shuffleOption;
  final bool? allowMultipleFiles;
  final List<String>? allowedFileExtensions;
  final String? calHost;
  final String? calUserName;
  final Map<String, dynamic>? zip;
  final Map<String, dynamic>? city;
  final Map<String, dynamic>? state;
  final Map<String, dynamic>? country;
  final Map<String, dynamic>? addressLine1;
  final Map<String, dynamic>? addressLine2;
  final Map<String, dynamic>? email;
  final Map<String, dynamic>? phone;
  final Map<String, dynamic>? company;
  final Map<String, dynamic>? firstName;
  final Map<String, dynamic>? lastName;
  final int? maxSizeInMB;
  final String? format;
  final List<Logic>? logic;
  final String? logicFallback; // Target if logic conditions fail
  final String? buttonUrl;
  final int? range;
  final String? scale;

  Question({
    required this.id,
    required this.type,
    required this.headline,
    this.html,
    this.subheader,
    required this.required,
    //this.inputConfig,
    this.lowerLabel,
    this.upperLabel,
    this.buttonLabel,
    this.backButtonLabel,
    this.dismissButtonLabel,
    this.label,
    this.placeholder,
    this.imageUrl,
    this.videoUrl,
    this.inputType,
    this.longAnswer,
    this.charLimit,
    this.choices,
    this.allowMulti,
    this.rows,
    this.columns,
    this.shuffleOption,
    this.allowedFileExtensions,
    this.allowMultipleFiles,
    this.calHost,
    this.calUserName,
    this.zip,
    this.city,
    this.state,
    this.country,
    this.addressLine1,
    this.addressLine2,
    this.email,
    this.phone,
    this.company,
    this.firstName,
    this.lastName,
    this.maxSizeInMB,
    this.format,
    required this.logic,
    this.logicFallback,
    this.buttonUrl,
    this.range,
    this.scale
  });


  factory Question.fromJson(Map<String, dynamic> json) => _$QuestionFromJson(json);
  Map<String, dynamic> toJson() => _$QuestionToJson(this);
}