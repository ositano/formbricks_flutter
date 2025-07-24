import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../formbricks_flutter.dart';
import '../../../models/environment/question.dart';
import '../../../utils/helper.dart';
import '../components/formbricks_video_player.dart';

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
    final isRequired = question.required ?? false;
    final charLimit = question.charLimit;
    final hasCharLimit = charLimit?['enabled'] ?? false;
    final maxChars = charLimit?['max'];
    final minChars = charLimit?['min'];

    return FormField<bool>(
      key: ValueKey(question.id),
      initialValue: _currentValue.isNotEmpty,
      validator: (state) {
        if(widget.requiredAnswerByLogicCondition) {
          return AppLocalizations.of(context)!.response_required;
        }

        if (!(question.required ?? false)) return null;

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
            if (question.imageUrl?.isNotEmpty ?? false)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: GestureDetector(child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: CachedNetworkImage(
                    imageUrl: question.imageUrl!,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(
                        child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator())),
                    errorWidget: (context, url, error) =>
                    const Icon(Icons.error),
                  ),
                ),
                  onTap: () => showFullScreenImage(context, question.imageUrl!),
                ),
              )
            else if (widget.question.videoUrl?.isNotEmpty ?? false)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                    theme.extension<MyCustomTheme>()!.styleRoundness!,
                  ),
                  child: FormbricksVideoPlayer(videoUrl: widget.question.videoUrl!,),
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Text(
                  translate(widget.question.headline, context) ?? '',
                  style: theme.textTheme.headlineMedium ??
                      const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                ),
                widget.question.required == true || widget.requiredAnswerByLogicCondition == true ? const SizedBox.shrink() :
                Text(
                  AppLocalizations.of(context)!.optional,
                  textAlign: TextAlign.end,
                  style: theme.textTheme.headlineSmall ??
                      const TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
                ),
              ],
            ),
            if (translate(question.subheader, context)?.isNotEmpty ?? false)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  translate(question.subheader, context) ?? '',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            const SizedBox(height: 16),
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
