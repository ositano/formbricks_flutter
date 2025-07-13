import 'package:flutter/material.dart';
import '../formbricks_flutter.dart';
import 'formbricks.dart';
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
  final List<TriggerValue>? triggers;
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
    this.triggers,
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

/// The state class for [FormbricksProvider] responsible for initializing and managing [TriggerManager].
class _FormbricksProviderState extends State<FormbricksProvider> {
  late TriggerManager _triggerManager;

  @override
  void initState() {
    super.initState();

    // Initialize the trigger manager with user, client, and UI configuration
    _triggerManager = TriggerManager(
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
    Formbricks().init(_triggerManager);

    _triggerManager.initialize();

    // Optionally perform post-frame logic
    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  @override
  void didUpdateWidget(covariant FormbricksProvider oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the locale has changed, update TriggerManager and trigger rebuild
    if (widget.locale != oldWidget.locale) {
      _triggerManager.setLocale(widget.locale);
    }
  }

  @override
  void dispose() {
    // Clean up resources when the provider is removed
    _triggerManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Provide TriggerManager to widget tree
    return InheritedFormbricks(
      triggerManager: _triggerManager,
      child: widget.child,
    );
  }
}

/// An inherited widget used to expose the [TriggerManager] instance to the widget tree.
class InheritedFormbricks extends InheritedWidget {
  final TriggerManager triggerManager;

  const InheritedFormbricks({
    super.key,
    required this.triggerManager,
    required super.child,
  });

  /// Retrieves the closest [InheritedFormbricks] instance in the widget tree.
  static InheritedFormbricks? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<InheritedFormbricks>();
  }

  /// Determines whether the widget should notify dependents on update.
  @override
  bool updateShouldNotify(InheritedFormbricks oldWidget) {
    return triggerManager != oldWidget.triggerManager;
  }
}

/// Extension method to easily access [TriggerManager] from [BuildContext].
extension FormbricksContext on BuildContext {
  TriggerManager? get triggerManager =>
      InheritedFormbricks.of(this)?.triggerManager;
}
