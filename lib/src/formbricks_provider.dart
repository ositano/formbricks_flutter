import 'package:flutter/material.dart';
import '../formbricks_flutter.dart';
import 'utils/helper.dart';

/// A Flutter widget that provides access to the Formbricks client and configuration
/// throughout the widget tree via an [InheritedWidget].
class FormbricksProvider extends StatefulWidget {
  final Widget child;
  final FormbricksClient client;
  final String userId;
  final Map<String, dynamic> userAttributes;
  final ThemeData? customTheme;
  final bool showPoweredBy;
  final SurveyDisplayMode surveyDisplayMode;
  final List<TriggerValue> triggers;
  final String locale;

  // Optional overrides for question widget builders
  final QuestionWidgetBuilder? addressQuestionBuilder;
  final QuestionWidgetBuilder? calQuestionBuilder;
  final QuestionWidgetBuilder? consentQuestionBuilder;
  final QuestionWidgetBuilder? contactInfoQuestionBuilder;
  final QuestionWidgetBuilder? ctaQuestionBuilder;
  final QuestionWidgetBuilder? dateQuestionBuilder;
  final QuestionWidgetBuilder? fileUploadQuestionBuilder;
  final QuestionWidgetBuilder? freeTextQuestionBuilder;
  final QuestionWidgetBuilder? matrixQuestionBuilder;
  final QuestionWidgetBuilder? multipleChoiceMultiQuestionBuilder;
  final QuestionWidgetBuilder? multipleChoiceSingleQuestionBuilder;
  final QuestionWidgetBuilder? npsQuestionBuilder;
  final QuestionWidgetBuilder? pictureSelectionQuestionBuilder;
  final QuestionWidgetBuilder? rankingQuestionBuilder;
  final QuestionWidgetBuilder? ratingQuestionBuilder;

  const FormbricksProvider({
    super.key,
    required this.child,
    required this.client,
    required this.userId,
    this.userAttributes = const {},
    this.customTheme,
    this.showPoweredBy = true,
    this.surveyDisplayMode = SurveyDisplayMode.fullScreen,
    this.triggers = const [],
    this.locale = 'en',
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

  /// Retrieves the state of the nearest [FormbricksProvider] above the widget tree.
  static _FormbricksProviderState? of(BuildContext context) {
    return context.findAncestorStateOfType<_FormbricksProviderState>();
  }

  @override
  State<FormbricksProvider> createState() => _FormbricksProviderState();
}

/// The state class for [FormbricksProvider] responsible for initializing and managing [SurveyManager].
class _FormbricksProviderState extends State<FormbricksProvider> {
  late SurveyManager _surveyManager;

  @override
  void initState() {
    super.initState();

    // Initialize the survey manager with user, client, and UI configuration
    _surveyManager = SurveyManager(
      client: widget.client,
      userId: widget.userId,
      userAttributes: widget.userAttributes,
      surveyDisplayMode: widget.surveyDisplayMode,
      showPoweredBy: widget.showPoweredBy,
      context: context,
      triggers: widget.triggers,
      locale: widget.locale,
      addressQuestionBuilder: widget.addressQuestionBuilder,
      calQuestionBuilder: widget.ctaQuestionBuilder,
      consentQuestionBuilder: widget.consentQuestionBuilder,
      contactInfoQuestionBuilder: widget.contactInfoQuestionBuilder,
      ctaQuestionBuilder: widget.ctaQuestionBuilder,
      dateQuestionBuilder: widget.dateQuestionBuilder,
      fileUploadQuestionBuilder: widget.fileUploadQuestionBuilder,
      freeTextQuestionBuilder: widget.freeTextQuestionBuilder,
      matrixQuestionBuilder: widget.matrixQuestionBuilder,
      multipleChoiceMultiQuestionBuilder:
          widget.multipleChoiceMultiQuestionBuilder,
      multipleChoiceSingleQuestionBuilder:
          widget.multipleChoiceSingleQuestionBuilder,
      npsQuestionBuilder: widget.npsQuestionBuilder,
      pictureSelectionQuestionBuilder: widget.pictureSelectionQuestionBuilder,
      rankingQuestionBuilder: widget.rankingQuestionBuilder,
      ratingQuestionBuilder: widget.ratingQuestionBuilder,
    );

    // Initialize Formbricks singleton
    Formbricks().init(_surveyManager);

    _surveyManager.initialize();
  }

  @override
  void didUpdateWidget(covariant FormbricksProvider oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the locale has changed, update SurveyManager and trigger rebuild
    if (widget.locale != oldWidget.locale) {
      _surveyManager.setLocale(widget.locale);
    }
  }

  @override
  void dispose() {
    // Clean up resources when the provider is removed
    _surveyManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Provide SurveyManager to widget tree
    return InheritedFormbricks(
      surveyManager: _surveyManager,
      child: widget.child,
    );
  }
}

/// An inherited widget used to expose the [SurveyManager] instance to the widget tree.
class InheritedFormbricks extends InheritedWidget {
  final SurveyManager surveyManager;

  const InheritedFormbricks({
    super.key,
    required this.surveyManager,
    required super.child,
  });

  /// Retrieves the closest [InheritedFormbricks] instance in the widget tree.
  static InheritedFormbricks? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<InheritedFormbricks>();
  }

  /// Determines whether the widget should notify dependents on update.
  @override
  bool updateShouldNotify(InheritedFormbricks oldWidget) {
    return surveyManager != oldWidget.surveyManager;
  }
}

/// Extension method to easily access [SurveyManager] from [BuildContext].
extension FormbricksContext on BuildContext {
  SurveyManager? get surveyManager =>
      InheritedFormbricks.of(this)?.surveyManager;
}
