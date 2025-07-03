import 'package:flutter/material.dart';

import '../../models/question.dart';

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
    final buttonText = question.inputConfig?['buttonText'] ?? 'Click here';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(question.headline['default'] ?? '', style: theme.textTheme.headlineMedium ?? const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        if (question.subheader['default']?.isNotEmpty ?? false)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(question.subheader['default'] ?? '', style: theme.textTheme.bodyMedium,),
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