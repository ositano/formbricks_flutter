import 'package:flutter/material.dart';

import '../formbricks_flutter.dart';
import 'utils/enums.dart';

class FormBricksProvider extends StatefulWidget {
  final Widget child;
  final FormBricksClient client;
  final String userId;
  final Map<String, dynamic> userAttributes;
  final ThemeData? customTheme;
  final bool? showPoweredBy;
  final SurveyDisplayMode? surveyDisplayMode;
  final List<TriggerValue>? triggers;

  const FormBricksProvider({
    super.key,
    required this.child,
    required this.client,
    required this.userId,
    this.userAttributes = const {},
    this.customTheme,
    this.showPoweredBy,
    this.surveyDisplayMode = SurveyDisplayMode.bottomSheetModal,
    this.triggers,
  });

  static _FormBricksProviderState? of(BuildContext context) {
    return context.findAncestorStateOfType<_FormBricksProviderState>();
  }

  @override
  State<FormBricksProvider> createState() => _FormBricksProviderState();
}

class _FormBricksProviderState extends State<FormBricksProvider> {
  late TriggerManager _triggerManager;

  @override
  void initState() {
    super.initState();
    _triggerManager = TriggerManager(
        client: widget.client,
        userId: widget.userId,
        userAttributes: widget.userAttributes,
        surveyDisplayMode: widget.surveyDisplayMode,
        showPoweredBy: widget.showPoweredBy,
        context: context,
        triggers: widget.triggers
    );
    _triggerManager.initialize();
    WidgetsBinding.instance.addPostFrameCallback((_){
    });
  }

  @override
  void dispose() {
    _triggerManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: widget.customTheme ?? Theme.of(context),
      child: Builder(
        builder: (context) {
          return InheritedFormBricks(
            triggerManager: _triggerManager,
            child: widget.child,
          );
        },
      ),
    );
  }
}

class InheritedFormBricks extends InheritedWidget {
  final TriggerManager triggerManager;

  const InheritedFormBricks({
    super.key,
    required this.triggerManager,
    required super.child,
  });

  static InheritedFormBricks? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<InheritedFormBricks>();
  }

  @override
  bool updateShouldNotify(InheritedFormBricks oldWidget) {
    return triggerManager != oldWidget.triggerManager;
  }
}

// Extension for easy access in context
extension FormbricksContext on BuildContext {
  TriggerManager? get triggerManager => InheritedFormBricks.of(this)?.triggerManager;
}