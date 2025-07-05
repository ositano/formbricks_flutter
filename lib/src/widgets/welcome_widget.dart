import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

import '../../formbricks_flutter.dart';

class WelcomeWidget extends StatelessWidget {
  final Survey survey;

  const WelcomeWidget({super.key, required this.survey});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    String? timeToFinishText;
    if (survey.welcomeCard?['timeToFinish'] != null) {
      final time = survey.welcomeCard!['timeToFinish'];
      timeToFinishText = time is int
          ? 'Estimated time: ${time ~/ 60} min ${time % 60} sec'
          : time is String
          ? 'Estimated time: $time'
          : null;
    }

    int? responseCount = survey.welcomeCard?['responseCount'];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (survey.welcomeCard?['fileUrl'] != null)
          Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Image.network(survey.welcomeCard!['fileUrl'], fit: BoxFit.fitWidth, height: 50,),
          ),
        Text(
          survey.welcomeCard?['headline']['default'] ?? '',
          style: theme.textTheme.headlineMedium ?? const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        HtmlWidget(survey.welcomeCard?['html']['default'] ?? ''),
        if (timeToFinishText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              timeToFinishText,
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
          ),
        if (survey.welcomeCard?['showResponseCount'] == true &&
            responseCount != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              '$responseCount responses',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
          ),
        const SizedBox(height: 20),
      ],
    );
  }
}
