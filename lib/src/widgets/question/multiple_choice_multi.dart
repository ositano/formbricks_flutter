import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../models/question.dart';

class MultipleChoiceMulti extends StatefulWidget {
  final Question question;
  final Function(String, dynamic) onResponse;
  final dynamic response;

  const MultipleChoiceMulti({
    super.key,
    required this.question,
    required this.onResponse,
    this.response,
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
      validator: (value) => isRequired && selectedOptions.isEmpty ? AppLocalizations.of(context)!.please_select_option : null,
      builder: (FormFieldState<bool> field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.question.headline['default'] ?? '', style: theme.textTheme.headlineMedium ?? const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            if (widget.question.subheader?['default']?.isNotEmpty ?? false)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(widget.question.subheader?['default'] ?? '', style: theme.textTheme.bodyMedium),
              ),
            const SizedBox(height: 16),
            ...options.map((option) => CheckboxListTile(
              title: Text(option['label']['default'] ?? '', style: theme.textTheme.bodyMedium),
              value: selectedOptions.contains(option['id']),
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    selectedOptions.add(option['id']);
                  } else {
                    selectedOptions.remove(option['id']);
                  }
                  widget.onResponse(widget.question.id, selectedOptions);
                  field.didChange(true); // Validate
                });
              },
            )),
            if (field.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(field.errorText!, style: TextStyle(color: theme.colorScheme.error)),
              ),
          ],
        );
      },
    );
  }
}