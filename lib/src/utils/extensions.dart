import 'package:flutter/material.dart';
import '../../formbricks_flutter.dart';

/// Extension on `Map<String, dynamic>?` to provide translation support
/// for localized content in questions (typically used when question data
/// is represented as a map with locale keys).
extension QuestionLocalization on Map<String, dynamic>? {
  /// Returns the localized string for the current app locale.
  ///
  /// It fetches the [locale] from the [SurveyManager] using
  /// the [InheritedFormbricks] context. If the specific locale key
  /// is not available in the map, it falls back to `'default'`.
  /// If neither is found, it returns an empty string.
  String tr(BuildContext context) {
    final surveyManager = InheritedFormbricks.of(context)?.surveyManager;
    final targetLocale = surveyManager?.locale ?? 'en';
    return this?[targetLocale] ?? this?['default'] ?? '';
  }
}

/// Extension on `Map<String, String>?` to provide translation support
/// for localized string maps (commonly used in question labels, etc.).
extension MapLocalization on Map<String, String>? {
  /// Returns the localized string for the current app locale.
  ///
  /// Like [QuestionLocalization], it prioritizes the current locale value,
  /// then falls back to `'default'`, and finally returns an empty string
  /// if neither exists.
  String tr(BuildContext context) {
    final surveyManager = InheritedFormbricks.of(context)?.surveyManager;
    final targetLocale = surveyManager?.locale ?? 'en';
    return this?[targetLocale] ?? this?['default'] ?? '';
  }
}
