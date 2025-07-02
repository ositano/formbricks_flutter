import 'package:flutter/material.dart';

import '../../models/question.dart';

/// Agree/disagree checkbox
class ConsentQuestion extends StatefulWidget {
  final Question question;
  final Function(String, dynamic) onResponse;

  const ConsentQuestion({
    super.key,
    required this.question,
    required this.onResponse,
  });

  @override
  State<ConsentQuestion> createState() => _ConsentQuestionState();
}

class _ConsentQuestionState extends State<ConsentQuestion> {
  bool consented = false;

  @override
  Widget build(BuildContext context) {
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
        CheckboxListTile(
          title: const Text('I agree'),
          value: consented,
          onChanged: (value) {
            setState(() {
              consented = value!;
              widget.onResponse(widget.question.id, value);
            });
          },
        ),
      ],
    );
  }
}