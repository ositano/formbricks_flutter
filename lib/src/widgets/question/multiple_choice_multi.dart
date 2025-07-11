import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../models/question.dart';
import '../../utils/helper.dart';

class MultipleChoiceMulti extends StatefulWidget {
  final Question question;
  final Function(String, dynamic) onResponse;
  final dynamic response;
  final bool requiredAnswerByLogicCondition;

  const MultipleChoiceMulti({
    super.key,
    required this.question,
    required this.onResponse,
    this.response,
    required this.requiredAnswerByLogicCondition
  });

  @override
  State<MultipleChoiceMulti> createState() => _MultipleChoiceMultiState();
}

class _MultipleChoiceMultiState extends State<MultipleChoiceMulti> {
  List<String> selectedOptions = [];

  @override
  void initState() {
    super.initState();
    selectedOptions = widget.response as List<String>? ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final options = widget.question.inputConfig?['choices'] as List<dynamic>? ?? [];
    final isRequired = widget.question.required ?? false;

    return FormField<bool>(
      validator: (value) => widget.requiredAnswerByLogicCondition
        ? AppLocalizations.of(context)!.response_required
        : (isRequired && selectedOptions.isEmpty
          ? AppLocalizations.of(context)!.please_select_option
          : null),
      builder: (field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              translate(widget.question.headline, context) ?? '',
              style: theme.textTheme.headlineMedium ??
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (translate(widget.question.subheader, context)?.isNotEmpty ?? false)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  translate(widget.question.subheader, context) ?? '',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            const SizedBox(height: 16),
            ...options.map((option) {
              final optionId = option['id']?.toString();
              final label = translate(option['label'], context)?.toString() ?? '';
              final isSelected = selectedOptions.contains(optionId);

              if (optionId == null) return const SizedBox.shrink();

              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      selectedOptions.remove(optionId);
                    } else {
                      selectedOptions.add(optionId);
                    }
                    widget.onResponse(widget.question.id, selectedOptions);
                    field.didChange(true);
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected
                          ? theme.primaryColor
                          : theme.inputDecorationTheme.enabledBorder!.borderSide.color,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    color: theme.inputDecorationTheme.fillColor,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.check_box
                            : Icons.check_box_outline_blank,
                        color: isSelected
                            ? theme.primaryColor
                            : theme.unselectedWidgetColor,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          label,
                          style: theme.textTheme.bodyMedium
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
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
