
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../formbricks_flutter.dart';
import '../../../utils/helper.dart';
import '../components/custom_heading.dart';

class CTAQuestion extends StatefulWidget {
  final Question question;
  final Function(String, dynamic) onResponse;
  final dynamic response;
  final bool requiredAnswerByLogicCondition;

  const CTAQuestion({
    super.key,
    required this.question,
    required this.onResponse,
    this.response,
    required this.requiredAnswerByLogicCondition,
  });

  @override
  State<CTAQuestion> createState() => _CTAQuestionState();
}

class _CTAQuestionState extends State<CTAQuestion> {
  bool performedAction = false;

  @override
  void initState() {
    super.initState();
    performedAction = (widget.response as String?) == "clicked" ? true : false;
  }

  Future<void> _openLink() async {
    final url = widget.question.buttonUrl!;
    if (await launchUrl(Uri.parse(url))) {
      setState(() {
        performedAction = true;
        widget.onResponse(widget.question.id, performedAction ? "clicked" : "dismissed");
      });
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
      validator: (value) => isRequired && value != true
                ? AppLocalizations.of(context)!.please_take_action
                : null,
      builder: (FormFieldState<bool> field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomHeading(question: widget.question, required: isRequired),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _openLink();
                    field.didChange(true); // Validate
                  },
                  child: Text(
                    translate(widget.question.buttonLabel, context) ??
                        AppLocalizations.of(context)!.action,
                  ),
                ),
                if (widget.question.dismissButtonLabel?['default'] != null)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        performedAction = true;
                        widget.onResponse(widget.question.id, performedAction ? "clicked" : "dismissed");
                      });
                      field.didChange(true);
                      //Navigator.of(context).pop(); // Skip and close
                    },
                    child: Text(
                      translate(widget.question.dismissButtonLabel, context) ??
                          AppLocalizations.of(context)!.skip,
                    ),
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
