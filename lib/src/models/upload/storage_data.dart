import 'package:json_annotation/json_annotation.dart';
import 'signing_data.dart';
part 'storage_data.g.dart';

@JsonSerializable()
class StorageData {
  final String signedUrl;
  final SigningData? signingData;
  final String? updatedFileName;
  final String fileUrl;
  final Map<String, dynamic>? presignedFields;

  StorageData({
    required this.signedUrl,
    required this.signingData,
    this.updatedFileName,
    required this.fileUrl,
    required this.presignedFields
  });

  factory StorageData.fromJson(Map<String, dynamic> json) =>
      _$StorageDataFromJson(json);

  Map<String, dynamic> toJson() => _$StorageDataToJson(this);
}
