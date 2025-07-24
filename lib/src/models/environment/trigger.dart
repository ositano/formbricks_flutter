import 'package:json_annotation/json_annotation.dart';
import 'action_class_reference.dart';
part 'trigger.g.dart';

@JsonSerializable()
class Trigger {
  final ActionClassReference? actionClass;

  Trigger({this.actionClass});

  factory Trigger.fromJson(Map<String, dynamic> json) => _$TriggerFromJson(json);
  Map<String, dynamic> toJson() => _$TriggerToJson(this);

  @override
  String toString(){
    return "{actionClass: $actionClass}";
  }
}
