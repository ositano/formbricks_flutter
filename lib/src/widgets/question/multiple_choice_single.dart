import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../models/question.dart';

class MultipleChoiceSingle extends StatefulWidget {
  final Question question;
  final Function(String, dynamic) onResponse;
  final dynamic response;

  const MultipleChoiceSingle({
    super.key,
    required this.question,
    required this.onResponse,
    this.response,
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
      validator: (value) {
        if (isRequired && selectedOption == null) {
          return AppLocalizations.of(context)!.select_option;
        }
        return null;
      },
      builder: (FormFieldState<bool> field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.question.headline['default'] ?? '',
              style: theme.textTheme.headlineMedium ??
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if ((widget.question.subheader?['default'] ?? '').isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  widget.question.subheader!['default']!,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            const SizedBox(height: 16),
            ...options.map<Widget>((option) {
              final optionId = option['id']?.toString();
              final label = option['label']?['default']?.toString() ?? '';

              if (optionId == null) return const SizedBox.shrink();

              return RadioListTile<String>(
                title: Text(label, style: theme.textTheme.bodyMedium),
                value: optionId,
                groupValue: selectedOption,
                onChanged: (value) {
                  setState(() {
                    selectedOption = value;
                    widget.onResponse(widget.question.id, value);
                    field.didChange(true); // Trigger validation
                  });
                },
                contentPadding: EdgeInsets.zero,
                dense: true,
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
