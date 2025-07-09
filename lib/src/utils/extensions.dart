import 'package:flutter/material.dart';
import '../../formbricks_flutter.dart';

extension QuestionLocalization on Map<String, dynamic>? {
  String tr(BuildContext context) {
    final triggerManager = InheritedFormBricks.of(context)?.triggerManager;
    final targetLocale = triggerManager?.locale ?? 'en';
    return this?[targetLocale] ?? this?['default'] ?? '';
  }
}

extension MapLocalization on Map<String, String>? {
  String tr(BuildContext context) {
    final triggerManager = InheritedFormBricks.of(context)?.triggerManager;
    final targetLocale = triggerManager?.locale ?? 'en';
    return this?[targetLocale] ?? this?['default'] ?? '';
  }
}