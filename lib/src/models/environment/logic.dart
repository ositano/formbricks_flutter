
import 'package:json_annotation/json_annotation.dart';

import '../../../formbricks_flutter.dart';
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
  @JsonKey(name: 'objective')
  final LogicActionObjective objective;
  final String? target;
  final dynamic value; // For calculate actions

  @JsonKey(name: 'operator')
  final LogicActionOperator? operator; // For calculate actions
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
  @JsonKey(name: 'connector')
  final ConditionConnector connector;
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
  @JsonKey(name: 'operator')
  final ConditionOperator operator;
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
  @JsonKey(name: 'type')
  final OperandType type;
  final dynamic value;

  Operand({required this.type, this.value});
  factory Operand.fromJson(Map<String, dynamic> json) => _$OperandFromJson(json);
  Map<String, dynamic> toJson() => _$OperandToJson(this);
}