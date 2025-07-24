import 'package:json_annotation/json_annotation.dart';

import 'segment_filter_resource.dart';

part 'segment.g.dart';


/// Segment model
@JsonSerializable()
class Segment {
  final String id;
  final String title;
  final String? description;

  @JsonKey(name: 'isPrivate')
  final bool isPrivate;

  final List<SegmentFilter> filters;
  final String environmentId;
  final String createdAt;
  final String updatedAt;
  final List<String> surveys;

  Segment({
    required this.id,
    required this.title,
    this.description,
    required this.isPrivate,
    required this.filters,
    required this.environmentId,
    required this.createdAt,
    required this.updatedAt,
    required this.surveys,
  });

  factory Segment.fromJson(Map<String, dynamic> json) =>
      _$SegmentFromJson(json);
  Map<String, dynamic> toJson() => _$SegmentToJson(this);
}