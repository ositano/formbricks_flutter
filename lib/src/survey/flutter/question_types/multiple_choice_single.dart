import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../formbricks_flutter.dart';
import '../../../models/environment/question.dart';
import '../../../utils/helper.dart';
import '../components/formbricks_video_player.dart';

class MultipleChoiceSingleQuestion extends StatefulWidget {
  final Question question;
  final Function(String, dynamic) onResponse;
  final dynamic response;
  final bool requiredAnswerByLogicCondition;

  const MultipleChoiceSingleQuestion({
    super.key,
    required this.question,
    required this.onResponse,
    this.response,
    required this.requiredAnswerByLogicCondition
  });

  @override
  State<MultipleChoiceSingleQuestion> createState() => _MultipleChoiceSingleQuestionState();
}

class _MultipleChoiceSingleQuestionState extends State<MultipleChoiceSingleQuestion> {
  String? selectedOption;

  @override
  void initState() {
    super.initState();
    selectedOption = widget.response as String?;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRequired = widget.question.required ?? false;
    final options = widget.question.choices ?? [];

    return FormField<bool>(
      validator: (_) {
        if(widget.requiredAnswerByLogicCondition) {
          return AppLocalizations.of(context)!.response_required;
        }

        if (isRequired && selectedOption == null) {
          return AppLocalizations.of(context)!.select_option;
        }
        return null;
      },
      builder: (field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.question.imageUrl?.isNotEmpty ?? false)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: GestureDetector(child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: CachedNetworkImage(
                    imageUrl: widget.question.imageUrl!,
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
                  onTap: () => showFullScreenImage(context, widget.question.imageUrl!),
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
            if ((translate(widget.question.subheader, context) ?? '').isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  translate(widget.question.subheader, context) ?? '',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            const SizedBox(height: 16),
            ...options.map<Widget>((option) {
              final optionId = option['id']?.toString();
              final label = translate(option['label'], context)?.toString() ?? '';

              if (optionId == null) return const SizedBox.shrink();
              final isSelected = selectedOption == label;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedOption = label;
                    widget.onResponse(widget.question.id, label);
                    field.didChange(true);
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected
                          ? theme.primaryColor
                          : theme.inputDecorationTheme.enabledBorder!.borderSide.color,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(theme.extension<MyCustomTheme>()!.styleRoundness!),
                    color: theme.inputDecorationTheme.fillColor,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: isSelected
                            ? theme.primaryColor
                            : theme.unselectedWidgetColor,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          label,
                          style: theme.textTheme.bodyMedium
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            if (field.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 8),
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
