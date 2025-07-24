import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../formbricks_flutter.dart';
import '../../../models/environment/question.dart';
import '../../../utils/helper.dart';
import '../components/formbricks_video_player.dart';

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
    final isRequired = widget.question.required ?? false;

    return FormField<int>(
      autovalidateMode: _hasInteracted
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
      validator: (value) {
        if(widget.requiredAnswerByLogicCondition) {
          return AppLocalizations.of(context)!.response_required;
        }

        if (_hasInteracted && isRequired && value == null) {
          return AppLocalizations.of(context)!.please_select_score;
        }
        return null;
      },
      builder: (FormFieldState<int> field) {
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
            if (translate(widget.question.subheader, context)?.isNotEmpty ?? false)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  translate(widget.question.subheader, context) ?? '',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            const SizedBox(height: 24),

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


            // Container(
            //   alignment: Alignment.center,
            //   child: Wrap(
            //   spacing: 2.0,
            //   runSpacing: 8.0,
            //   children: List.generate(11, (index) {
            //     final isSelected = selectedIndex == index;
            //     return GestureDetector(
            //       onTap: () {
            //         setState(() {
            //           selectedIndex = index;
            //           _hasInteracted = true;
            //         });
            //         field.didChange(index);
            //         widget.onResponse(widget.question.id, index);
            //
            //         final formState = context.findAncestorStateOfType<SurveyWidgetState>()?.formKey.currentState;
            //         if (formState?.validate() ?? false) {
            //           context.findAncestorStateOfType<SurveyWidgetState>()?.nextStep();
            //         }
            //       },
            //       child: Container(
            //         width: 30,
            //         height: 30,
            //         alignment: Alignment.center,
            //         decoration: BoxDecoration(
            //           color: isSelected ? theme.primaryColor : Colors.transparent,
            //           border: Border.all(color: isSelected ? theme.primaryColor : Colors.grey),
            //           borderRadius: BorderRadius.circular(6),
            //         ),
            //         child: Text(
            //           '$index',
            //           style: TextStyle(
            //             color: isSelected ? Colors.white : theme.textTheme.bodyMedium?.color,
            //             fontWeight: FontWeight.w500,
            //           ),
            //         ),
            //       ),
            //     );
            //   }),
            // ),
            // ),



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
