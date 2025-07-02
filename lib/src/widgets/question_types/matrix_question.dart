import 'package:flutter/material.dart';

import '../../models/question.dart';

/// Grid-based question with rows and columns (e.g., rate multiple items on a scale).
class MatrixQuestion extends StatefulWidget {
  final Question question;
  final Function(String, dynamic) onResponse;

  const MatrixQuestion({
    super.key,
    required this.question,
    required this.onResponse,
  });

  @override
  State<MatrixQuestion> createState() => _MatrixQuestionState();
}

class _MatrixQuestionState extends State<MatrixQuestion> {
  Map<String, String> selections = {};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rows = widget.question.inputConfig?['rows'] as List<dynamic>? ?? [];
    final columns = widget.question.inputConfig?['columns'] as List<dynamic>? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.question.headline, style: theme.textTheme.headlineMedium ?? const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        if (widget.question.subheader.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(widget.question.subheader, style: theme.textTheme.bodyMedium,),
          ),
        const SizedBox(height: 16),
        Table(
          border: TableBorder.all(),
          children: [
            TableRow(
              children: [
                const SizedBox(),
                ...columns.map((col) => Center(child: Text(col['label']))),
              ],
            ),
            ...rows.map((row) {
              final rowId = row['id'];
              return TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(row['label']),
                  ),
                  ...columns.map((col) {
                    final colId = col['id'];
                    return Radio<String>(
                      value: colId,
                      groupValue: selections[rowId],
                      onChanged: (value) {
                        setState(() {
                          selections[rowId] = value!;
                          widget.onResponse(widget.question.id, selections);
                        });
                      },
                    );
                  }),
                ],
              );
            }),
          ],
        ),
      ],
    );
  }
}