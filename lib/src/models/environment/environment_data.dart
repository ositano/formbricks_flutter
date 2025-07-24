import 'package:json_annotation/json_annotation.dart';

import 'survey.dart';
import 'action_class.dart';
import 'project.dart';

part 'environment_data.g.dart';

@JsonSerializable()
class EnvironmentData {
  final List<Survey>? surveys;
  final List<ActionClass>? actionClasses;
  final Project project;

  EnvironmentData({this.surveys, this.actionClasses, required this.project});

  factory EnvironmentData.fromJson(Map<String, dynamic> json) => _$EnvironmentDataFromJson(json);
  Map<String, dynamic> toJson() => _$EnvironmentDataToJson(this);
}