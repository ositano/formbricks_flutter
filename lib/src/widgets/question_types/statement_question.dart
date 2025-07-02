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
        Text(question.headline, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        if (question.subheader.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(question.subheader),
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