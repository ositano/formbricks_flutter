import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../models/question.dart';

/// Choose one or more images from a set
class PictureSelectionQuestion extends StatefulWidget {
  final Question question;
  final Function(String, dynamic) onResponse;

  const PictureSelectionQuestion({
    super.key,
    required this.question,
    required this.onResponse,
  });

  @override
  State<PictureSelectionQuestion> createState() => _PictureSelectionQuestionState();
}

class _PictureSelectionQuestionState extends State<PictureSelectionQuestion> {
  List<String> selectedImages = [];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final images = widget.question.inputConfig?['images'] as List<dynamic>? ?? [];
    final isMulti = widget.question.inputConfig?['allowMulti'] ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.question.headline['default'] ?? '', style: theme.textTheme.headlineMedium ?? const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        if (widget.question.subheader['default']?.isNotEmpty ?? false)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(widget.question.subheader['default'] ?? '', style: theme.textTheme.bodyMedium,),
          ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: images.map((image) {
            final imageId = image['id'];
            final isSelected = selectedImages.contains(imageId);
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
                  widget.onResponse(widget.question.id, isMulti ? selectedImages : imageId);
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: isSelected ? Colors.blue : Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CachedNetworkImage(
                  imageUrl: image['url'],
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}