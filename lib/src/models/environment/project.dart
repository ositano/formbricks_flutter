import 'package:json_annotation/json_annotation.dart';

import 'styling.dart';

part 'project.g.dart';
@JsonSerializable()
class Project {
  final String? id;
  final double? recontactDays;
  final bool? clickOutsideClose;
  final bool? darkOverlay;
  final String? placement;
  final bool? inAppSurveyBranding;
  final Styling? styling;

  Project({
    this.id,
    this.recontactDays,
    this.clickOutsideClose,
    this.darkOverlay,
    this.placement,
    this.inAppSurveyBranding,
    this.styling,
  });

  factory Project.fromJson(Map<String, dynamic> json) => _$ProjectFromJson(json);
  Map<String, dynamic> toJson() => _$ProjectToJson(this);
}