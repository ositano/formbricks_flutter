// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'segment_filter_resource.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SegmentFilterQualifier _$SegmentFilterQualifierFromJson(
  Map<String, dynamic> json,
) => SegmentFilterQualifier(
  operator: $enumDecode(_$FilterOperatorEnumMap, json['operator']),
);

Map<String, dynamic> _$SegmentFilterQualifierToJson(
  SegmentFilterQualifier instance,
) => <String, dynamic>{'operator': _$FilterOperatorEnumMap[instance.operator]!};

const _$FilterOperatorEnumMap = {
  FilterOperator.lessThan: 'lessThan',
  FilterOperator.lessEqual: 'lessEqual',
  FilterOperator.greaterThan: 'greaterThan',
  FilterOperator.greaterEqual: 'greaterEqual',
  FilterOperator.equals: 'equals',
  FilterOperator.notEquals: 'notEquals',
  FilterOperator.contains: 'contains',
  FilterOperator.doesNotContain: 'doesNotContain',
  FilterOperator.startsWith: 'startsWith',
  FilterOperator.endsWith: 'endsWith',
  FilterOperator.isSet: 'isSet',
  FilterOperator.isNotSet: 'isNotSet',
  FilterOperator.userIsIn: 'userIsIn',
  FilterOperator.userIsNotIn: 'userIsNotIn',
};

SegmentPrimitiveFilter _$SegmentPrimitiveFilterFromJson(
  Map<String, dynamic> json,
) => SegmentPrimitiveFilter(
  id: json['id'] as String,
  root: SegmentFilterRoot.fromJson(json['root'] as Map<String, dynamic>),
  value: json['value'],
  qualifier: SegmentFilterQualifier.fromJson(
    json['qualifier'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$SegmentPrimitiveFilterToJson(
  SegmentPrimitiveFilter instance,
) => <String, dynamic>{
  'id': instance.id,
  'root': instance.root,
  'value': instance.value,
  'qualifier': instance.qualifier,
};

SegmentFilter _$SegmentFilterFromJson(Map<String, dynamic> json) =>
    SegmentFilter(
      id: json['id'] as String,
      connector: $enumDecodeNullable(
        _$SegmentConnectorEnumMap,
        json['connector'],
      ),
      resource: SegmentFilterResource.fromJson(
        json['resource'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$SegmentFilterToJson(SegmentFilter instance) =>
    <String, dynamic>{
      'id': instance.id,
      'connector': _$SegmentConnectorEnumMap[instance.connector],
      'resource': instance.resource,
    };

const _$SegmentConnectorEnumMap = {
  SegmentConnector.and: 'and',
  SegmentConnector.or: 'or',
};
