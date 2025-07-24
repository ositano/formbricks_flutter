
import 'package:json_annotation/json_annotation.dart';
part 'logic.g.dart';
@JsonSerializable()
class Logic {
  final String id;
  final List<LogicAction> actions;
  final Condition? conditions;

  Logic({required this.id, required this.actions, this.conditions});

  // factory Logic.fromJson(Map<String, dynamic> json) {
  //   return Logic(
  //     id: json['id'],
  //     actions: (json['actions'] as List)
  //         .map((a) => LogicAction.fromJson(a))
  //         .toList(),
  //     conditions: json['conditions'] != null
  //         ? Condition.fromJson(json['conditions'])
  //         : null,
  //   );
  // }
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

  // factory LogicAction.fromJson(Map<String, dynamic> json) {
  //   return LogicAction(
  //     id: json['id'],
  //     objective: json['objective'],
  //     target: json['target'],
  //     value: json['value'],
  //     operator: json['operator'],
  //     variableId: json['variableId'],
  //   );
  // }

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

  // factory Condition.fromJson(Map<String, dynamic> json) {
  //   return Condition(
  //     id: json['id'],
  //     connector: json['connector'],
  //     conditions: (json['conditions'] as List)
  //         .map((c) => c.containsKey('operator')
  //         ? ConditionDetail.fromJson(c)
  //         : Condition.fromJson(c))
  //         .toList(),
  //   );
  // }

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

  // factory ConditionDetail.fromJson(Map<String, dynamic> json) {
  //   return ConditionDetail(
  //     id: json['id'],
  //     operator: json['operator'],
  //     leftOperand: Operand.fromJson(json['leftOperand']),
  //     rightOperand: json['rightOperand'] != null ? Operand.fromJson(json['rightOperand']) : null,
  //   );
  // }
  factory ConditionDetail.fromJson(Map<String, dynamic> json) => _$ConditionDetailFromJson(json);
  Map<String, dynamic> toJson() => _$ConditionDetailToJson(this);
}

@JsonSerializable()
class Operand {
  final String type;
  final dynamic value;

  Operand({required this.type, this.value});

  // factory Operand.fromJson(Map<String, dynamic> json) {
  //   return Operand(
  //     type: json['type'],
  //     value: json['value'],
  //   );
  // }
  factory Operand.fromJson(Map<String, dynamic> json) => _$OperandFromJson(json);
  Map<String, dynamic> toJson() => _$OperandToJson(this);
}