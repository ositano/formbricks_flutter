import 'package:flutter/material.dart';

import '../../../../formbricks_flutter.dart';
import 'buttons.dart';
import 'copyright.dart';
import 'progress.dart';

class SurveyContentFormbricks extends StatelessWidget {
  final double? widgetWidth;
  final double? widgetHeight;
  final double? contentHeight;
  final double spacerHeight;
  final double? bottom;
  final double progress;
  final Widget child;
  final int currentStep;
  final String? nextLabel;
  final String? previousLabel;
  final Survey survey;
  final SurveyDisplayMode surveyDisplayMode;

  final Function() previousStep;
  final Function() nextStep;
  final Function(String, dynamic) onResponse;
  final dynamic response;

  const SurveyContentFormbricks({
    super.key,
    this.widgetWidth,
    this.widgetHeight,
    required this.contentHeight,
    required this.spacerHeight,
    this.bottom,
    required this.progress,
    required this.currentStep,
    required this.nextStep,
    required this.previousStep,
    required this.nextLabel,
    required this.previousLabel,
    required this.onResponse,
    required this.response,
    required this.survey,
    required this.child,
    required this.surveyDisplayMode,
  });

  @override
  Widget build(BuildContext context) {
    //debugPrint("current step: $spacerHeight");
    // debugPrint("next label: $nextLabel");
    final deviceWidth = MediaQuery.of(context).size.width;
    final deviceHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      width: widgetWidth ?? deviceWidth,
      height: widgetHeight ?? deviceHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            bottom: bottom ?? 0, // Align to the very bottom
            left: 0,
            right: 0,
            child: Container(
              color: surveyDisplayMode == SurveyDisplayMode.dialog
                  ? Theme.of(context).dialogTheme.backgroundColor
                  : Theme.of(context).cardColor,
              width: deviceWidth,
              child: Column(
                children: [
                  SurveyCopyright(),
                  SurveyProgress(progress: progress),
                ],
              ),
            ),
          ),
          Container(
            width: widgetWidth ?? deviceWidth,
            height:
            contentHeight ??
                widgetHeight ??
                deviceHeight, // Fixed height for the card
            alignment: Alignment.topCenter, // Align card to bottom
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                  0, // Remove fixed minHeight to allow natural overflow
                  maxHeight: contentHeight ?? widgetHeight ?? deviceHeight,
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    24.0,
                    32.0,
                    24.0,
                    50.0,
                  ), // Extra padding at bottom for stack elements
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      surveyDisplayMode == SurveyDisplayMode.formbricks
                          ? Flexible(
                        fit: FlexFit.loose,
                        child: child,
                      ) // Allow content to expand and trigger scroll:
                          : child,
                      SurveyButtons(
                        currentStep: currentStep,
                        nextStep: nextStep,
                        previousStep: previousStep,
                        nextLabel: nextLabel,
                        previousLabel: previousLabel,
                        survey: survey,
                      ),
                      SizedBox(height: spacerHeight),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
