import '../utils/enums.dart';

class Trigger {
  final String event;
  final Map<String, dynamic>? attributes;
  final Map<String, dynamic>? delay;

  Trigger({
    required this.event,
    this.attributes,
    this.delay,
  });

  factory Trigger.fromJson(Map<String, dynamic> json) {
    return Trigger(
      event: json['event'],
      attributes: json['attributes'],
      delay: json['delay'],
    );
  }
}


class TriggerValue {
  final TriggerType type;
  final String? name; // For noCode
  final String? key;  // For code

  TriggerValue({
    required this.type,
    this.name,
    this.key,
  });
}