// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Question _$QuestionFromJson(Map<String, dynamic> json) => Question(
  id: json['id'] as String,
  type: $enumDecode(_$QuestionTypeEnumMap, json['type']),
  headline: Map<String, String>.from(json['headline'] as Map),
  html: (json['html'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as String),
  ),
  subheader: (json['subheader'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as String),
  ),
  required: json['required'] as bool?,
  lowerLabel: (json['lowerLabel'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as String),
  ),
  upperLabel: (json['upperLabel'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as String),
  ),
  buttonLabel: (json['buttonLabel'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as String),
  ),
  backButtonLabel: (json['backButtonLabel'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as String),
  ),
  dismissButtonLabel: (json['dismissButtonLabel'] as Map<String, dynamic>?)
      ?.map((k, e) => MapEntry(k, e as String)),
  label: (json['label'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as String),
  ),
  placeholder: (json['placeholder'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as String),
  ),
  imageUrl: json['imageUrl'] as String?,
  videoUrl: json['videoUrl'] as String?,
  inputType: json['inputType'] as String?,
  longAnswer: json['longAnswer'] as bool?,
  charLimit: json['charLimit'] as Map<String, dynamic>?,
  choices: (json['choices'] as List<dynamic>?)
      ?.map((e) => e as Map<String, dynamic>)
      .toList(),
  allowMulti: json['allowMulti'] as bool?,
  rows: (json['rows'] as List<dynamic>?)
      ?.map((e) => Map<String, String>.from(e as Map))
      .toList(),
  columns: (json['columns'] as List<dynamic>?)
      ?.map((e) => Map<String, String>.from(e as Map))
      .toList(),
  shuffleOption: json['shuffleOption'] as String?,
  allowedFileExtensions: (json['allowedFileExtensions'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  allowMultipleFiles: json['allowMultipleFiles'] as bool?,
  calHost: json['calHost'] as String?,
  calUserName: json['calUserName'] as String?,
  zip: json['zip'] as Map<String, dynamic>?,
  city: json['city'] as Map<String, dynamic>?,
  state: json['state'] as Map<String, dynamic>?,
  country: json['country'] as Map<String, dynamic>?,
  addressLine1: json['addressLine1'] as Map<String, dynamic>?,
  addressLine2: json['addressLine2'] as Map<String, dynamic>?,
  email: json['email'] as Map<String, dynamic>?,
  phone: json['phone'] as Map<String, dynamic>?,
  company: json['company'] as Map<String, dynamic>?,
  firstName: json['firstName'] as Map<String, dynamic>?,
  lastName: json['lastName'] as Map<String, dynamic>?,
  maxSizeInMB: (json['maxSizeInMB'] as num?)?.toInt(),
  format: json['format'] as String?,
  logic: (json['logic'] as List<dynamic>?)
      ?.map((e) => Logic.fromJson(e as Map<String, dynamic>))
      .toList(),
  logicFallback: json['logicFallback'] as String?,
  buttonUrl: json['buttonUrl'] as String?,
  range: (json['range'] as num?)?.toInt(),
  scale: json['scale'] as String?,
);

Map<String, dynamic> _$QuestionToJson(Question instance) => <String, dynamic>{
  'id': instance.id,
  'type': _$QuestionTypeEnumMap[instance.type]!,
  'headline': instance.headline,
  'html': instance.html,
  'subheader': instance.subheader,
  'required': instance.required,
  'lowerLabel': instance.lowerLabel,
  'upperLabel': instance.upperLabel,
  'buttonLabel': instance.buttonLabel,
  'backButtonLabel': instance.backButtonLabel,
  'dismissButtonLabel': instance.dismissButtonLabel,
  'label': instance.label,
  'placeholder': instance.placeholder,
  'imageUrl': instance.imageUrl,
  'videoUrl': instance.videoUrl,
  'inputType': instance.inputType,
  'longAnswer': instance.longAnswer,
  'charLimit': instance.charLimit,
  'choices': instance.choices,
  'allowMulti': instance.allowMulti,
  'rows': instance.rows,
  'columns': instance.columns,
  'shuffleOption': instance.shuffleOption,
  'allowMultipleFiles': instance.allowMultipleFiles,
  'allowedFileExtensions': instance.allowedFileExtensions,
  'calHost': instance.calHost,
  'calUserName': instance.calUserName,
  'zip': instance.zip,
  'city': instance.city,
  'state': instance.state,
  'country': instance.country,
  'addressLine1': instance.addressLine1,
  'addressLine2': instance.addressLine2,
  'email': instance.email,
  'phone': instance.phone,
  'company': instance.company,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'maxSizeInMB': instance.maxSizeInMB,
  'format': instance.format,
  'logic': instance.logic,
  'logicFallback': instance.logicFallback,
  'buttonUrl': instance.buttonUrl,
  'range': instance.range,
  'scale': instance.scale,
};

const _$QuestionTypeEnumMap = {
  QuestionType.freeText: 'freeText',
  QuestionType.openText: 'openText',
  QuestionType.multipleChoiceSingle: 'multipleChoiceSingle',
  QuestionType.multipleChoiceMulti: 'multipleChoiceMulti',
  QuestionType.pictureSelection: 'pictureSelection',
  QuestionType.rating: 'rating',
  QuestionType.nps: 'nps',
  QuestionType.ranking: 'ranking',
  QuestionType.matrix: 'matrix',
  QuestionType.consent: 'consent',
  QuestionType.fileUpload: 'fileUpload',
  QuestionType.date: 'date',
  QuestionType.cal: 'cal',
  QuestionType.address: 'address',
  QuestionType.contactInfo: 'contactInfo',
  QuestionType.cta: 'cta',
  QuestionType.unSupportedType: 'unSupportedType',
};
