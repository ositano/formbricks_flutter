import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

import '../../models/question.dart';

class CTAQuestion extends StatefulWidget {
  final Question question;
  final Function(String, dynamic) onResponse;
  final dynamic response;

  const CTAQuestion({
    super.key,
    required this.question,
    required this.onResponse,
    this.response
  });

  @override
  State<CTAQuestion> createState() => _CTAQuestionState();
}

class _CTAQuestionState extends State<CTAQuestion> {
  bool performedAction = false;

  @override
  void initState() {
    super.initState();
    performedAction = widget.response as bool? ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRequired = widget.question.required ?? false;

    return FormField<bool>(
      validator: (value) => isRequired && value != true ? 'Please take action' : null,
      builder: (FormFieldState<bool> field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.question.headline['default'] ?? '', style: theme.textTheme.headlineMedium ?? const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            if (widget.question.html?['default']?.isNotEmpty ?? false)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: HtmlWidget(widget.question.html!['default'] ?? ''),
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    widget.onResponse(widget.question.id, true);
                    field.didChange(true); // Validate
                  },
                  child: Text(widget.question.buttonLabel?['default'] ?? 'Action'),
                ),
                if (widget.question.dismissButtonLabel?['default'] != null)
                  TextButton(
                    onPressed: () {
                      widget.onResponse(widget.question.id, false);
                      Navigator.of(context).pop(); // Skip and close
                    },
                    child: Text(widget.question.dismissButtonLabel!['default'] ?? 'Skip'),
                  ),
              ],
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