import 'package:json_annotation/json_annotation.dart';

part 'segment_filter_resource.g.dart';


/// Enums with custom names
enum SegmentConnector { and, or }
enum FilterOperator {
  @JsonValue('lessThan')
  lessThan,
  @JsonValue('lessEqual')
  lessEqual,
  @JsonValue('greaterThan')
  greaterThan,
  @JsonValue('greaterEqual')
  greaterEqual,
  @JsonValue('equals')
  equals,
  @JsonValue('notEquals')
  notEquals,
  @JsonValue('contains')
  contains,
  @JsonValue('doesNotContain')
  doesNotContain,
  @JsonValue('startsWith')
  startsWith,
  @JsonValue('endsWith')
  endsWith,
  @JsonValue('isSet')
  isSet,
  @JsonValue('isNotSet')
  isNotSet,
  @JsonValue('userIsIn')
  userIsIn,
  @JsonValue('userIsNotIn')
  userIsNotIn,
}


/// SegmentFilterRoot union type with discriminated JSON
@JsonSerializable()
class SegmentFilterRoot {
  final String type;
  final String key;

  SegmentFilterRoot(this.type, this.key);

  factory SegmentFilterRoot.attribute(String key) => SegmentFilterRoot('attribute', key);
  factory SegmentFilterRoot.person(String key) => SegmentFilterRoot('person', key);
  factory SegmentFilterRoot.segment(String key) => SegmentFilterRoot('segment', key);
  factory SegmentFilterRoot.device(String key) => SegmentFilterRoot('device', key);

  factory SegmentFilterRoot.fromJson(Map<String, dynamic> json) {
    switch (json['type']) {
      case 'attribute':
        return SegmentFilterRoot.attribute(json['contactAttributeKey'] as String);
      case 'person':
        return SegmentFilterRoot.person(json['personIdentifier'] as String);
      case 'segment':
        return SegmentFilterRoot.segment(json['segmentId'] as String);
      case 'device':
        return SegmentFilterRoot.device(json['deviceType'] as String);
      default:
        throw Exception('Unknown SegmentFilterRoot type: ${json['type']}');
    }
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{'type': type};
    switch (type) {
      case 'attribute':
        map['contactAttributeKey'] = key;
        break;
      case 'person':
        map['personIdentifier'] = key;
        break;
      case 'segment':
        map['segmentId'] = key;
        break;
      case 'device':
        map['deviceType'] = key;
        break;
    }
    return map;
  }
}

/// Qualifier wrapper
@JsonSerializable()
class SegmentFilterQualifier {
  @JsonKey(name: 'operator')
  final FilterOperator operator;

  SegmentFilterQualifier({required this.operator});

  factory SegmentFilterQualifier.fromJson(Map<String, dynamic> json) =>
      _$SegmentFilterQualifierFromJson(json);
  Map<String, dynamic> toJson() => _$SegmentFilterQualifierToJson(this);
}

/// Primitive filter
@JsonSerializable()
class SegmentPrimitiveFilter {
  final String id;
  final SegmentFilterRoot root;
  final dynamic value;
  final SegmentFilterQualifier qualifier;

  SegmentPrimitiveFilter({
    required this.id,
    required this.root,
    required this.value,
    required this.qualifier,
  });

  factory SegmentPrimitiveFilter.fromJson(Map<String, dynamic> json) =>
      _$SegmentPrimitiveFilterFromJson(json);
  Map<String, dynamic> toJson() => _$SegmentPrimitiveFilterToJson(this);
}

/// Recursive resource: either primitive or group
@JsonSerializable()
class SegmentFilterResource {
  final SegmentPrimitiveFilter? primitive;
  final List<SegmentFilter>? group;

  SegmentFilterResource({this.primitive, this.group});

  factory SegmentFilterResource.primitive(SegmentPrimitiveFilter p) =>
      SegmentFilterResource(primitive: p);

  factory SegmentFilterResource.group(List<SegmentFilter> filters) =>
      SegmentFilterResource(group: filters);

  factory SegmentFilterResource.fromJson(Map<String, dynamic> json) {
    if (json is List) {
      final list = (json as List)
          .map((e) => SegmentFilter.fromJson(e as Map<String, dynamic>))
          .toList();
      return SegmentFilterResource.group(list);
    } else {
      return SegmentFilterResource.primitive(
          SegmentPrimitiveFilter.fromJson(json));
    }
  }

  dynamic toJson() {
    if (primitive != null) return primitive!.toJson();
    return group!.map((e) => e.toJson()).toList();
  }
}

/// Filter node
@JsonSerializable()
class SegmentFilter {
  final String id;
  final SegmentConnector? connector;
  final SegmentFilterResource resource;

  SegmentFilter({
    required this.id,
    this.connector,
    required this.resource,
  });

  factory SegmentFilter.fromJson(Map<String, dynamic> json) =>
      _$SegmentFilterFromJson(json);
  Map<String, dynamic> toJson() => _$SegmentFilterToJson(this);
}
