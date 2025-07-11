import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../models/question.dart';
import '../../utils/helper.dart';

class MultipleChoiceSingle extends StatefulWidget {
  final Question question;
  final Function(String, dynamic) onResponse;
  final dynamic response;
  final bool requiredAnswerByLogicCondition;

  const MultipleChoiceSingle({
    super.key,
    required this.question,
    required this.onResponse,
    this.response,
    required this.requiredAnswerByLogicCondition
  });

  @override
  State<MultipleChoiceSingle> createState() => _MultipleChoiceSingleState();
}

class _MultipleChoiceSingleState extends State<MultipleChoiceSingle> {
  String? selectedOption;

  @override
  void initState() {
    super.initState();
    selectedOption = widget.response as String?;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRequired = widget.question.required ?? false;
    final options = (widget.question.inputConfig?['choices'] as List?) ?? [];

    return FormField<bool>(
      validator: (_) {
        if(widget.requiredAnswerByLogicCondition) {
          return AppLocalizations.of(context)!.response_required;
        }

        if (isRequired && selectedOption == null) {
          return AppLocalizations.of(context)!.select_option;
        }
        return null;
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
            ...options.map<Widget>((option) {
              final optionId = option['id']?.toString();
              final label = translate(option['label'], context)?.toString() ?? '';

              if (optionId == null) return const SizedBox.shrink();

              final isSelected = selectedOption == optionId;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedOption = optionId;
                    widget.onResponse(widget.question.id, optionId);
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
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
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
                padding: const EdgeInsets.only(top: 8),
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
