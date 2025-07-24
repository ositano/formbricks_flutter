import 'package:json_annotation/json_annotation.dart';
part 'styling.g.dart';

@JsonSerializable()
class Styling {
  final double? roundness;
  final bool? allowStyleOverwrite;
  final bool? overwriteThemeStyling;
  final bool? isLogoHidden;
  final bool? hideProgressBar;
  final bool? isDarkModeEnabled;
  final Map<String, dynamic>? background;
  final Map<String, dynamic>? brandColor;
  final Map<String, dynamic>? inputColor;
  final Map<String, dynamic>? questionColor;
  final Map<String, dynamic>? inputBorderColor;
  final Map<String, dynamic>? cardBackgroundColor;
  final Map<String, dynamic>? cardBorderColor;
  final Map<String, dynamic>? cardShadowColor;
  final Map<String, dynamic>? highlightBorderColor;

  Styling({this.roundness, this.allowStyleOverwrite, this.overwriteThemeStyling, this.isLogoHidden, this.hideProgressBar, this.isDarkModeEnabled, this.background, this.brandColor, this.inputColor, this.questionColor, this.inputBorderColor, this.cardBackgroundColor, this.cardBorderColor, this.cardShadowColor, this.highlightBorderColor});

  factory Styling.fromJson(Map<String, dynamic> json) => _$StylingFromJson(json);
  Map<String, dynamic> toJson() => _$StylingToJson(this);
}