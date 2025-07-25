
import 'package:json_annotation/json_annotation.dart';
part 'logic.g.dart';
@JsonSerializable()
class Logic {
  final String id;
  final List<LogicAction> actions;
  final Condition? conditions;

  Logic({required this.id, required this.actions, this.conditions});
  factory Logic.fromJson(Map<String, dynamic> json) => _$LogicFromJson(json);
  Map<String, dynamic> toJson() => _$LogicToJson(this);
}

/// A task that is executed when a condition is met
@JsonSerializable()
class LogicAction {
  final String id;
  final String objective;
  final String? target;
  final dynamic value; // For calculate actions
  final String? operator; // For calculate actions
  final String? variableId; // For variable assignment

  LogicAction({
    required this.id,
    required this.objective,
    this.target,
    this.value,
    this.operator,
    this.variableId
  });
  factory LogicAction.fromJson(Map<String, dynamic> json) => _$LogicActionFromJson(json);
  Map<String, dynamic> toJson() => _$LogicActionToJson(this);
}

/// A rule that determines when an action should be executed.
@JsonSerializable()
class Condition {
  final String id;
  final String connector;
  final List<dynamic> conditions; // Can be ConditionDetail or nested Condition

  Condition({
    required this.id,
    required this.connector,
    required this.conditions,
  });
  factory Condition.fromJson(Map<String, dynamic> json) => _$ConditionFromJson(json);
  Map<String, dynamic> toJson() => _$ConditionToJson(this);
}

@JsonSerializable()
class ConditionDetail {
  final String id;
  final String operator;
  final Operand leftOperand;
  final Operand? rightOperand;

  ConditionDetail({
    required this.id,
    required this.operator,
    required this.leftOperand,
    this.rightOperand,
  });
  factory ConditionDetail.fromJson(Map<String, dynamic> json) => _$ConditionDetailFromJson(json);
  Map<String, dynamic> toJson() => _$ConditionDetailToJson(this);
}

@JsonSerializable()
class Operand {
  final String type;
  final dynamic value;

  Operand({required this.type, this.value});
  factory Operand.fromJson(Map<String, dynamic> json) => _$OperandFromJson(json);
  Map<String, dynamic> toJson() => _$OperandToJson(this);
}