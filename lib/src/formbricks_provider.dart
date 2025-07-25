import 'package:flutter/material.dart';
import '../formbricks_flutter.dart';
import 'manager/survey_manager.dart';
import 'manager/user_manager.dart';

/// A Flutter widget that provides access to the Formbricks client and configuration
/// throughout the widget tree via an [InheritedWidget].
///
/// This is the entry point for setting up Formbricks in your app.
/// It initializes survey and user managers and provides them to descendant widgets.
class FormbricksProvider extends StatefulWidget {
  /// The child widget to which Formbricks context will be provided.
  final Widget child;

  /// The Formbricks client instance responsible for network communication.
  final FormbricksClient client;

  /// The display mode to use when showing in-app surveys.
  final SurveyDisplayMode surveyDisplayMode;

  /// The platform type for survey display (in-app or web).
  final SurveyPlatform surveyPlatform;

  /// Whether to check for new surveys on app restart.
  final bool checkForNewSurveysOnRestart;

  /// The user ID to associate with the current session.
  final String? userId;

  /// The preferred language for survey localization.
  final String? language;

  /// Custom configuration including theming and question widget overrides.
  final FormbricksFlutterConfig? formbricksFlutterConfig;

  const FormbricksProvider({
    super.key,
    required this.child,
    required this.client,
    this.surveyDisplayMode = SurveyDisplayMode.fullScreen,
    this.surveyPlatform = SurveyPlatform.inApp,
    this.checkForNewSurveysOnRestart = false,
    this.userId,
    this.language = 'default',
    this.formbricksFlutterConfig,
  });

  /// Retrieves the state of the nearest [FormbricksProvider] above in the widget tree.
  static _FormbricksProviderState? of(BuildContext context) {
    return context.findAncestorStateOfType<_FormbricksProviderState>();
  }

  @override
  State<FormbricksProvider> createState() => _FormbricksProviderState();
}

/// The state class for [FormbricksProvider] responsible for initializing and managing [SurveyManager] and [UserManager].
class _FormbricksProviderState extends State<FormbricksProvider> {
  late SurveyManager _surveyManager;
  late UserManager _userManager;

  @override
  void initState() {
    super.initState();

    /// Initialize the survey manager with the necessary configuration.
    _surveyManager = SurveyManager(
      client: widget.client,
      context: context,
      formbricksFlutterConfig: widget.formbricksFlutterConfig,
    );

    /// Initialize and configure the user manager.
    _userManager = UserManager();
    if (widget.userId != null && widget.userId!.isNotEmpty) {
      _userManager.setUserId(widget.userId!);
    }
    if (widget.language != null && widget.language!.isNotEmpty) {
      _userManager.setLanguage(widget.language!);
    }

    /// Register user and survey managers in the Formbricks singleton.
    Formbricks.instance.init(
      _userManager,
      _surveyManager,
      widget.checkForNewSurveysOnRestart,
    );

    Formbricks.instance.setSurveyPlatform(widget.surveyPlatform);
    Formbricks.instance.setSurveyDisplayMode(widget.surveyDisplayMode);

  }

  @override
  void didUpdateWidget(covariant FormbricksProvider oldWidget) {
    super.didUpdateWidget(oldWidget);

    /// Update language if it has changed and is not null.
    if (widget.language != oldWidget.language && widget.language != null) {
      _userManager.setLanguage(widget.language!);
    }
  }

  @override
  void dispose() {
    /// You can dispose surveyManager if needed in future to release resources.
    _userManager.logout();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// Provide [SurveyManager] and [UserManager] to the widget tree using an inherited widget.
    return InheritedFormbricks(
      surveyManager: _surveyManager,
      userManager: _userManager,
      child: widget.child,
    );
  }
}

/// An [InheritedWidget] that makes the [SurveyManager] and [UserManager] available
/// to the widget subtree.
///
/// This allows descendant widgets to access survey and user data.
class InheritedFormbricks extends InheritedWidget {
  /// The active survey manager used for handling survey logic and display.
  final SurveyManager surveyManager;

  /// The user manager responsible for identifying and managing user data.
  final UserManager userManager;

  const InheritedFormbricks({
    super.key,
    required this.surveyManager,
    required this.userManager,
    required super.child,
  });

  /// Retrieves the nearest instance of [InheritedFormbricks] in the widget tree.
  static InheritedFormbricks? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<InheritedFormbricks>();
  }

  /// Determines whether the widget should notify its dependents
  /// when [surveyManager] changes.
  @override
  bool updateShouldNotify(InheritedFormbricks oldWidget) {
    return surveyManager != oldWidget.surveyManager;
  }
}

/// Extension method on [BuildContext] to provide convenient access to
/// [SurveyManager] and [UserManager] from anywhere in the widget tree.
extension FormbricksContext on BuildContext {
  /// Returns the nearest [SurveyManager] from the widget tree.
  SurveyManager? get surveyManager => InheritedFormbricks.of(this)?.surveyManager;

  /// Returns the nearest [UserManager] from the widget tree.
  UserManager? get userManager => InheritedFormbricks.of(this)?.userManager;
}
