import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../formbricks_flutter.dart';
import '../../../utils/helper.dart';
import '../../../utils/theme_manager.dart';
import '../components/custom_heading.dart';

class PictureSelectionQuestion extends StatefulWidget {
  final Question question;
  final Function(String, dynamic) onResponse;
  final dynamic response;
  final bool requiredAnswerByLogicCondition;

  const PictureSelectionQuestion({
    super.key,
    required this.question,
    required this.onResponse,
    this.response,
    required this.requiredAnswerByLogicCondition,
  });

  @override
  State<PictureSelectionQuestion> createState() =>
      _PictureSelectionQuestionState();
}

class _PictureSelectionQuestionState extends State<PictureSelectionQuestion> {
  late List<String> selectedImages;

  @override
  void initState() {
    super.initState();
    selectedImages = widget.response as List<String>? ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final choices = widget.question.choices ?? [];
    final isMulti = widget.question.allowMulti ?? false;
    bool isRequired = widget.question.required ?? false;
    if (widget.requiredAnswerByLogicCondition) {
      isRequired = widget.requiredAnswerByLogicCondition;
    }

    return FormField<bool>(
      key: ValueKey(widget.question.id),
      validator: (_) => isRequired == true && selectedImages.isEmpty
          ? AppLocalizations.of(context)!.please_select_option
          : null,
      builder: (FormFieldState<bool> field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomHeading(question: widget.question, required: isRequired),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: choices.map((choice) {
                final imageId = choice['id'] as String;
                final imageUrl = choice['imageUrl'] as String;
                final isSelected = selectedImages.contains(imageId);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isMulti) {
                        isSelected
                            ? selectedImages.remove(imageId)
                            : selectedImages.add(imageId);
                      } else {
                        selectedImages = [imageId];
                      }
                      widget.onResponse(widget.question.id, selectedImages);
                      field.didChange(true);
                    });
                  },
                  onDoubleTap: () => showFullScreenImage(context, imageUrl),
                  child: Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected
                                ? theme.primaryColor
                                : theme.inputDecorationTheme.enabledBorder != null ? theme
                                      .inputDecorationTheme
                                      .enabledBorder!
                                      .borderSide
                                      .color : theme.unselectedWidgetColor,
                            width: isSelected ? 3 : 0,
                          ),
                          borderRadius: BorderRadius.circular(theme.extension<MyCustomTheme>()?.styleRoundness ?? 8.0),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(theme.extension<MyCustomTheme>()?.styleRoundness ?? 8.0),
                          child: CachedNetworkImage(
                            imageUrl: imageUrl,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Icon(
                          isMulti
                              ? Icons.check_circle
                              : (isSelected
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_unchecked),
                          size: 20,
                          color: isSelected
                              ? theme.primaryColor
                              : theme.unselectedWidgetColor,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
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
