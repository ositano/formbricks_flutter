import 'package:flutter/material.dart';

import '../../../../formbricks_flutter.dart';
import 'buttons.dart';
import 'copyright.dart';
import 'progress.dart';

class SurveyContent extends StatelessWidget {
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

  const SurveyContent({
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
    final deviceWidth = MediaQuery.of(context).size.width;
    final deviceHeight = MediaQuery.of(context).size.height;

    // Determine base dimensions
    final width = widgetWidth ?? deviceWidth;
    double height;
    EdgeInsets padding;
    bool isScrollable = true;

    switch (surveyDisplayMode) {
      case SurveyDisplayMode.bottomSheetModal:
        height = contentHeight ?? deviceHeight * 0.8; // 80% of screen height
        padding = const EdgeInsets.fromLTRB(24.0, 32.0, 24.0, 16.0); // Reduced bottom padding
        break;
      case SurveyDisplayMode.dialog:
        height = contentHeight ?? deviceHeight * 0.7; // 70% of screen height
        padding = const EdgeInsets.all(16.0);
        isScrollable = false; // Dialogs typically handle overflow internally
        break;
      case SurveyDisplayMode.formbricks:
      default:
        height = widgetHeight ?? deviceHeight;
        padding = const EdgeInsets.fromLTRB(24.0, 32.0, 24.0, 16.0);
        break;
    }

    return SizedBox(
      width: width,
      height: height,
      child: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top + kToolbarHeight),
          Expanded(
            child: SingleChildScrollView(
              physics: isScrollable ? const AlwaysScrollableScrollPhysics() : const NeverScrollableScrollPhysics(),
              child: Padding(
                padding: padding,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    surveyDisplayMode == SurveyDisplayMode.formbricks
                        ? Flexible(
                      fit: FlexFit.loose,
                      child: child,
                    )
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
          Container(
            width: width,
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              children: [
                SurveyCopyright(),
                SurveyProgress(progress: progress),
              ],
            ),
          ),
        ],
      ),
    );
  }
}