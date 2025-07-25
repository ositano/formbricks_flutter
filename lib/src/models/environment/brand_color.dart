import 'package:json_annotation/json_annotation.dart';

part 'brand_color.g.dart';
@JsonSerializable()
class BrandColor {
  final String? light;
  final String? dark;

  BrandColor({this.light, this.dark});

  factory BrandColor.fromJson(Map<String, dynamic> json) => _$BrandColorFromJson(json);
  Map<String, dynamic> toJson() => _$BrandColorToJson(this);
}