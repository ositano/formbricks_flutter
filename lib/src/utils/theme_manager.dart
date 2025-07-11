
import 'package:flutter/material.dart';
import '../../formbricks_flutter.dart';


ThemeData buildTheme(BuildContext context, ThemeData? customTheme, Survey survey) {
  final parentTheme = Theme.of(context);
  final baseTheme = customTheme ?? parentTheme;
  final formBricksStyling = survey.styling ?? {};

  if (!(formBricksStyling['overwriteThemeStyling'] == true)) {
    return baseTheme;
  }

  Color parseColor(String? hex, {Color fallback = Colors.transparent}) {
    if (hex == null || hex.isEmpty) return fallback;
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) hex = 'FF$hex'; // Add opacity if missing
    return Color(int.tryParse('0x$hex') ?? fallback.toARGB32());
  }

  final brandColor = parseColor(formBricksStyling['brandColor']?['light'], fallback: baseTheme.primaryColor);
  final inputColor = parseColor(formBricksStyling['inputColor']?['light'], fallback: baseTheme.inputDecorationTheme.fillColor ?? Colors.grey[100]!);
  final questionColor = parseColor(formBricksStyling['questionColor']?['light'], fallback: baseTheme.textTheme.bodyLarge?.color ?? Colors.black);
  final cardBorderColor = parseColor(formBricksStyling['cardBorderColor']?['light'], fallback: Colors.transparent);
  final cardShadowColor = parseColor(formBricksStyling['cardShadowColor']?['light'], fallback: Colors.black12);
  final inputBorderColor = parseColor(formBricksStyling['inputBorderColor']?['light'], fallback: Colors.grey);
  final cardBackgroundColor = parseColor(formBricksStyling['cardBackgroundColor']?['light'], fallback: baseTheme.cardColor);
  final highlightBorderColor = parseColor(formBricksStyling['highlightBorderColor']?['light'], fallback: Colors.blueAccent);
  final roundness = double.tryParse('${formBricksStyling['roundness']}') ?? 8.0;

  return baseTheme.copyWith(
    primaryColor: brandColor,
    cardColor: cardBackgroundColor,
    scaffoldBackgroundColor: cardBackgroundColor,// parseColor(formBricksStyling['background']?['bg'], fallback: baseTheme.scaffoldBackgroundColor),
    cardTheme: baseTheme.cardTheme.copyWith(
      color: cardBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(roundness),
        side: BorderSide(color: cardBorderColor),
      ),
      shadowColor: cardShadowColor,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: inputColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(roundness),
        borderSide: BorderSide(color: inputBorderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(roundness),
        borderSide: BorderSide(color: highlightBorderColor, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: highlightBorderColor, width: 2),
        borderRadius: BorderRadius.circular(roundness),
      ),
    ),
    textTheme: baseTheme.textTheme.copyWith(
      headlineMedium: baseTheme.textTheme.headlineMedium?.copyWith(
        color: questionColor,
      ),
      bodyMedium: baseTheme.textTheme.bodyMedium?.copyWith(
        color: questionColor,
      ),
      bodySmall: baseTheme.textTheme.bodySmall?.copyWith(
        color: questionColor,
      ),
    ),
    radioTheme: baseTheme.radioTheme.copyWith(
      fillColor: WidgetStateProperty.all(brandColor),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(roundness),
          ),
        ),
        backgroundColor: WidgetStateProperty.all(brandColor),
        foregroundColor: WidgetStateProperty.all(Colors.white),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(roundness),
            side: BorderSide(color: brandColor, width: 2),
          ),
        ),
        backgroundColor: WidgetStateProperty.all(Colors.white),
        foregroundColor: WidgetStateProperty.all(brandColor),
      ),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: brandColor,
    ),
  );
}

double styleRoundness(Survey survey){
  final formBricksStyling = survey.styling ?? {};

  if (!(formBricksStyling['overwriteThemeStyling'] == true)) {
    return 8.0;
  }
  return double.tryParse('${formBricksStyling['roundness']}') ?? 8.0;
}
