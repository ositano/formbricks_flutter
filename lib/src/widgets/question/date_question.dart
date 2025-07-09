import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../formbricks_flutter.dart';
import '../../models/question.dart';
import '../../utils/helper.dart';

class DateQuestion extends StatefulWidget {
  final Question question;
  final Function(String, dynamic) onResponse;
  final dynamic response;

  const DateQuestion({
    super.key,
    required this.question,
    required this.onResponse,
    this.response,
  });

  @override
  State<DateQuestion> createState() => _DateQuestionState();
}

class _DateQuestionState extends State<DateQuestion> {
  DateTime? selectedDate;
  late final DateFormat formatter;
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    formatter = DateFormat(widget.question.format ?? 'yyyy-MM-dd');
    selectedDate = _parseDate(widget.response);
    _controller = TextEditingController(text: widget.response);
  }

  @override
  void didUpdateWidget(covariant DateQuestion oldWidget) {
    super.didUpdateWidget(oldWidget);

    final newDate = _parseDate(widget.response);
    if (newDate != null && newDate != selectedDate) {
      selectedDate = newDate;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _controller.text = formatter.format(newDate);
        }
      });
    }
  }

  DateTime? _parseDate(dynamic input) {
    if (input is DateTime) return input;
    if (input is String && input.isNotEmpty) {
      try {
        return DateFormat(
          widget.question.format ?? 'yyyy-MM-dd',
        ).parseStrict(input);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  Future<void> _pickDate(FormFieldState<bool> field) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (picked != null && mounted) {
      setState(() {
        selectedDate = picked;
        _controller.text = formatter.format(picked);
      });

      widget.onResponse(widget.question.id, formatter.format(picked));
      field.didChange(true); // only trigger after valid input
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final q = widget.question;
    final isRequired = q.required ?? false;

    return FormField<bool>(
      key: ValueKey(q.id),
      initialValue: selectedDate != null,
      validator: (_) => isRequired && selectedDate == null
          ? AppLocalizations.of(context)!.please_select_date
          : null,
      builder: (field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              //q.headline['default'] ?? '',
              translate(q.headline, context) ?? '',
              style:
                  theme.textTheme.headlineMedium ??
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            //if (q.subheader?['default']?.isNotEmpty ?? false)
            if (translate(q.subheader, context)?.isNotEmpty ?? false)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  //q.subheader!['default']!,
                  translate(q.subheader, context) ?? "",
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            const SizedBox(height: 16),
            TextFormField(
              readOnly: true,
              controller: _controller,
              onTap: () => _pickDate(field),
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.select_date,
                border: const OutlineInputBorder(),
                suffixIcon: const Icon(Icons.calendar_today),
                //errorText: field.hasError ? field.errorText : null,
              ),
              style: theme.textTheme.bodyMedium,
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
