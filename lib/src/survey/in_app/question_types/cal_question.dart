import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../formbricks_flutter.dart';
import '../../../utils/logger.dart';
import '../components/custom_heading.dart';

/// Calendar booking input (e.g., using cal.com)
class CalQuestion extends StatefulWidget {
  final Question question;
  final Function(String, dynamic) onResponse;
  final dynamic response;
  final bool requiredAnswerByLogicCondition;

  const CalQuestion({
    super.key,
    required this.question,
    required this.onResponse,
    this.response,
    required this.requiredAnswerByLogicCondition,
  });

  @override
  State<CalQuestion> createState() => _CalQuestionState();
}

class _CalQuestionState extends State<CalQuestion> {
  bool isScheduled = false;

  @override
  void initState() {
    super.initState();
    isScheduled = (widget.response as String?) == "booked" ? true : false;
  }

  Future<void> _openCalendar() async {
    final url =
        'https://${widget.question.calHost ?? 'cal.com'}/${widget.question.calUserName ?? ''}';
    if (await launchUrl(Uri.parse(url))) {
      setState(() {
        isScheduled = true;
        widget.onResponse(widget.question.id, isScheduled ? "booked" : "dismissed");
      });
    } else {
      // Check if the widget is still mounted before using context
      if (context.mounted) {
        return; // Widget is no longer in the tree, so don't use context
      }
      Log.instance.d(AppLocalizations.of(context)!.could_not_open_calendar);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    bool isRequired = widget.question.required ?? false;
    if(widget.requiredAnswerByLogicCondition){
      isRequired = widget.requiredAnswerByLogicCondition;
    }

    return FormField<bool>(
      key: ValueKey(widget.question.id),
      validator: (value) => isRequired && !isScheduled
                ? AppLocalizations.of(context)!.pls_schedule_meeting
                : null,
      builder: (FormFieldState<bool> field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomHeading(question: widget.question, required: isRequired),
            ElevatedButton(
              onPressed: _openCalendar,
              child: Text(AppLocalizations.of(context)!.schedule_meeting),
            ),
            if (isScheduled)
              Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  AppLocalizations.of(context)!.meeting_scheduled,
                  style: theme.textTheme.bodySmall,
                ),
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
