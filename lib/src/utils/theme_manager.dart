
import 'package:flutter/material.dart';
import '../../formbricks_flutter.dart';

ThemeData buildTheme(BuildContext context, ThemeData? customTheme, Survey survey) {
  final parentTheme = Theme.of(context);
  final formBricksStyling = survey.styling ?? {};
  final baseTheme = customTheme ?? parentTheme;

  // Parse colors with fallback to baseTheme
  Color parseColor(String? hexColor, {String fallbackHex = '0xFF000000'}) {
    return Color(int.parse(
      hexColor?.replaceFirst('#', '0xFF') ?? fallbackHex,
    ));
  }

  // Extract styling properties with fallbacks
  final roundness = formBricksStyling['roundness'] ?? 0.0; // Default to 0 if not specified
  final backgroundColor = parseColor(formBricksStyling['background']?['bg'], fallbackHex: baseTheme.scaffoldBackgroundColor.value.toRadixString(16).padLeft(8, '0'));
  final brandColor = parseColor(formBricksStyling['brandColor']?['light'], fallbackHex: baseTheme.primaryColor.value.toRadixString(16).padLeft(8, '0'));
  final inputColor = parseColor(formBricksStyling['inputColor']?['light'], fallbackHex: baseTheme.inputDecorationTheme.fillColor?.value.toRadixString(16).padLeft(8, '0') ?? '0xFFccddf0');
  final questionColor = parseColor(formBricksStyling['questionColor']?['light'], fallbackHex: baseTheme.textTheme.bodyMedium?.color?.value.toRadixString(16).padLeft(8, '0') ?? '0xFF0a040a');
  final cardBorderColor = parseColor(formBricksStyling['cardBorderColor']?['light'], fallbackHex: baseTheme.dividerColor.value.toRadixString(16).padLeft(8, '0'));
  final cardShadowColor = parseColor(formBricksStyling['cardShadowColor']?['light'], fallbackHex: baseTheme.shadowColor.value.toRadixString(16).padLeft(8, '0'));
  final inputBorderColor = parseColor(formBricksStyling['inputBorderColor']?['light'], fallbackHex: baseTheme.inputDecorationTheme.border?.borderSide.color.value.toRadixString(16).padLeft(8, '0') ?? '0xFF000102');
  final cardBackgroundColor = parseColor(formBricksStyling['cardBackgroundColor']?['light'], fallbackHex: baseTheme.cardColor.value.toRadixString(16).padLeft(8, '0'));
  final highlightBorderColor = parseColor(formBricksStyling['highlightBorderColor']?['light'], fallbackHex: baseTheme.highlightColor.value.toRadixString(16).padLeft(8, '0'));

  // Determine dark mode (currently false, but prepared for future)
  final isDarkMode = formBricksStyling['isDarkModeEnabled'] ?? false;
  final brightness = isDarkMode ? Brightness.dark : Brightness.light;

  print("background color: ${backgroundColor.toString()}");
  print("card color: ${cardBackgroundColor.toString()}");

  return baseTheme.copyWith(
    // General theme properties
    brightness: brightness,
    scaffoldBackgroundColor: backgroundColor,
    primaryColor: brandColor,
    cardColor: cardBackgroundColor,
    shadowColor: cardShadowColor,

    // Text styling
    textTheme: baseTheme.textTheme.merge(
      TextTheme(
        headlineMedium: baseTheme.textTheme.headlineMedium?.copyWith(
          color: questionColor,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        bodyMedium: baseTheme.textTheme.bodyMedium?.copyWith(
          color: questionColor,
        ),
      ),
    ),

    // Input decoration
    inputDecorationTheme: baseTheme.inputDecorationTheme.copyWith(
      fillColor: inputColor,
      border: OutlineInputBorder(
        borderSide: BorderSide(color: inputBorderColor),
        borderRadius: BorderRadius.circular(roundness.toDouble()),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: inputBorderColor),
        borderRadius: BorderRadius.circular(roundness.toDouble()),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: highlightBorderColor),
        borderRadius: BorderRadius.circular(roundness.toDouble()),
      ),
    ),

    // ElevatedButton styling
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(brandColor),
        foregroundColor: WidgetStateProperty.all(
          baseTheme.brightness == Brightness.dark ? Colors.white : Colors.black,
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(roundness.toDouble()),
          ),
        ),
      ),
    ),

    // Card styling
    cardTheme: baseTheme.cardTheme.copyWith(
      shape: RoundedRectangleBorder(
        side: BorderSide(color: cardBorderColor),
        borderRadius: BorderRadius.circular(roundness.toDouble()),
      ),
      elevation: 4,
      shadowColor: cardShadowColor,
    ),

    // Progress bar visibility (custom logic if needed)
    // Note: hideProgressBar is boolean, may require custom widget adjustment
  );
}


ThemeData buildTheme2(BuildContext context, ThemeData? customTheme, Survey survey) {
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
    return Color(int.tryParse('0x$hex') ?? fallback.value);
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
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: brandColor,
    ),
  );
}
