import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../models/question.dart';
import '../../utils/helper.dart';

/// Button or link for an action
class StatementQuestion extends StatelessWidget {
  final Question question;
  final Function(String, dynamic) onResponse;

  const StatementQuestion({
    super.key,
    required this.question,
    required this.onResponse,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonText = question.inputConfig?['buttonText'] ?? AppLocalizations.of(context)!.click_here;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            //question.headline['default'] ?? '',
            translate(question.headline, context) ?? '',
            style: theme.textTheme.headlineMedium ?? const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        //if (question.subheader?['default']?.isNotEmpty ?? false)
        if (translate(question.subheader, context)?.isNotEmpty ?? false)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              //question.subheader?['default'] ?? '',
              translate(question.subheader, context) ?? '',
              style: theme.textTheme.bodyMedium,),
          ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => onResponse(question.id, true),
          child: Text(buttonText),
        ),
      ],
    );
  }
}