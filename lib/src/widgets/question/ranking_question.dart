import 'package:flutter/material.dart';
import 'package:reorderables/reorderables.dart';

import '../../../l10n/app_localizations.dart';
import '../../models/question.dart';
import '../../utils/helper.dart';

class RankingQuestion extends StatefulWidget {
  final Question question;
  final Function(String, dynamic) onResponse;
  final dynamic response;
  final bool useWrapInRankingQuestion;

  const RankingQuestion({
    super.key,
    required this.question,
    required this.onResponse,
    this.response,
    required this.useWrapInRankingQuestion,
  });

  @override
  State<RankingQuestion> createState() => _RankingQuestionState();
}

class _RankingQuestionState extends State<RankingQuestion> {
  late List<String> rankedItems;
  late List<Map<String, dynamic>> choices;

  @override
  void initState() {
    super.initState();
    choices = widget.question.choices ?? [];
    rankedItems = (widget.response as List?)?.cast<String>() ??
        choices.map((c) => c['id']?.toString() ?? '').toList();
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      final item = rankedItems.removeAt(oldIndex);
      rankedItems.insert(newIndex, item);
      widget.onResponse(widget.question.id, rankedItems);
    });
  }

  String _getChoiceLabel(String id) {
    final choice = choices.firstWhere(
          (c) => c['id'] == id,
      orElse: () => {},
    );
    return choice['label']?['default'] ?? id;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRequired = widget.question.required ?? false;

    return FormField<bool>(
      validator: (value) {
        if (!isRequired) return null;

        final allItemsValid = rankedItems.toSet().length == choices.length;
        return allItemsValid ? null : AppLocalizations.of(context)!.please_rank_all_options;
      },
      builder: (field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              //widget.question.headline['default'] ?? '',
              translate(widget.question.headline, context) ?? '',
              style: theme.textTheme.headlineMedium ??
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            //if ((widget.question.subheader?['default'] ?? '').isNotEmpty)
            if ((translate(widget.question.subheader, context) ?? '').isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  //widget.question.subheader!['default']!,
                  translate(widget.question.subheader, context) ?? '',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            const SizedBox(height: 16),
            widget.useWrapInRankingQuestion
                ? ReorderableWrap(
              spacing: 8,
              runSpacing: 8,
              ignorePrimaryScrollController: true,
              onReorder: _onReorder,
              children: rankedItems
                  .asMap()
                  .entries
                  .map((entry) => Chip(
                key: ValueKey(entry.value),
                label: Text('${entry.key + 1}. ${_getChoiceLabel(entry.value)}'),
                backgroundColor: Colors.grey[200],
              ))
                  .toList(),
            )
                : ReorderableListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              onReorder: _onReorder,
              children: rankedItems
                  .asMap()
                  .entries
                  .map((entry) => ListTile(
                key: ValueKey(entry.value),
                title: Text('${entry.key + 1}. ${_getChoiceLabel(entry.value)}'),
                tileColor: Colors.grey[200],
              ))
                  .toList(),
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
