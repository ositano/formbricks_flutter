import 'package:flutter/material.dart';

import '../../models/question.dart';

/// Single-choice multiple-choice question
class SingleSelectQuestion extends StatefulWidget {
  final Question question;
  final Function(String, dynamic) onResponse;

  const SingleSelectQuestion({
    super.key,
    required this.question,
    required this.onResponse,
  });

  @override
  State<SingleSelectQuestion> createState() => _SingleSelectQuestionState();
}

class _SingleSelectQuestionState extends State<SingleSelectQuestion> {
  String? selectedOption;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final options = widget.question.inputConfig?['choices'] as List<dynamic>? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.question.headline, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        if (widget.question.subheader.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(widget.question.subheader),
          ),
        const SizedBox(height: 16),
        ...options.map((option) => RadioListTile<String>(
          title: Text(option['label']),
          value: option['id'],
          groupValue: selectedOption,
          onChanged: (value) {
            setState(() {
              selectedOption = value;
              widget.onResponse(widget.question.id, value);
            });
          },
        )),
      ],
    );
  }
}