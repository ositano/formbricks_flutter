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
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Your response',
            border: OutlineInputBorder(),
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