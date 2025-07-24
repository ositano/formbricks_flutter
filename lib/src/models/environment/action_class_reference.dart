import 'package:json_annotation/json_annotation.dart';

part 'action_class_reference.g.dart';

@JsonSerializable()
class ActionClassReference {
  final String? name;

  ActionClassReference({this.name});

  factory ActionClassReference.fromJson(Map<String, dynamic> json) => _$ActionClassReferenceFromJson(json);
  Map<String, dynamic> toJson() => _$ActionClassReferenceToJson(this);

  @override
  String toString(){
    return "{name: $name}";
  }
}