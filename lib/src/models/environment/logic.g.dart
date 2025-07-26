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
  objective: $enumDecode(_$LogicActionObjectiveEnumMap, json['objective']),
  target: json['target'] as String?,
  value: json['value'],
  operator: $enumDecodeNullable(_$LogicActionOperatorEnumMap, json['operator']),
  variableId: json['variableId'] as String?,
);

Map<String, dynamic> _$LogicActionToJson(LogicAction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'objective': _$LogicActionObjectiveEnumMap[instance.objective]!,
      'target': instance.target,
      'value': instance.value,
      'operator': _$LogicActionOperatorEnumMap[instance.operator],
      'variableId': instance.variableId,
    };

const _$LogicActionObjectiveEnumMap = {
  LogicActionObjective.jumpToQuestion: 'jumpToQuestion',
  LogicActionObjective.requireAnswer: 'requireAnswer',
  LogicActionObjective.calculate: 'calculate',
};

const _$LogicActionOperatorEnumMap = {
  LogicActionOperator.add: 'add',
  LogicActionOperator.subtract: 'subtract',
  LogicActionOperator.multiply: 'multiply',
  LogicActionOperator.divide: 'divide',
  LogicActionOperator.assign: 'assign',
};

Condition _$ConditionFromJson(Map<String, dynamic> json) => Condition(
  id: json['id'] as String,
  connector: $enumDecode(_$ConditionConnectorEnumMap, json['connector']),
  conditions: json['conditions'] as List<dynamic>,
);

Map<String, dynamic> _$ConditionToJson(Condition instance) => <String, dynamic>{
  'id': instance.id,
  'connector': _$ConditionConnectorEnumMap[instance.connector]!,
  'conditions': instance.conditions,
};

const _$ConditionConnectorEnumMap = {
  ConditionConnector.and: 'and',
  ConditionConnector.or: 'or',
};

ConditionDetail _$ConditionDetailFromJson(Map<String, dynamic> json) =>
    ConditionDetail(
      id: json['id'] as String,
      operator: $enumDecode(_$ConditionOperatorEnumMap, json['operator']),
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
      'operator': _$ConditionOperatorEnumMap[instance.operator]!,
      'leftOperand': instance.leftOperand,
      'rightOperand': instance.rightOperand,
    };

const _$ConditionOperatorEnumMap = {
  ConditionOperator.equals: 'equals',
  ConditionOperator.equalsOneOf: 'equalsOneOf',
  ConditionOperator.isLessThan: 'isLessThan',
  ConditionOperator.isLessThanOrEqual: 'isLessThanOrEqual',
  ConditionOperator.isGreaterThan: 'isGreaterThan',
  ConditionOperator.isGreaterThanOrEqual: 'isGreaterThanOrEqual',
  ConditionOperator.doesNotEqual: 'doesNotEqual',
  ConditionOperator.contains: 'contains',
  ConditionOperator.doesNotContain: 'doesNotContain',
  ConditionOperator.startsWith: 'startsWith',
  ConditionOperator.doesNotStartWith: 'doesNotStartWith',
  ConditionOperator.endsWith: 'endsWith',
  ConditionOperator.doesNotEndWith: 'doesNotEndWith',
  ConditionOperator.isSubmitted: 'isSubmitted',
  ConditionOperator.noOperator: 'noOperator',
};

Operand _$OperandFromJson(Map<String, dynamic> json) => Operand(
  type: $enumDecode(_$OperandTypeEnumMap, json['type']),
  value: json['value'],
);

Map<String, dynamic> _$OperandToJson(Operand instance) => <String, dynamic>{
  'type': _$OperandTypeEnumMap[instance.type]!,
  'value': instance.value,
};

const _$OperandTypeEnumMap = {
  OperandType.question: 'question',
  OperandType.static: 'static',
  OperandType.variable: 'variable',
};
