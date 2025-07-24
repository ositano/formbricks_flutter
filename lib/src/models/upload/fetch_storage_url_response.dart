import 'package:json_annotation/json_annotation.dart';
import 'storage_data.dart';

part 'fetch_storage_url_response.g.dart';

@JsonSerializable()
class FetchStorageUrlResponse {
  final StorageData data;

  FetchStorageUrlResponse({required this.data});

  factory FetchStorageUrlResponse.fromJson(Map<String, dynamic> json) =>
      _$FetchStorageUrlResponseFromJson(json);

  Map<String, dynamic> toJson() => _$FetchStorageUrlResponseToJson(this);
}
