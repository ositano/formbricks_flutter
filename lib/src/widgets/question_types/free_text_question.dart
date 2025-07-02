import 'package:flutter/material.dart';

import '../../models/question.dart';

/// Open-ended text input (equivalent to Open Text).
class FreeTextQuestion extends StatelessWidget {
  final Question question;
  final Function(String, dynamic) onResponse;

  const FreeTextQuestion({
    super.key,
    required this.question,
    required this.onResponse,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(question.headline, style: theme.textTheme.headlineMedium ?? const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        if (question.subheader.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(question.subheader, style: theme.textTheme.bodyMedium,),
          ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Your response',
            border: OutlineInputBorder(),
            labelStyle: theme.textTheme.bodyMedium
          ),
          maxLines: 4,
          validator: question.required
              ? (value) => value == null || value.isEmpty ? 'This field is required' : null
              : null,
          onChanged: (value) => onResponse(question.id, value),
        ),
      ],
    );
  }
}