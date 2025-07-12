
import 'logic.dart';

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
  final List<Map<String, String>>? rows;
  final List<Map<String, String>>? columns;
  final String? shuffleOption;
  final bool? allowMultipleFiles;
  final List<String>? allowedFileExtensions;
  final String? calHost;
  final String? calUserName;
  final Map<String, dynamic>? zip;
  final Map<String, dynamic>? city;
  final Map<String, dynamic>? state;
  final Map<String, dynamic>? country;
  final Map<String, dynamic>? addressLine1;
  final Map<String, dynamic>? addressLine2;
  final Map<String, dynamic>? email;
  final Map<String, dynamic>? phone;
  final Map<String, dynamic>? company;
  final Map<String, dynamic>? firstName;
  final Map<String, dynamic>? lastName;
  final int? maxSizeInMB;
  final String? format;
  final List<Logic> logic;
  final String? logicFallback; // Target if logic conditions fail
  final String? buttonUrl;

  double? _styleRoundness;

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
    this.allowMulti,
    this.rows,
    this.columns,
    this.shuffleOption,
    this.allowedFileExtensions,
    this.allowMultipleFiles,
    this.calHost,
    this.calUserName,
    this.zip,
    this.city,
    this.state,
    this.country,
    this.addressLine1,
    this.addressLine2,
    this.email,
    this.phone,
    this.company,
    this.firstName,
    this.lastName,
    this.maxSizeInMB,
    this.format,
    required this.logic,
    this.logicFallback,
    this.buttonUrl
  });

  set styleRoundness(double roundness){
    _styleRoundness = roundness;
  }

  double get styleRoundness => _styleRoundness ?? 8.0;

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
      shuffleOption: json['shuffleOption'],
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
      buttonUrl: json['buttonUrl'] ?? '',
      charLimit: {
        if (json['max'] != null) 'range': json['max'],
        if (json['min'] != null) 'scale': json['min'],
        if (json['enabled'] != null) 'enabled': json['enabled'],
      },
      choices: (json['choices'] as List?)?.cast<Map<String, dynamic>>(),
      rows: _listOfMapsToStringMaps(json['rows'] as List<dynamic>?),
      columns: _listOfMapsToStringMaps(json['columns'] as List<dynamic>?),
      allowMulti: json['allowMulti'] ?? false,
      allowMultipleFiles: json['allowMultipleFiles'] ?? false,
      allowedFileExtensions: (json['columns'] as List?)?.cast<String>(),
      calHost: json['calHost'],
      calUserName: json['calUserName'],
      zip: json['zip'] != null ? Map<String, dynamic>.from(json['zip']) : null,
      city: json['city'] != null ? Map<String, dynamic>.from(json['city']) : null,
      state: json['state'] != null ? Map<String, dynamic>.from(json['state']) : null,
      country: json['country'] != null ? Map<String, dynamic>.from(json['country']) : null,
      addressLine1: json['addressLine1'] != null ? Map<String, dynamic>.from(json['addressLine1']) : null,
      addressLine2: json['addressLine2'] != null ? Map<String, dynamic>.from(json['addressLine2']) : null,
      email: json['email'] != null ? Map<String, dynamic>.from(json['email']) : null,
      phone: json['phone'] != null ? Map<String, dynamic>.from(json['phone']) : null,
      company: json['company'] != null ? Map<String, dynamic>.from(json['company']) : null,
      lastName: json['lastName'] != null ? Map<String, dynamic>.from(json['lastName']) : null,
      firstName: json['firstName'] != null ? Map<String, dynamic>.from(json['firstName']) : null,
      maxSizeInMB: json['maxSizeInMB'] ?? 0,
      format: json['format'],
      logic: json['logic'] != null ? (json['logic'] as List)
          .map((q) => Logic.fromJson(q))
          .toList() : [],
      logicFallback: json['logicFallback'],
    );
  }

  // Custom function to convert Map<String, dynamic> to Map<String, String>
  static Map<String, String> _mapToStringMap(Map<String, dynamic>? map) {
    if (map == null) return {};
    return map.map((key, value) => MapEntry(key, value.toString()));
  }

  // Custom function to convert List<Map<String, dynamic>> to List<Map<String, String>>
  static List<Map<String, String>>? _listOfMapsToStringMaps(List<dynamic>? list) {
    if (list == null) return null;
    return list.map((item) => _mapToStringMap(item as Map<String, dynamic>)).toList();
  }
}