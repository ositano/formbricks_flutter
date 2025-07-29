import 'package:flutter/material.dart';
import 'package:reorderables/reorderables.dart';
import '../../../../formbricks_flutter.dart';
import '../../../utils/helper.dart';
import '../components/custom_heading.dart';

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
  late List<Map<String, dynamic>> choices;
  late List<String> rankedChoices;

  @override
  void initState() {
    super.initState();
    choices = widget.question.choices ?? [];
    List<String> choiceInList = choices.map((c) => translate(c['label'], context) ?? '').toList();
    rankedChoices = widget.response as List<String>? ?? choiceInList;
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      final item = rankedChoices.removeAt(oldIndex);
      rankedChoices.insert(newIndex, item);
      widget.onResponse(widget.question.id, rankedChoices);
    });
  }

  String _getChoiceLabel(String id) {
    final choice = choices.firstWhere(
          (c) => c['id'] == id,
      orElse: () => {},
    );
    return translate(choice['label'], context) ?? id;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    bool isRequired = widget.question.required ?? false;
    if(widget.requiredAnswerByLogicCondition){
      isRequired = widget.requiredAnswerByLogicCondition;
    }

    return FormField<bool>(
      key: ValueKey(widget.question.id),
      validator: (value) {
        if (!isRequired) return null;
        final allItemsValid = rankedChoices.toSet().length == choices.length;
        return allItemsValid ? null : AppLocalizations.of(context)!.please_rank_all_options;
      },
      builder: (field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomHeading(question: widget.question, required: isRequired),
            ReorderableColumn(
              crossAxisAlignment: CrossAxisAlignment.start,
              needsLongPressDraggable: false,
              onReorder: _onReorder,
              children: rankedChoices.asMap().entries.map((entry) {
                final index = entry.key + 1;
                final value = entry.value;
                final label = _getChoiceLabel(value);
                return Container(
                  key: ValueKey(value),
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.inputDecorationTheme.enabledBorder != null ? theme.inputDecorationTheme.enabledBorder!.borderSide.color : theme.unselectedWidgetColor, width: 2),
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
