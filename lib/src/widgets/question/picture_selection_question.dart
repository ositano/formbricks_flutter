import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../models/question.dart';
import '../../utils/helper.dart';

/// Choose one or more images from a set
class PictureSelectionQuestion extends StatefulWidget {
  final Question question;
  final Function(String, dynamic) onResponse;
  final dynamic response;

  const PictureSelectionQuestion({
    super.key,
    required this.question,
    required this.onResponse,
    this.response,
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

  void _showFullScreenImage(String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              Center(
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, url) =>
                      const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) =>
                      const Center(child: Icon(Icons.error)),
                ),
              ),
              Positioned(
                top: 40,
                left: 10,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final choices = widget.question.choices ?? [];
    final isMulti = widget.question.allowMulti ?? false;
    return FormField<bool>(
      validator: (value) => widget.question.required == true && selectedImages.isEmpty ? AppLocalizations.of(context)!.please_select_option : null,
      builder: (FormFieldState<bool> field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              //widget.question.headline['default'] ?? '',
              translate(widget.question.headline, context) ?? '',
              style:
                  theme.textTheme.headlineMedium ??
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (widget.question.subheader?['default']?.isNotEmpty ?? false)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  //widget.question.subheader?['default'] ?? '',
                  translate(widget.question.subheader, context) ?? '',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: choices.map((choice) {
                final imageId = choice['id'] as String;
                final imageUrl = choice['imageUrl'] as String;
                final isSelected = selectedImages.contains(imageId);
                //print('Rendering image: $imageUrl, selected: $isSelected');
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isMulti) {
                        if (isSelected) {
                          selectedImages.remove(imageId);
                        } else {
                          selectedImages.add(imageId);
                        }
                      } else {
                        selectedImages = [imageId];
                      }
                      //print('Selected images: $selectedImages');
                      widget.onResponse(widget.question.id, selectedImages);
                    });
                  },
                  onDoubleTap: () => _showFullScreenImage(imageUrl),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected
                            ? theme.primaryColor
                            : Colors.transparent,
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => SizedBox(
                        width: 20,
                        height: 20,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) {
                        //print('Image load error for $url: $error');
                        return const Icon(Icons.error);
                      },
                    ),
                  ),
                );
              }).toList(),
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
