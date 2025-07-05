import 'package:flutter/material.dart';
import 'package:reorderables/reorderables.dart';

import '../../models/question.dart';

/// Order options by preference
class RankingQuestion extends StatefulWidget {
  final Question question;
  final Function(String, dynamic) onResponse;
  final dynamic response;

  const RankingQuestion({
    super.key,
    required this.question,
    required this.onResponse,
    this.response
  });

  @override
  State<RankingQuestion> createState() => _RankingQuestionState();
}

class _RankingQuestionState extends State<RankingQuestion> {
  List<String> rankedItems = [];

  @override
  void initState() {
    super.initState();
    rankedItems = widget.response as List<String>? ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final items = widget.question.inputConfig?['items'] as List<dynamic>? ?? [];

    if (rankedItems.isEmpty) {
      rankedItems = items.map((item) => item['id'] as String).toList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.question.headline['default'] ?? '', style: theme.textTheme.headlineMedium ?? const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        if (widget.question.subheader?['default']?.isNotEmpty ?? false)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(widget.question.subheader?['default'] ?? '', style: theme.textTheme.bodyMedium,),
          ),
        const SizedBox(height: 16),
        ReorderableWrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: rankedItems
              .asMap()
              .entries
              .map((entry) => Chip(
            label: Text(items.firstWhere((item) => item['id'] == entry.value)['label']),
            backgroundColor: Colors.grey[200],
          ))
              .toList(),
          onReorder: (oldIndex, newIndex) {
            setState(() {
              final item = rankedItems.removeAt(oldIndex);
              rankedItems.insert(newIndex, item);
              widget.onResponse(widget.question.id, rankedItems);
            });
          },
        ),
      ],
    );
  }
}