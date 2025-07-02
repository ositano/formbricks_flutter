import 'package:flutter/material.dart';

import 'formbricks_client.dart';
import 'trigger_manager.dart';
import 'widgets/survey_widget.dart';


class FormBricksProvider extends StatefulWidget {
  final Widget child;
  final FormbricksClient client;
  final String userId;
  final Map<String, dynamic> userAttributes;
  final ThemeData? customTheme;

  const FormBricksProvider({
    super.key,
    required this.child,
    required this.client,
    required this.userId,
    this.userAttributes = const {},
    this.customTheme,
  });

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
      onSurveyTriggered: (surveyId) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Dialog(
            child: SurveyWidget(
              client: widget.client,
              surveyId: surveyId,
              userId: widget.userId,
              customTheme: widget.customTheme,
            ),
          ),
        );
      },
    );
    _triggerManager.initialize();
  }

  void trackEvent(String event) {
    _triggerManager.trackEvent(event, context);
  }

  @override
  Widget build(BuildContext context) {
    return _FormBricksContext(
      triggerManager: _triggerManager,
      child: widget.child,
    );
  }
}

class _FormBricksContext extends InheritedWidget {
  final TriggerManager triggerManager;

  const _FormBricksContext({
    required this.triggerManager,
    required super.child,
  });

  static _FormBricksContext? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_FormBricksContext>();
  }

  @override
  bool updateShouldNotify(_FormBricksContext oldWidget) {
    return triggerManager != oldWidget.triggerManager;
  }
}

void trackFormBricksEvent(BuildContext context, String event) {
  final formBricksContext = _FormBricksContext.of(context);
  formBricksContext?.triggerManager.trackEvent(event, context);
}