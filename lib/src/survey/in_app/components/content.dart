import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

import '../../../../formbricks_flutter.dart';
import 'buttons.dart';
import 'copyright.dart';
import 'progress.dart';

/// This widget is the main layout for displaying a survey screen.
/// It handles layout, display mode (fullscreen, bottom sheet, dialog),
/// navigation buttons, progress bars, estimated time, and auto-close behavior.
class SurveyContent extends StatelessWidget {
  /// Optional custom dimensions for the survey widget
  final double? widgetWidth;
  final double? widgetHeight;
  final double? contentHeight;

  /// Spacer height between the content and bottom section
  final double spacerHeight;

  /// Bottom offset (used for modal placement if needed)
  final double? bottom;

  /// Current progress in the survey (0.0 to 1.0)
  final double progress;

  /// Index of the current step/question
  final int currentStep;

  /// Survey navigation labels
  final String? nextLabel;
  final String? previousLabel;

  /// Survey model object
  final Survey survey;

  /// Display mode: dialog, bottom sheet, or fullscreen
  final SurveyDisplayMode surveyDisplayMode;

  /// Estimated completion time (in seconds)
  final int estimatedTimeInSecs;

  /// Step navigation callbacks
  final Function() previousStep;
  final Function() nextStep;

  /// Response handling
  final Function(String, dynamic) onResponse;
  final dynamic response;

  /// Called when survey is completed or dismissed
  final VoidCallback? onComplete;

  /// Whether tapping outside can close the survey
  final bool clickOutsideClose;

  /// Whether user has interacted with survey
  final bool hasUserInteracted;

  /// Countdown value before auto-close (in seconds)
  final int inactivitySecondsRemaining;

  /// The current survey content (typically a question widget)
  final Widget child;

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
    required this.inactivitySecondsRemaining,
  });

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final deviceHeight = MediaQuery.of(context).size.height;

    /// Set dimensions based on mode
    final width = widgetWidth ?? deviceWidth;
    double height;
    EdgeInsets padding;
    bool isScrollable = true;

    /// Set layout and scroll behavior depending on display mode
    switch (surveyDisplayMode) {
      case SurveyDisplayMode.bottomSheetModal:
        height = contentHeight ?? deviceHeight * 0.8;
        padding = const EdgeInsets.fromLTRB(24.0, 32.0, 24.0, 1.0);
        break;
      case SurveyDisplayMode.dialog:
        height = contentHeight ?? deviceHeight * 0.7;
        padding = const EdgeInsets.all(16.0);
        isScrollable = false; /// Dialog typically handles overflow itself
        break;
      default:
        height = widgetHeight ?? deviceHeight;
        padding = EdgeInsets.fromLTRB(24.0, 0, 24.0, 1.0);
        break;
    }

    /// Progress bar value for inactivity countdown (used for auto-close)
    double inactivityProgress = inactivitySecondsRemaining / (survey.autoClose ?? 10).toDouble();

    return SizedBox(
      width: width,
      height: height,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /// Show inactivity countdown progress bar only if user hasn't interacted
          hasUserInteracted
              ? SizedBox.shrink()
              : SurveyProgress(progress: inactivityProgress, inactivitySecs: survey.autoClose,),

          /// Top-right close button (only in modal/dialog mode)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              surveyDisplayMode == SurveyDisplayMode.fullScreen
                  ? SizedBox(height: MediaQuery.of(context).padding.top + kToolbarHeight)
                  : SizedBox.shrink(),
              clickOutsideClose
                  ? IconButton(
                onPressed: () {
                  onComplete?.call(); /// Trigger completion logic
                  Navigator.of(context).maybePop(); /// Close the dialog/modal
                },
                icon: Icon(
                  LineAwesomeIcons.times_solid,
                  color: Theme.of(context).iconTheme.color?.withAlpha((255 * 0.6).round()),
                ),
              )
                  : SizedBox.shrink(),
            ],
          ),

          /// Main survey content
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
                    /// Injected survey step/question widget
                    child,

                    /// Navigation buttons
                    SurveyButtons(
                      currentStep: currentStep,
                      nextStep: nextStep,
                      previousStep: previousStep,
                      nextLabel: nextLabel,
                      previousLabel: previousLabel,
                      survey: survey,
                      onComplete: onComplete,
                    ),

                    /// Show estimated time (only on welcome card)
                    currentStep == -1 &&
                        survey.welcomeCard?['enabled'] == true &&
                        survey.welcomeCard?['timeToFinish'] == true
                        ? Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Row(
                        children: [
                          Icon(
                            Icons.schedule_outlined,
                            size: 12,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                          Text(
                            "${AppLocalizations.of(context)!.takes_less_than}${Duration(seconds: estimatedTimeInSecs).inMinutes}min",
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    )
                        : SizedBox.shrink(),

                    /// Bottom spacing
                    SizedBox(height: spacerHeight),
                  ],
                ),
              ),
            ),
          ),

          /// Bottom progress bar and copyright section
          currentStep >= survey.questions.length
              ? SizedBox.shrink()
              : Container(
            width: width,
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              children: [
                /// Show formbricks logo/copyright [powered by Formbricks] unless hidden
                survey.styling?.isLogoHidden == true
                    ? SizedBox.shrink()
                    : SurveyCopyright(),

                /// Show progress bar (except on welcome or if disabled)
                (currentStep == -1 && survey.welcomeCard?['enabled'] == true) ||
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
