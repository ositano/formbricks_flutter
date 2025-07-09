import 'package:flutter/material.dart';

import '../../../formbricks_flutter.dart';
import '../../models/question.dart';

class ConsentQuestion extends StatefulWidget {
  final Question question;
  final Function(String, dynamic) onResponse;
  final dynamic response;

  const ConsentQuestion({
    super.key,
    required this.question,
    required this.onResponse,
    this.response,
  });

  @override
  State<ConsentQuestion> createState() => _ConsentQuestionState();
}

class _ConsentQuestionState extends State<ConsentQuestion> {
  bool consented = false;

  @override
  void initState() {
    super.initState();
    consented = widget.response as bool? ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRequired = widget.question.required ?? false;

    return FormField<bool>(
      validator: (value) => isRequired && !consented ? 'Please provide consent' : null,
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
            CheckboxListTile(
              title: Text(widget.question.label?['default'] ?? AppLocalizations.of(context)!.i_agree, style: theme.textTheme.bodyMedium),
              value: consented,
              onChanged: (value) {
                setState(() {
                  consented = value ?? false;
                  widget.onResponse(widget.question.id, consented);
                  field.didChange(true); // Validate
                });
              },
            ),
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