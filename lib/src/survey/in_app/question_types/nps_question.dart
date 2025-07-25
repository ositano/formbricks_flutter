import 'package:flutter/material.dart';
import '../../../../formbricks_flutter.dart';
import '../../../utils/helper.dart';
import '../../../utils/theme_manager.dart';
import '../components/custom_heading.dart';
import '../survey_widget.dart';


class NPSQuestion extends StatefulWidget {
  final Question question;
  final Function(String, dynamic) onResponse;
  final dynamic response;
  final bool requiredAnswerByLogicCondition;

  const NPSQuestion({
    super.key,
    required this.question,
    required this.onResponse,
    this.response,
    required this.requiredAnswerByLogicCondition
  });

  @override
  State<NPSQuestion> createState() => _NPSQuestionState();
}

class _NPSQuestionState extends State<NPSQuestion> {
  int? selectedIndex;
  bool _hasInteracted = false;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.response as int?;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    bool isRequired = widget.question.required ?? false;
    if(widget.requiredAnswerByLogicCondition){
      isRequired = widget.requiredAnswerByLogicCondition;
    }
    return FormField<int>(
      key: ValueKey(widget.question.id),
      autovalidateMode: _hasInteracted
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
      validator: (value) {
        if (_hasInteracted && isRequired && value == null) {
          return AppLocalizations.of(context)!.please_select_score;
        }
        return null;
      },
      builder: (FormFieldState<int> field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomHeading(question: widget.question, required: isRequired),
            const SizedBox(height: 8),
            // 2D Grid of NPS choices (0–10)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(11, (index) {
                  final isSelected = selectedIndex == index;

                  BorderRadius borderRadius = BorderRadius.zero;
                  if (index == 0) {
                    borderRadius = BorderRadius.only(
                      topLeft: Radius.circular(theme.extension<MyCustomTheme>()!.styleRoundness!),
                      bottomLeft: Radius.circular(theme.extension<MyCustomTheme>()!.styleRoundness!),
                    );
                  } else if (index == 10) {
                    borderRadius = BorderRadius.only(
                      topRight: Radius.circular(theme.extension<MyCustomTheme>()!.styleRoundness!),
                      bottomRight: Radius.circular(theme.extension<MyCustomTheme>()!.styleRoundness!),
                    );
                  }

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                        _hasInteracted = true;
                      });
                      field.didChange(index);
                      widget.onResponse(widget.question.id, index);

                      final formState = context.findAncestorStateOfType<SurveyWidgetState>()?.formKey.currentState;
                      if (formState?.validate() ?? false) {
                        context.findAncestorStateOfType<SurveyWidgetState>()?.nextStep();
                      }
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected ? theme.primaryColor : Colors.transparent,
                        border: Border.all(
                          color: theme.primaryColor,
                          width: 1,
                        ),
                        borderRadius: borderRadius,
                      ),
                      child: Text(
                        '$index',
                        style: TextStyle(
                          color: isSelected ? Colors.white : theme.textTheme.bodyMedium?.color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (widget.question.lowerLabel != null)
                  Text(
                    translate(widget.question.lowerLabel, context) ?? '',
                    style: theme.textTheme.bodySmall,
                  ),
                if (widget.question.upperLabel != null)
                  Text(
                    translate(widget.question.upperLabel, context) ?? '',
                    style: theme.textTheme.bodySmall,
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
