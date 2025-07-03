import 'package:flutter/material.dart';

import '../../models/question.dart';

/// Multiple-choice question with multiple selections
class MultiSelectQuestion extends StatefulWidget {
  final Question question;
  final Function(String, dynamic) onResponse;

  const MultiSelectQuestion({
    super.key,
    required this.question,
    required this.onResponse,
  });

  @override
  State<MultiSelectQuestion> createState() => _MultiSelectQuestionState();
}

class _MultiSelectQuestionState extends State<MultiSelectQuestion> {
  List<String> selectedOptions = [];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final options = widget.question.inputConfig?['choices'] as List<dynamic>? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.question.headline['default'] ?? '', style: theme.textTheme.headlineMedium ?? const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        if (widget.question.subheader['default']?.isNotEmpty ?? false)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(widget.question.subheader['default'] ?? '', style: theme.textTheme.bodyMedium,),
          ),
        const SizedBox(height: 16),
        ...options.map((option) => CheckboxListTile(
          title: Text(option['label'], style: theme.textTheme.bodyMedium,),
          value: selectedOptions.contains(option['id']),
          onChanged: (value) {
            setState(() {
              if (value == true) {
                selectedOptions.add(option['id']);
              } else {
                selectedOptions.remove(option['id']);
              }
              widget.onResponse(widget.question.id, selectedOptions);
            });
          },
        )),
      ],
    );
  }
}