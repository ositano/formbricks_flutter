import 'package:flutter/material.dart';

import '../../../formbricks_flutter.dart';
import '../../models/question.dart';

class NPSQuestion extends StatefulWidget {
  final Question question;
  final Function(String, dynamic) onResponse;
  final dynamic response;

  const NPSQuestion({
    super.key,
    required this.question,
    required this.onResponse,
    this.response,
  });

  @override
  State<NPSQuestion> createState() => _NPSQuestionState();
}

class _NPSQuestionState extends State<NPSQuestion> {
  int? selectedIndex;
  bool _hasInteracted = false;


  @override
  void initState() {
    super.initState();
    selectedIndex = widget.response as int?;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRequired = widget.question.required ?? false;

    return FormField<int>(
      autovalidateMode: _hasInteracted
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
      validator: (value) {
        if (_hasInteracted && isRequired && value == null) {
          return AppLocalizations.of(context)!.please_select_score;
        }
        return null;
      },
      builder: (FormFieldState<int> field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.question.headline['default'] ?? '',
              style: theme.textTheme.headlineMedium ??
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (widget.question.subheader?['default']?.isNotEmpty ?? false)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  widget.question.subheader!['default'] ?? '',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 8.0,
              children: List.generate(11, (index) {
                return ChoiceChip(
                  label: Text('$index'),
                  selected: selectedIndex == index,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        selectedIndex = index;
                        _hasInteracted = true;
                      });
                      field.didChange(index);
                      widget.onResponse(widget.question.id, index);

                      final formState = context.findAncestorStateOfType<SurveyWidgetState>()?.formKey.currentState;
                      if (formState?.validate() ?? false) {
                        context.findAncestorStateOfType<SurveyWidgetState>()?.nextStep();
                      }
                    }
                  },
                  selectedColor: theme.primaryColor,
                  labelStyle: TextStyle(
                    color: selectedIndex == index
                        ? Colors.white
                        : theme.textTheme.bodyMedium?.color,
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (widget.question.lowerLabel != null)
                  Text(
                    widget.question.lowerLabel!['default'] ?? '',
                    style: theme.textTheme.bodySmall,
                  ),
                if (widget.question.upperLabel != null)
                  Text(
                    widget.question.upperLabel!['default'] ?? '',
                    style: theme.textTheme.bodySmall,
                  ),
              ],
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
