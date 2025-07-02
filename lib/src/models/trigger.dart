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