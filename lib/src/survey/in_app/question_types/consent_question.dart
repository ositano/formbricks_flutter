import 'package:flutter/material.dart';
import '../../../../formbricks_flutter.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../models/environment/question.dart';
import '../../../utils/helper.dart';
import '../components/custom_heading.dart';

class ConsentQuestion extends StatefulWidget {
  final Question question;
  final Function(String, dynamic) onResponse;
  final dynamic response;
  final bool requiredAnswerByLogicCondition;

  const ConsentQuestion({
    super.key,
    required this.question,
    required this.onResponse,
    this.response,
    required this.requiredAnswerByLogicCondition
  });

  @override
  State<ConsentQuestion> createState() => _ConsentQuestionState();
}

class _ConsentQuestionState extends State<ConsentQuestion> {
  bool consented = false;

  @override
  void initState() {
    super.initState();
    consented = (widget.response as String?) == "accepted" ? true : false;
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
      validator: (value) => isRequired && !consented ? AppLocalizations.of(context)!.please_provide_consent : null,
      builder: (FormFieldState<bool> field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomHeading(question: widget.question, required: isRequired),
            GestureDetector(
              onTap: () {
                setState(() {
                  consented = !consented;
                  widget.onResponse(widget.question.id, consented ? "accepted" : "dismissed");
                  field.didChange(true);
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12,),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: theme.inputDecorationTheme.enabledBorder!.borderSide.color,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  color: theme.inputDecorationTheme.fillColor,
                ),
                child: Row(
                  children: [
                    Checkbox(
                      value: consented,
                      //checkColor: theme.primaryColor,
                      fillColor: consented ? WidgetStateProperty.all(theme.primaryColor) : null,
                      onChanged: (value) {
                        setState(() {
                          consented = value ?? false;
                          widget.onResponse(widget.question.id, consented ? "accepted" : "dismissed");
                          field.didChange(true);
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        translate(widget.question.label, context) ??
                            AppLocalizations.of(context)!.i_agree,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),

                  ],
                ),
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
