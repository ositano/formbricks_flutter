import 'package:json_annotation/json_annotation.dart';
import 'environment_response_data.dart';
part 'environment_response.g.dart';

@JsonSerializable()
class EnvironmentResponse {
  final EnvironmentResponseData data;

  EnvironmentResponse({required this.data});

  factory EnvironmentResponse.fromJson(Map<String, dynamic> json) => _$EnvironmentResponseFromJson(json);
  Map<String, dynamic> toJson() => _$EnvironmentResponseToJson(this);
}