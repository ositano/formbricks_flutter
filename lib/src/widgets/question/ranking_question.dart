import 'package:flutter/material.dart';
import 'package:reorderables/reorderables.dart';

import '../../../l10n/app_localizations.dart';
import '../../models/question.dart';
import '../../utils/helper.dart';

class RankingQuestion extends StatefulWidget {
  final Question question;
  final Function(String, dynamic) onResponse;
  final dynamic response;
  final bool requiredAnswerByLogicCondition;

  const RankingQuestion({
    super.key,
    required this.question,
    required this.onResponse,
    this.response,
    required this.requiredAnswerByLogicCondition
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
        if(widget.requiredAnswerByLogicCondition) {
          return AppLocalizations.of(context)!.response_required;
        }

        if (!isRequired) return null;

        final allItemsValid = rankedItems.toSet().length == choices.length;
        return allItemsValid ? null : AppLocalizations.of(context)!.please_rank_all_options;
      },
      builder: (field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              translate(widget.question.headline, context) ?? '',
              style: theme.textTheme.headlineMedium ??
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if ((translate(widget.question.subheader, context) ?? '').isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  translate(widget.question.subheader, context) ?? '',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            const SizedBox(height: 16),
            ReorderableColumn(
              crossAxisAlignment: CrossAxisAlignment.start,
              needsLongPressDraggable: false,
              onReorder: _onReorder,
              children: rankedItems.asMap().entries.map((entry) {
                final index = entry.key + 1;
                final value = entry.value;
                final label = _getChoiceLabel(value);
                return Container(
                  key: ValueKey(value),
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.inputDecorationTheme.enabledBorder!.borderSide.color, width: 2),
                    borderRadius: BorderRadius.circular(10),
                    color: theme.inputDecorationTheme.fillColor
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.primaryColor,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '$index',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: theme.scaffoldBackgroundColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          label,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      const Icon(Icons.drag_handle, color: Colors.grey),
                    ],
                  ),
                );
              }).toList(),
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
