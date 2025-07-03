class Question {
  final String id;
  final String type;
  final Map<String, String> headline;
  final String subheader;
  final bool required;
  final Map<String, dynamic>? inputConfig;

  Question({
    required this.id,
    required this.type,
    required this.headline,
    required this.subheader,
    required this.required,
    this.inputConfig,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      type: json['type'],
      headline: Map<String, String>.from(json['headline'] ?? {'default': ''}),
      subheader: json['subheader']?.toString() ?? '',
      required: json['required'] ?? false,
      inputConfig: json['inputConfig'],
    );
  }
}