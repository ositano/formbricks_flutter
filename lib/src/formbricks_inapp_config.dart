import 'package:flutter/material.dart';
import 'utils/helper.dart';

/// Configuration class for customizing the Formbricks Flutter experience.
///
/// Allows you to override default question widgets and apply a custom theme
/// to surveys in your Flutter application.
///
/// This configuration is intended to be passed to the `FormbricksFlutter` provider wrapper
/// and provides centralized control over how questions and themes are rendered.
class FormbricksInAppConfig {
  /// Custom [ThemeData] to be applied across all survey screens and widgets.
  ///
  /// If not provided, the default app theme will be used.
  /// NB: if overwriteThemeStyling is set to true, it will prioritize the survey config theme
  /// over app theme or custom theme
  final ThemeData? customTheme;

  /// Builder for custom Address question widgets.
  final QuestionWidgetBuilder? addressQuestionBuilder;

  /// Builder for custom Calendar question widgets.
  final QuestionWidgetBuilder? calQuestionBuilder;

  /// Builder for custom Consent question widgets.
  final QuestionWidgetBuilder? consentQuestionBuilder;

  /// Builder for custom Contact Info question widgets.
  final QuestionWidgetBuilder? contactInfoQuestionBuilder;

  /// Builder for custom Call-to-Action (CTA) question widgets.
  final QuestionWidgetBuilder? ctaQuestionBuilder;

  /// Builder for custom Date Picker question widgets.
  final QuestionWidgetBuilder? dateQuestionBuilder;

  /// Builder for custom File Upload question widgets.
  final QuestionWidgetBuilder? fileUploadQuestionBuilder;

  /// Builder for custom Open/Free Text question widgets.
  final QuestionWidgetBuilder? freeTextQuestionBuilder;

  /// Builder for custom Matrix question widgets.
  final QuestionWidgetBuilder? matrixQuestionBuilder;

  /// Builder for custom Multiple Choice (multi-select) question widgets.
  final QuestionWidgetBuilder? multipleChoiceMultiQuestionBuilder;

  /// Builder for custom Multiple Choice (single-select) question widgets.
  final QuestionWidgetBuilder? multipleChoiceSingleQuestionBuilder;

  /// Builder for custom Net Promoter Score (NPS) question widgets.
  final QuestionWidgetBuilder? npsQuestionBuilder;

  /// Builder for custom Picture Selection question widgets.
  final QuestionWidgetBuilder? pictureSelectionQuestionBuilder;

  /// Builder for custom Ranking question widgets.
  final QuestionWidgetBuilder? rankingQuestionBuilder;

  /// Builder for custom Rating question widgets.
  final QuestionWidgetBuilder? ratingQuestionBuilder;

  /// Creates a [FormbricksInAppConfig] instance with optional custom widget builders and theming.
  ///
  /// All fields are optional; any question type left unconfigured will fall back
  /// to its default implementation.
  FormbricksInAppConfig({
    this.customTheme,
    this.addressQuestionBuilder,
    this.calQuestionBuilder,
    this.consentQuestionBuilder,
    this.contactInfoQuestionBuilder,
    this.ctaQuestionBuilder,
    this.dateQuestionBuilder,
    this.fileUploadQuestionBuilder,
    this.freeTextQuestionBuilder,
    this.matrixQuestionBuilder,
    this.multipleChoiceMultiQuestionBuilder,
    this.multipleChoiceSingleQuestionBuilder,
    this.npsQuestionBuilder,
    this.pictureSelectionQuestionBuilder,
    this.rankingQuestionBuilder,
    this.ratingQuestionBuilder,
  });
}
