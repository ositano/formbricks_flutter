
/// Defines the survey question model.
class Question {
  final String id;
  final String type;
  final Map<String, String> headline;
  final Map<String, String>? html;
  final Map<String, String>? subheader;
  final bool? required;
  final Map<String, dynamic>? inputConfig;
  final Map<String, String>? lowerLabel;
  final Map<String, String>? upperLabel;
  final Map<String, String>? buttonLabel;
  final Map<String, String>? backButtonLabel;
  final Map<String, String>? dismissButtonLabel;
  final Map<String, String>? label;
  final Map<String, String>? placeholder;
  final String? imageUrl;
  final String? videoUrl;
  final String? inputType;
  final bool? longAnswer;
  final Map<String, dynamic>? charLimit;
  final List<Map<String, dynamic>>? choices;
  final bool? allowMulti;


  Question({
    required this.id,
    required this.type,
    required this.headline,
    this.html,
    this.subheader,
    required this.required,
    this.inputConfig,
    this.lowerLabel,
    this.upperLabel,
    this.buttonLabel,
    this.backButtonLabel,
    this.dismissButtonLabel,
    this.label,
    this.placeholder,
    this.imageUrl,
    this.videoUrl,
    this.inputType,
    this.longAnswer,
    this.charLimit,
    this.choices,
    this.allowMulti
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      type: json['type'] == 'openText' ? 'freeText' : json['type'],
      headline: Map<String, String>.from(json['headline'] ?? {'default': ''}),
      html: json['html'] != null ? Map<String, String>.from(json['html']) : null,
      subheader: json['subheader'] != null ? Map<String, String>.from(json['subheader']) : null,
      required: json['required'] ?? false,
      longAnswer: json['longAnswer'] ?? false,
      inputType: json['inputType'],
      inputConfig: {
        if (json['range'] != null) 'range': json['range'],
        if (json['scale'] != null) 'scale': json['scale'],
        if (json['charLimit'] != null) 'charLimit': json['charLimit'],
        if (json['inputType'] != null) 'inputType': json['inputType'],
        if (json['longAnswer'] != null) 'longAnswer': json['longAnswer'],
        if (json['choices'] != null) 'choices': json['choices'],
        if (json['shuffleOption'] != null) 'shuffleOption': json['shuffleOption'],
        if (json['allowMulti'] != null) 'allowMulti': json['allowMulti'],
        if (json['isColorCodingEnabled'] != null) 'isColorCodingEnabled': json['isColorCodingEnabled'],
        if (json['buttonExternal'] != null) 'buttonExternal': json['buttonExternal'],
      },
      lowerLabel: json['lowerLabel'] != null ? Map<String, String>.from(json['lowerLabel']) : null,
      upperLabel: json['upperLabel'] != null ? Map<String, String>.from(json['upperLabel']) : null,
      buttonLabel: json['buttonLabel'] != null ? Map<String, String>.from(json['buttonLabel']) : null,
      backButtonLabel: json['backButtonLabel'] != null ? Map<String, String>.from(json['backButtonLabel']) : null,
      dismissButtonLabel: json['dismissButtonLabel'] != null ? Map<String, String>.from(json['dismissButtonLabel']) : null,
      label: json['label'] != null ? Map<String, String>.from(json['label']) : null,
      placeholder: json['placeholder'] != null ? Map<String, String>.from(json['placeholder']) : null,
      imageUrl: json['imageUrl'] ?? "",
      videoUrl: json['videoUrl'] ?? "",
      charLimit: {
        if (json['max'] != null) 'range': json['max'],
        if (json['min'] != null) 'scale': json['min'],
        if (json['enabled'] != null) 'enabled': json['enabled'],
      },
      choices: (json['choices'] as List?)?.cast<Map<String, dynamic>>(),
      allowMulti: json['allowMulti'] ?? false,
    );
  }
}