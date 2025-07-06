
import 'package:flutter/material.dart';
import '../../formbricks_flutter.dart';

ThemeData buildTheme(BuildContext context, ThemeData? customTheme, Survey survey) {
  final parentTheme = Theme.of(context);
  final formBricksStyling = survey.styling ?? {};
  final baseTheme = customTheme ?? parentTheme;

  return baseTheme.copyWith(
    primaryColor: Color(
      int.parse(
        formBricksStyling['primaryColor']?.replaceFirst('#', '0xFF') ??
            '0xFF${baseTheme.primaryColor.value.toRadixString(16).padLeft(8, '0')}',
      ),
    ),
    textTheme: baseTheme.textTheme.merge(
      formBricksStyling['fontFamily'] != null
          ? TextTheme(
        headlineMedium: TextStyle(
          fontFamily: formBricksStyling['fontFamily'],
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        bodyMedium: TextStyle(
          fontFamily: formBricksStyling['fontFamily'],
        ),
      )
          : null,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(
          Color(
            int.parse(
              formBricksStyling['buttonColor']?.replaceFirst('#', '0xFF') ??
                  '0xFF${baseTheme.primaryColor.value.toRadixString(16).padLeft(8, '0')}',
            ),
          ),
        ),
        foregroundColor: WidgetStateProperty.all(
          Color(
            int.parse(
              formBricksStyling['buttonTextColor']?.replaceFirst(
                '#',
                '0xFF',
              ) ??
                  '0xFFFFFFFF',
            ),
          ),
        ),
      ),
    ),
  );
}