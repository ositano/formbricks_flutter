import 'dart:ui';
import 'package:flutter/material.dart';
import '../../formbricks_flutter.dart';

/// Builds a custom [ThemeData] for Formbricks surveys based on optional styling overrides.
///
/// It supports both light and dark mode. The `survey.styling` configuration can include separate
/// values for `light` and `dark` modes for each color property.
///
/// If the survey does not specify `overwriteThemeStyling: true`, the provided `customTheme` or
/// the current `Theme.of(context)` is returned unchanged.
ThemeData buildTheme(BuildContext context, ThemeData? customTheme, Survey survey) {
  // Use customTheme if provided, otherwise use the theme from context
  final parentTheme = Theme.of(context);
  final baseTheme = customTheme ?? parentTheme;

  // Check for styling overrides in the survey config
  final formBricksStyling = survey.styling;

  // If overwriteThemeStyling is false or not set, return base theme unchanged
  if (!(formBricksStyling != null && formBricksStyling.overwriteThemeStyling == true)) {
    return baseTheme;
  }

  // Determine whether we are currently in dark mode
  final brightness = baseTheme.brightness;
  final isDarkMode = brightness == Brightness.dark;

  /// Helper function to parse hex color strings into [Color] objects.
  /// If parsing fails, the [fallback] color is returned.
  Color parseColor(String? hex, {required Color fallback}) {
    if (hex == null || hex.isEmpty) return fallback;
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) hex = 'FF$hex'; // Add alpha channel if missing
    return Color(int.tryParse('0x$hex') ?? fallback.toARGB32());
  }

  /// Utility function to get a color from styling config based on brightness mode.
  Color themedColor(Map<String, dynamic>? colorMap, {required Color fallback}) {
    return parseColor(
      isDarkMode && colorMap != null && colorMap.containsKey('dark')  ? colorMap['dark'] : colorMap?['light'],
      fallback: fallback,
    );
  }

  // Extract style values, using theme fallbacks where applicable
  final brandColor = themedColor(
    formBricksStyling.brandColor,
    fallback: baseTheme.primaryColor,
  );

  final inputColor = themedColor(
    formBricksStyling.inputColor,
    fallback: baseTheme.inputDecorationTheme.fillColor ?? Colors.grey[100]!,
  );

  final questionColor = themedColor(
    formBricksStyling.questionColor,
    fallback: baseTheme.textTheme.bodyLarge?.color ?? Colors.black,
  );

  final cardBorderColor = themedColor(
    formBricksStyling.cardBorderColor,
    fallback: Colors.transparent,
  );

  final cardShadowColor = themedColor(
    formBricksStyling.cardShadowColor,
    fallback: Colors.black12,
  );

  final inputBorderColor = themedColor(
    formBricksStyling.inputBorderColor,
    fallback: Colors.grey,
  );

  final cardBackgroundColor = themedColor(
    formBricksStyling.cardBackgroundColor,
    fallback: baseTheme.cardColor,
  );

  final highlightBorderColor = themedColor(
    formBricksStyling.highlightBorderColor,
    fallback: Colors.blueAccent,
  );

  final roundness = double.tryParse('${formBricksStyling.roundness}') ?? 8.0;

  // Build and return the custom ThemeData
  return baseTheme.copyWith(
    primaryColor: brandColor,
    scaffoldBackgroundColor: cardBackgroundColor,
    cardColor: cardBackgroundColor,

    // Card appearance
    cardTheme: baseTheme.cardTheme.copyWith(
      color: cardBackgroundColor,
      shadowColor: cardShadowColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(roundness),
        side: BorderSide(color: cardBorderColor),
      ),
    ),

    // Input decoration (text fields, dropdowns, etc.)
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
        borderRadius: BorderRadius.circular(roundness),
        borderSide: BorderSide(color: inputBorderColor),
      ),
    ),

    // Text styles (for questions, etc.)
    textTheme: baseTheme.textTheme.copyWith(
      headlineMedium: baseTheme.textTheme.headlineMedium?.copyWith(color: questionColor, fontSize: 18, fontWeight: FontWeight.bold),
      titleMedium: baseTheme.textTheme.titleMedium?.copyWith(color: questionColor, fontWeight: FontWeight.w300),
      bodyMedium: baseTheme.textTheme.bodyMedium?.copyWith(color: questionColor),
      bodySmall: baseTheme.textTheme.bodySmall?.copyWith(color: questionColor),
    ),

    // Radio buttons
    radioTheme: baseTheme.radioTheme.copyWith(
      fillColor: WidgetStateProperty.all(brandColor),
    ),

    // Elevated button style
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(brandColor),
        foregroundColor: WidgetStateProperty.all(Colors.white),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(roundness),
          ),
        ),
      ),
    ),

    // Outlined button style
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.all(brandColor),
        backgroundColor: WidgetStateProperty.all(Colors.white),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(roundness),
            side: BorderSide(color: brandColor, width: 2),
          ),
        ),
      ),
    ),

    // Progress indicators (like loading spinners)
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: brandColor,
    ),

    // Custom theme extension for roundness
    extensions: <ThemeExtension<dynamic>>[
      MyCustomTheme(styleRoundness: roundness),
    ],
  );
}

/// Custom [ThemeExtension] to support reading additional styling properties from the theme.
/// This allows you to access `MyCustomTheme.of(context)?.styleRoundness` anywhere in the app.
@immutable
class MyCustomTheme extends ThemeExtension<MyCustomTheme> {
  final double? styleRoundness;

  const MyCustomTheme({this.styleRoundness});

  @override
  MyCustomTheme copyWith({double? styleRoundness}) {
    return MyCustomTheme(
      styleRoundness: styleRoundness ?? this.styleRoundness,
    );
  }

  @override
  MyCustomTheme lerp(ThemeExtension<MyCustomTheme>? other, double t) {
    if (other is! MyCustomTheme) return this;
    return MyCustomTheme(
      styleRoundness: lerpDouble(styleRoundness, other.styleRoundness, t),
    );
  }
}
