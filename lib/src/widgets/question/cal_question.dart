import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../formbricks_flutter.dart';
import '../../models/question.dart';
import '../../utils/helper.dart';

/// Calendar booking input (e.g., using cal.com)
class CalQuestion extends StatefulWidget {
  final Question question;
  final Function(String, dynamic) onResponse;
  final dynamic response;

  const CalQuestion({
    super.key,
    required this.question,
    required this.onResponse,
    this.response,
  });

  @override
  State<CalQuestion> createState() => _CalQuestionState();
}

class _CalQuestionState extends State<CalQuestion> {
  bool isScheduled = false;

  @override
  void initState() {
    super.initState();
    isScheduled = widget.response == true;
  }

  Future<void> _openCalendar() async {
    final url = 'https://${widget.question.calHost ?? 'cal.com'}/${widget.question.calUserName ?? ''}';
    if (await canLaunch(url)) {
      await launch(url);
      setState(() {
        isScheduled = true;
        widget.onResponse(widget.question.id, true);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.could_not_open_calendar)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRequired = widget.question.required ?? false;

    return FormField<bool>(
      validator: (value) => isRequired && !isScheduled ? AppLocalizations.of(context)!.pls_schedule_meeting : null,
      builder: (FormFieldState<bool> field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              //widget.question.headline['default'] ?? '',
              translate(widget.question.headline, context) ?? '',
              style: theme.textTheme.headlineMedium ?? const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            //if (widget.question.subheader?['default']?.isNotEmpty ?? false)
            if (translate(widget.question.subheader, context)?.isNotEmpty ?? false)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(widget.question.subheader?['default'] ?? '', style: theme.textTheme.bodyMedium),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _openCalendar,
              child: Text(AppLocalizations.of(context)!.schedule_meeting),
            ),
            if (isScheduled)
              Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(AppLocalizations.of(context)!.meeting_scheduled, style: theme.textTheme.bodySmall,),
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