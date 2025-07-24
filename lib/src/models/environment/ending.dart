import 'package:json_annotation/json_annotation.dart';

part 'ending.g.dart';
/// Defines the response model for survey submissions.
@JsonSerializable()
class Ending {
  final String id;
  final String type;
  final Map<String, String> headline;
  final Map<String, String>? subheader;
  final String? imageUrl;
  final String? videoUrl;

  Ending({
    required this.id,
    required this.type,
    required this.headline,
    this.imageUrl,
    this.videoUrl,
    this.subheader
  });

  // factory Ending.fromJson(Map<String, dynamic> json) {
  //   return Ending(
  //     id: json['id'],
  //     type: json['type'],
  //     headline: Map<String, String>.from(json['headline'] ?? {'default': ''}),
  //     subheader: json['subheader'] != null ? Map<String, String>.from(
  //         json['subheader']) : null,
  //     imageUrl: json['imageUrl'],
  //     videoUrl: json['videoUrl'],
  //   );
  // }

  factory Ending.fromJson(Map<String, dynamic> json) => _$EndingFromJson(json);
  Map<String, dynamic> toJson() => _$EndingToJson(this);
}