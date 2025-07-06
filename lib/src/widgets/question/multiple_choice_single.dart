import 'package:flutter/material.dart';

import '../../models/question.dart';

class MultipleChoiceSingle extends StatefulWidget {
  final Question question;
  final Function(String, dynamic) onResponse;
  final dynamic response;

  const MultipleChoiceSingle({
    super.key,
    required this.question,
    required this.onResponse,
    this.response
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
    final options = widget.question.inputConfig?['choices'] as List<dynamic>? ?? [];
    final isRequired = widget.question.required ?? false;

    return FormField<bool>(
      validator: (value) => isRequired && selectedOption == null ? 'Please select an option' : null,
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
            ...options.map((option) => RadioListTile<String>(
              title: Text(option['label']['default'] ?? '', style: theme.textTheme.bodyMedium),
              value: option['id'],
              groupValue: selectedOption,
              onChanged: (value) {
                setState(() {
                  selectedOption = value;
                  widget.onResponse(widget.question.id, value);
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