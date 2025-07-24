import 'package:json_annotation/json_annotation.dart';
import 'environment_data.dart';

part 'environment_response_data.g.dart';

@JsonSerializable()
class EnvironmentResponseData {
  final EnvironmentData data;
  final String? expiresAt;

  EnvironmentResponseData({required this.data, this.expiresAt});

  factory EnvironmentResponseData.fromJson(Map<String, dynamic> json) => _$EnvironmentResponseDataFromJson(json);
  Map<String, dynamic> toJson() => _$EnvironmentResponseDataToJson(this);
}