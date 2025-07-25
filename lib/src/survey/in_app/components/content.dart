import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

import '../../../../formbricks_flutter.dart';
import '../../../../l10n/app_localizations.dart';
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
  final int estimatedTimeInSecs;
  final Function() previousStep;
  final Function() nextStep;
  final Function(String, dynamic) onResponse;
  final dynamic response;
  final VoidCallback? onComplete;
  final bool clickOutsideClose;
  final bool hasUserInteracted;
  final int inactivitySecondsRemaining;

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
    required this.estimatedTimeInSecs,
    required this.onComplete,
    required this.clickOutsideClose,
    required this.hasUserInteracted,
    required this.inactivitySecondsRemaining
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
        padding = const EdgeInsets.fromLTRB(
          24.0,
          32.0,
          24.0,
          16.0,
        ); // Reduced bottom padding
        break;
      case SurveyDisplayMode.dialog:
        height = contentHeight ?? deviceHeight * 0.7; // 70% of screen height
        padding = const EdgeInsets.all(16.0);
        isScrollable = false; // Dialogs typically handle overflow internally
        break;
      default:
        height = widgetHeight ?? deviceHeight;
        padding = const EdgeInsets.fromLTRB(24.0, 32.0, 24.0, 16.0);
        break;
    }

    double inactivityProgress = inactivitySecondsRemaining / (survey.autoClose ?? 10).toDouble();
    return SizedBox(
      width: width,
      height: height,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          hasUserInteracted ? SizedBox.shrink() :
              SurveyProgress(progress: inactivityProgress),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              surveyDisplayMode == SurveyDisplayMode.fullScreen
                  ? SizedBox(
                      height: kToolbarHeight,
                    )
                  : SizedBox.shrink(),
              clickOutsideClose ? IconButton(
                onPressed: () {
                    onComplete?.call(); // notify TriggerManager to show next
                    Navigator.of(context).maybePop();
                },
                icon: Icon(
                  LineAwesomeIcons.times_solid,
                  color: Theme.of(context).iconTheme.color?.withOpacity(0.6),
                ),
              ) : SizedBox.shrink(),
            ],
          ),

          Expanded(
            child: SingleChildScrollView(
              physics: isScrollable
                  ? const AlwaysScrollableScrollPhysics()
                  : const NeverScrollableScrollPhysics(),
              child: Padding(
                padding: padding,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: progress >= 1.0
                      ? CrossAxisAlignment.center
                      : CrossAxisAlignment.start,
                  children: [
                    child,
                    SurveyButtons(
                      currentStep: currentStep,
                      nextStep: nextStep,
                      previousStep: previousStep,
                      nextLabel: nextLabel,
                      previousLabel: previousLabel,
                      survey: survey,
                      onComplete: onComplete,
                    ),
                    currentStep == -1 &&
                            survey.welcomeCard?['enabled'] == true &&
                            survey.welcomeCard?['timeToFinish'] == true
                        ? Padding(
                            padding: EdgeInsets.only(top: 20),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.schedule_outlined,
                                  size: 12,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodySmall?.color,
                                ),
                                Text(
                                  "${AppLocalizations.of(context)!.takes_less_than}${Duration(seconds: estimatedTimeInSecs).inMinutes}min",
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          )
                        : SizedBox.shrink(),
                    SizedBox(height: spacerHeight),
                  ],
                ),
              ),
            ),
          ),
          currentStep >= survey.questions.length
              ? SizedBox.shrink()
              : Container(
                  width: width,
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    children: [
                      survey.styling?.isLogoHidden == true
                          ? SizedBox.shrink()
                          : SurveyCopyright(),
                      survey.styling?.hideProgressBar == true
                          ? SizedBox.shrink()
                          : SurveyProgress(progress: progress),
                    ],
                  ),
                ),
        ],
      ),
    );
  }
}
