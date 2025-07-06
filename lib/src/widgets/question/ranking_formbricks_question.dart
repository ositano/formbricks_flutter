import 'package:flutter/material.dart';
import 'package:reorderables/reorderables.dart';

import '../../models/question.dart';

/// Order options by preference
class RankingFormbricksQuestion extends StatefulWidget {
  final Question question;
  final Function(String, dynamic) onResponse;
  final dynamic response;
  final bool useWrapInRankingQuestion;

  const RankingFormbricksQuestion({
    super.key,
    required this.question,
    required this.onResponse,
    this.response,
    required this.useWrapInRankingQuestion,
  });

  @override
  State<RankingFormbricksQuestion> createState() =>
      _RankingFormbricksQuestionState();
}

class _RankingFormbricksQuestionState extends State<RankingFormbricksQuestion> {
  late List<String> rankedItems;

  @override
  void initState() {
    super.initState();
    final choices = widget.question.choices ?? [];
    rankedItems =
        widget.response as List<String>? ??
        choices.map((choice) => choice['id'] as String).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final choices = widget.question.choices ?? [];

    return FormField<bool>(
      validator: (value) =>
          widget.question.required == false ||
              (rankedItems.length == choices.length &&
                  rankedItems.toSet().length == choices.length)
          ? null
          : 'Please select an option',
      builder: (FormFieldState<bool> field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.question.headline['default'] ?? '',
              style:
                  theme.textTheme.headlineMedium ??
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (widget.question.subheader?['default']?.isNotEmpty ?? false)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  widget.question.subheader?['default'] ?? '',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            const SizedBox(height: 16),
            widget.useWrapInRankingQuestion
                ? Expanded(
                  child: ReorderableWrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      ignorePrimaryScrollController: true,
                      children: rankedItems
                          .asMap()
                          .entries
                          .map(
                            (entry) => Chip(
                              key: ValueKey(rankedItems[entry.key]),
                              label: Text(
                                '${entry.key + 1}. ${choices.firstWhere((choice) => choice['id'] == entry.value)['label']['default'] ?? ''}',
                              ),
                              backgroundColor:
                                  Colors.grey[200], // Background color
                            ),
                          )
                          .toList(),
                      onReorder: (oldIndex, newIndex) {
                        setState(() {
                          final item = rankedItems.removeAt(oldIndex);
                          rankedItems.insert(newIndex, item);
                          widget.onResponse(widget.question.id, rankedItems);
                        });
                      },
                    ),
                )
                : Expanded(
                  child: ReorderableListView(
                      shrinkWrap: true,
                      primary: false,
                      children: rankedItems
                          .asMap()
                          .entries
                          .map(
                            (entry) => ListTile(
                              key: ValueKey(rankedItems[entry.key]),
                              title: Text(
                                '${entry.key + 1}. ${choices.firstWhere((choice) => choice['id'] == entry.value)['label']['default'] ?? ''}',
                              ),
                              tileColor: Colors.grey[200], // Background color
                            ),
                          )
                          .toList(),
                      onReorder: (oldIndex, newIndex) {
                        setState(() {
                          final item = rankedItems.removeAt(oldIndex);
                          rankedItems.insert(newIndex, item);
                          widget.onResponse(widget.question.id, rankedItems);
                        });
                      },
                    ),
                ),
            if (field.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  field.errorText!,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
          ],
        );
      },
    );
  }
}
