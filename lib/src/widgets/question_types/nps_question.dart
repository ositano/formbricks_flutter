import 'package:flutter/material.dart';

import '../../models/question.dart';

/// 0–10 score with optional comment.
class NPSQuestion extends StatefulWidget {
  final Question question;
  final Function(String, dynamic) onResponse;

  const NPSQuestion({
    super.key,
    required this.question,
    required this.onResponse,
  });

  @override
  State<NPSQuestion> createState() => _NPSQuestionState();
}

class _NPSQuestionState extends State<NPSQuestion> {
  int _score = 5;
  final _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(11, (index) => GestureDetector(
            onTap: () {
              setState(() {
                _score = index;
                widget.onResponse(widget.question.id, {'score': index, 'comment': _commentController.text});
              });
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _score == index ? Colors.blue : Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('$index', style: TextStyle(
                color: _score == index ? Colors.white : Colors.black,
              )),
            ),
          )),
        ),
        const SizedBox(height: 8),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('0\nNot likely'),
            Text('10\nVery likely'),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _commentController,
          decoration: const InputDecoration(
            labelText: 'Why did you give this score? (Optional)',
            border: OutlineInputBorder(),
          ),
          maxLines: 4,
          onChanged: (value) {
            widget.onResponse(widget.question.id, {'score': _score, 'comment': value});
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}