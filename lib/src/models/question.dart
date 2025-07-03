class Question {
  final String id;
  final String type;
  final Map<String, String> headline;
  final Map<String, String> subheader;
  final bool required;
  final Map<String, dynamic>? inputConfig;
  final Map<String, String>? lowerLabel;
  final Map<String, String>? upperLabel;
  final Map<String, String>? buttonLabel;

  Question({
    required this.id,
    required this.type,
    required this.headline,
    required this.subheader,
    required this.required,
    this.inputConfig,
    this.lowerLabel,
    this.upperLabel,
    this.buttonLabel,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      type: json['type'],
      headline: Map<String, String>.from(json['headline'] ?? {'default': ''}),
      subheader: Map<String, String>.from(json['subheader'] ?? {'default': ''}),
      required: json['required'] ?? false,
      inputConfig: json['inputConfig'],
      lowerLabel: json['lowerLabel'] != null ? Map<String, String>.from(json['lowerLabel']) : null,
      upperLabel: json['upperLabel'] != null ? Map<String, String>.from(json['upperLabel']) : null,
      buttonLabel: json['buttonLabel'] != null ? Map<String, String>.from(json['buttonLabel']) : null,
    );
  }
}