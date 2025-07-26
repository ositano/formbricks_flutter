import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../formbricks_flutter.dart';
import '../survey/in_app/survey_widget.dart';
import '../survey/webview/survey_webview.dart';
import '../utils/helper.dart';
import '../utils/theme_manager.dart';

/// Handles how surveys are presented in the app – full screen, dialog, bottom sheet, or web view.
class ViewManager {
  /// Displays the Flutter-based survey UI using the specified display mode.
  static void showSurveyInApp(
      BuildContext context,
      FormbricksClient client,
      String userId,
      Survey survey,
      SurveyDisplayMode surveyDisplayMode,
      int estimatedTimeInSecs, {
        FormbricksFlutterConfig? formbricksFlutterConfig,
      }) {

    /// Build the actual survey widget using registered question builders.
    final widgetBody = _buildSurveyWidget(
      client,
      userId,
      survey,
      estimatedTimeInSecs,
      surveyDisplayMode,
      survey.projectOverwrites?['clickOutsideClose'] ?? false,
      addressQuestionBuilder: formbricksFlutterConfig?.addressQuestionBuilder,
      calQuestionBuilder: formbricksFlutterConfig?.calQuestionBuilder,
      consentQuestionBuilder: formbricksFlutterConfig?.consentQuestionBuilder,
      contactInfoQuestionBuilder:
      formbricksFlutterConfig?.contactInfoQuestionBuilder,
      ctaQuestionBuilder: formbricksFlutterConfig?.ctaQuestionBuilder,
      dateQuestionBuilder: formbricksFlutterConfig?.dateQuestionBuilder,
      fileUploadQuestionBuilder:
      formbricksFlutterConfig?.fileUploadQuestionBuilder,
      freeTextQuestionBuilder: formbricksFlutterConfig?.freeTextQuestionBuilder,
      matrixQuestionBuilder: formbricksFlutterConfig?.matrixQuestionBuilder,
      multipleChoiceMultiQuestionBuilder:
      formbricksFlutterConfig?.multipleChoiceMultiQuestionBuilder,
      multipleChoiceSingleQuestionBuilder:
      formbricksFlutterConfig?.multipleChoiceSingleQuestionBuilder,
      npsQuestionBuilder: formbricksFlutterConfig?.npsQuestionBuilder,
      pictureSelectionQuestionBuilder:
      formbricksFlutterConfig?.pictureSelectionQuestionBuilder,
      rankingQuestionBuilder: formbricksFlutterConfig?.rankingQuestionBuilder,
      ratingQuestionBuilder: formbricksFlutterConfig?.ratingQuestionBuilder,
    );

    /// Render survey as full screen page.
    if (surveyDisplayMode == SurveyDisplayMode.fullScreen) {
      final widget = Theme(
        data: buildTheme(context, formbricksFlutterConfig?.customTheme, survey),
        child: Scaffold(
          backgroundColor: Theme.of(context).cardColor,
          appBar: AppBar(
            automaticallyImplyLeading: false, // 👈 Hides the back button
          ),
          body: widgetBody,
        ),
      );
      Navigator.push(
        context,
        Platform.isIOS
            ? CupertinoPageRoute(builder: (context) => widget)
            : MaterialPageRoute(builder: (context) => widget),
      );
    }
    /// Render survey as an alert dialog.
    else if (surveyDisplayMode == SurveyDisplayMode.dialog) {
      final widget = Theme(
        data: buildTheme(context, formbricksFlutterConfig?.customTheme, survey),
        child: widgetBody,
      );
      showDialog(
        context: context,
        barrierDismissible:
        survey.projectOverwrites?['clickOutsideClose'] ?? false,
        builder: (context) => AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          titlePadding: EdgeInsets.zero,
          contentPadding: EdgeInsets.zero,
          actionsPadding: EdgeInsets.zero,
          content: widget,
        ),
      );
    }
    /// Render survey as a modal bottom sheet.
    else {
      final widget = Theme(
        data: buildTheme(context, formbricksFlutterConfig?.customTheme, survey),
        child: widgetBody,
      );
      showModalBottomSheet(
        context: context,
        isDismissible: survey.projectOverwrites?['clickOutsideClose'] ?? false,
        backgroundColor: Colors.transparent,
        builder: (context) => widget,
      );
    }
  }

  /// Displays a web-based version of the survey in a full-screen draggable bottom sheet.
  static void showSurveyWeb(
      BuildContext context,
      FormbricksClient client,
      String userId,
      Survey survey,
      String language,
      String platform,
      Map<String, dynamic> environmentData,
      ) {
    final widget = Container(
      color: Colors.transparent,
      child: SurveyWebview(
        client: client,
        survey: survey,
        userId: userId,
        language: language,
        environmentData: environmentData,
        platform: platform,
        onComplete: () {},
      ),
    );

    showModalBottomSheet(
      context: context,
      isDismissible: survey.projectOverwrites?['clickOutsideClose'] ?? false,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 1.0,
        minChildSize: 0.6,
        maxChildSize: 1.0,
        builder: (context, scrollController) => widget,
      ),
    );
  }

  /// Internal method to create the main `SurveyWidget` using custom question builders.
  static SurveyWidget _buildSurveyWidget(
      FormbricksClient client,
      String userId,
      Survey survey,
      int estimatedTimeInSecs,
      SurveyDisplayMode surveyDisplayMode,
      bool clickOutsideClose, {
        QuestionWidgetBuilder? addressQuestionBuilder,
        QuestionWidgetBuilder? calQuestionBuilder,
        QuestionWidgetBuilder? consentQuestionBuilder,
        QuestionWidgetBuilder? contactInfoQuestionBuilder,
        QuestionWidgetBuilder? ctaQuestionBuilder,
        QuestionWidgetBuilder? dateQuestionBuilder,
        QuestionWidgetBuilder? fileUploadQuestionBuilder,
        QuestionWidgetBuilder? freeTextQuestionBuilder,
        QuestionWidgetBuilder? matrixQuestionBuilder,
        QuestionWidgetBuilder? multipleChoiceMultiQuestionBuilder,
        QuestionWidgetBuilder? multipleChoiceSingleQuestionBuilder,
        QuestionWidgetBuilder? npsQuestionBuilder,
        QuestionWidgetBuilder? pictureSelectionQuestionBuilder,
        QuestionWidgetBuilder? rankingQuestionBuilder,
        QuestionWidgetBuilder? ratingQuestionBuilder,
      }) {
    return SurveyWidget(
      client: client,
      survey: survey,
      userId: userId,
      surveyDisplayMode: surveyDisplayMode,
      estimatedTimeInSecs: estimatedTimeInSecs,
      clickOutsideClose: clickOutsideClose,
      addressQuestionBuilder: addressQuestionBuilder,
      calQuestionBuilder: calQuestionBuilder,
      consentQuestionBuilder: consentQuestionBuilder,
      contactInfoQuestionBuilder: contactInfoQuestionBuilder,
      ctaQuestionBuilder: ctaQuestionBuilder,
      dateQuestionBuilder: dateQuestionBuilder,
      fileUploadQuestionBuilder: fileUploadQuestionBuilder,
      freeTextQuestionBuilder: freeTextQuestionBuilder,
      matrixQuestionBuilder: matrixQuestionBuilder,
      multipleChoiceMultiQuestionBuilder: multipleChoiceMultiQuestionBuilder,
      multipleChoiceSingleQuestionBuilder: multipleChoiceSingleQuestionBuilder,
      npsQuestionBuilder: npsQuestionBuilder,
      pictureSelectionQuestionBuilder: pictureSelectionQuestionBuilder,
      rankingQuestionBuilder: rankingQuestionBuilder,
      ratingQuestionBuilder: ratingQuestionBuilder,
      onComplete: () {}, // Placeholder for future callback
    );
  }
}
