// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'styling.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Styling _$StylingFromJson(Map<String, dynamic> json) => Styling(
  roundness: (json['roundness'] as num?)?.toDouble(),
  allowStyleOverwrite: json['allowStyleOverwrite'] as bool?,
  overwriteThemeStyling: json['overwriteThemeStyling'] as bool?,
  isLogoHidden: json['isLogoHidden'] as bool?,
  hideProgressBar: json['hideProgressBar'] as bool?,
  isDarkModeEnabled: json['isDarkModeEnabled'] as bool?,
  background: json['background'] as Map<String, dynamic>?,
  brandColor: json['brandColor'] as Map<String, dynamic>?,
  inputColor: json['inputColor'] as Map<String, dynamic>?,
  questionColor: json['questionColor'] as Map<String, dynamic>?,
  inputBorderColor: json['inputBorderColor'] as Map<String, dynamic>?,
  cardBackgroundColor: json['cardBackgroundColor'] as Map<String, dynamic>?,
  cardBorderColor: json['cardBorderColor'] as Map<String, dynamic>?,
  cardShadowColor: json['cardShadowColor'] as Map<String, dynamic>?,
  highlightBorderColor: json['highlightBorderColor'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$StylingToJson(Styling instance) => <String, dynamic>{
  'roundness': instance.roundness,
  'allowStyleOverwrite': instance.allowStyleOverwrite,
  'overwriteThemeStyling': instance.overwriteThemeStyling,
  'isLogoHidden': instance.isLogoHidden,
  'hideProgressBar': instance.hideProgressBar,
  'isDarkModeEnabled': instance.isDarkModeEnabled,
  'background': instance.background,
  'brandColor': instance.brandColor,
  'inputColor': instance.inputColor,
  'questionColor': instance.questionColor,
  'inputBorderColor': instance.inputBorderColor,
  'cardBackgroundColor': instance.cardBackgroundColor,
  'cardBorderColor': instance.cardBorderColor,
  'cardShadowColor': instance.cardShadowColor,
  'highlightBorderColor': instance.highlightBorderColor,
};
