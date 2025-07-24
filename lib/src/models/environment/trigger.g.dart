// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trigger.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Trigger _$TriggerFromJson(Map<String, dynamic> json) => Trigger(
  actionClass: json['actionClass'] == null
      ? null
      : ActionClassReference.fromJson(
          json['actionClass'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$TriggerToJson(Trigger instance) => <String, dynamic>{
  'actionClass': instance.actionClass,
};
