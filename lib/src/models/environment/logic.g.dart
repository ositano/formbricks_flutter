// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'logic.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Logic _$LogicFromJson(Map<String, dynamic> json) => Logic(
  id: json['id'] as String,
  actions: (json['actions'] as List<dynamic>)
      .map((e) => LogicAction.fromJson(e as Map<String, dynamic>))
      .toList(),
  conditions: json['conditions'] == null
      ? null
      : Condition.fromJson(json['conditions'] as Map<String, dynamic>),
);

Map<String, dynamic> _$LogicToJson(Logic instance) => <String, dynamic>{
  'id': instance.id,
  'actions': instance.actions,
  'conditions': instance.conditions,
};

LogicAction _$LogicActionFromJson(Map<String, dynamic> json) => LogicAction(
  id: json['id'] as String,
  objective: json['objective'] as String,
  target: json['target'] as String?,
  value: json['value'],
  operator: json['operator'] as String?,
  variableId: json['variableId'] as String?,
);

Map<String, dynamic> _$LogicActionToJson(LogicAction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'objective': instance.objective,
      'target': instance.target,
      'value': instance.value,
      'operator': instance.operator,
      'variableId': instance.variableId,
    };

Condition _$ConditionFromJson(Map<String, dynamic> json) => Condition(
  id: json['id'] as String,
  connector: json['connector'] as String,
  conditions: json['conditions'] as List<dynamic>,
);

Map<String, dynamic> _$ConditionToJson(Condition instance) => <String, dynamic>{
  'id': instance.id,
  'connector': instance.connector,
  'conditions': instance.conditions,
};

ConditionDetail _$ConditionDetailFromJson(Map<String, dynamic> json) =>
    ConditionDetail(
      id: json['id'] as String,
      operator: json['operator'] as String,
      leftOperand: Operand.fromJson(
        json['leftOperand'] as Map<String, dynamic>,
      ),
      rightOperand: json['rightOperand'] == null
          ? null
          : Operand.fromJson(json['rightOperand'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ConditionDetailToJson(ConditionDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'operator': instance.operator,
      'leftOperand': instance.leftOperand,
      'rightOperand': instance.rightOperand,
    };

Operand _$OperandFromJson(Map<String, dynamic> json) =>
    Operand(type: json['type'] as String, value: json['value']);

Map<String, dynamic> _$OperandToJson(Operand instance) => <String, dynamic>{
  'type': instance.type,
  'value': instance.value,
};
