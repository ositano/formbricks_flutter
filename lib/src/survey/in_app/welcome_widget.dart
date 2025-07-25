import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

import '../../../formbricks_flutter.dart';
import '../../../l10n/app_localizations.dart';
import '../../utils/helper.dart';


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
          ? '${AppLocalizations.of(context)!.estimated_time}: ${time ~/ 60} min ${time % 60} sec'
          : time is String
          ? '${AppLocalizations.of(context)!.estimated_time}: $time'
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
            child: CachedNetworkImage(
              imageUrl: survey.welcomeCard!['fileUrl'],
              fit: BoxFit.fitWidth,
              height: 50,
              placeholder: (context, url) => const Center(
                  child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator())),
              errorWidget: (context, url, error) =>
              const Icon(Icons.error),
            )
          ),
        Text(
          translate(survey.welcomeCard?['headline'], context) ?? '',
          style:
              theme.textTheme.headlineMedium ??
              const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        HtmlWidget(translate(survey.welcomeCard?['html'], context) ?? ''),
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
              '$responseCount ${AppLocalizations.of(context)!.responses}',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
          ),
        const SizedBox(height: 20),
      ],
    );
  }
}
