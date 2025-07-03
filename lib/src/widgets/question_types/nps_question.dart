import 'package:flutter/material.dart';

import '../../models/question.dart';

class NPSQuestion extends StatelessWidget {
  final Question question;
  final Function(String, dynamic) onResponse;

  const NPSQuestion({
    super.key,
    required this.question,
    required this.onResponse,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    int selectedIndex = -1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question.headline['default'] ?? '',
          style: theme.textTheme.headlineMedium ?? const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        if (question.subheader['default']?.isNotEmpty ?? false)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              question.subheader['default'] ?? '',
              style: theme.textTheme.bodyMedium,
            ),
          ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (question.lowerLabel != null)
              Text(
                question.lowerLabel!['default'] ?? '',
                style: theme.textTheme.bodySmall,
              ),
            const Spacer(),
            if (question.upperLabel != null)
              Text(
                question.upperLabel!['default'] ?? '',
                style: theme.textTheme.bodySmall,
              ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          children: List.generate(11, (index) {
            return ChoiceChip(
              label: Text('$index'),
              selected: false,
              onSelected: (selected) {
                if (selected) {
                  selectedIndex = index;
                  onResponse(question.id, index);
                }
              },
              selectedColor: theme.primaryColor,
              labelStyle: TextStyle(
                color: selectedIndex == index ? Colors.white : theme.textTheme.bodyMedium?.color,
              ),
            );
          }),
        ),
      ],
    );
  }
}