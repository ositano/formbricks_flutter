import 'package:json_annotation/json_annotation.dart';

part 'action_class.g.dart';

@JsonSerializable()
class ActionClass {
  final String? id;
  final String? type;
  final String? name;
  final String? key;

  ActionClass({
    this.id,
    this.type,
    this.name,
    this.key,
  });

  factory ActionClass.fromJson(Map<String, dynamic> json) => _$ActionClassFromJson(json);
  Map<String, dynamic> toJson() => _$ActionClassToJson(this);

  @override
  String toString(){
    return "{id: $id, type: $type, name: $name, key: $key}";
  }
}
