import 'package:json_annotation/json_annotation.dart';
part 'signing_data.g.dart';

@JsonSerializable()
class SigningData {
  final String signature;
  final int timestamp;
  final String uuid;

  SigningData({
    required this.signature,
    required this.timestamp,
    required this.uuid,
  });

  factory SigningData.fromJson(Map<String, dynamic> json) =>
      _$SigningDataFromJson(json);

  Map<String, dynamic> toJson() => _$SigningDataToJson(this);
}
