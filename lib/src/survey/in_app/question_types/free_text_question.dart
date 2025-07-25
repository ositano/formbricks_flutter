
import 'package:flutter/material.dart';
import '../../../../formbricks_flutter.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../models/environment/question.dart';
import '../../../utils/helper.dart';
import '../components/custom_heading.dart';

class FreeTextQuestion extends StatefulWidget {
  final Question question;
  final Function(String, dynamic) onResponse;
  final dynamic response;
  final bool requiredAnswerByLogicCondition;

  const FreeTextQuestion({
    super.key,
    required this.question,
    required this.onResponse,
    this.response,
    required this.requiredAnswerByLogicCondition,
  });

  @override
  State<FreeTextQuestion> createState() => _FreeTextQuestionState();
}

class _FreeTextQuestionState extends State<FreeTextQuestion> {
  late TextEditingController _controller;
  late String _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.response is String ? widget.response as String : '';
    _controller = TextEditingController(text: _currentValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant FreeTextQuestion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.response != oldWidget.response) {
      _controller.text = widget.response;
      _currentValue = widget.response;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final question = widget.question;
    bool isRequired = question.required ?? false;
    if(widget.requiredAnswerByLogicCondition){
      isRequired = widget.requiredAnswerByLogicCondition;
    }
    final charLimit = question.charLimit;
    final hasCharLimit = charLimit?['enabled'] ?? false;
    final maxChars = charLimit?['max'];
    final minChars = charLimit?['min'];

    return FormField<bool>(
      key: ValueKey(question.id),
      initialValue: _currentValue.isNotEmpty,
      validator: (state) {
        if (!(isRequired)) return null;

        if (isRequired && _controller.text.trim().isEmpty) {
          return AppLocalizations.of(context)!.field_is_required;
        }

        if (hasCharLimit) {
          final min = int.tryParse(minChars ?? '');
          final max = int.tryParse(maxChars ?? '');

          if (min != null && _controller.text.trim().length < min) {
            return '${AppLocalizations.of(context)!.min_character_required}: $min';
          }

          if (max != null && _controller.text.trim().length > max) {
            return '${AppLocalizations.of(context)!.max_character_required}: $max';
          }
        }
        return null;
      },
      builder: (field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomHeading(question: widget.question, required: isRequired),
            TextFormField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: translate(question.placeholder, context) ?? AppLocalizations.of(context)!.type_answer_here,
                labelStyle: theme.textTheme.bodyMedium,
              ),
              maxLines: question.longAnswer == true ? null : 1,
              minLines: question.longAnswer == true ? 3 : 1,
              maxLength: hasCharLimit ? int.tryParse(maxChars ?? '0') : null,
              keyboardType:
                  {
                    'number': TextInputType.number,
                    'phone': TextInputType.phone,
                    'email': TextInputType.emailAddress,
                  }[question.inputType] ??
                  TextInputType.text,
              textInputAction: TextInputAction.next,
              onChanged: (value) {
                _currentValue = value;
                widget.onResponse(widget.question.id, value.trim());
                field.didChange;
              },
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
