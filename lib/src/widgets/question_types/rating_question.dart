import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../../models/question.dart';

/// Numeric or star-based rating (e.g., 1–5 stars).
class RatingQuestion extends StatelessWidget {
  final Question question;
  final Function(String, dynamic) onResponse;

  const RatingQuestion({
    super.key,
    required this.question,
    required this.onResponse,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final range = question.inputConfig?['range'] ?? 5;
    final scale = question.inputConfig?['scale'] ?? 'star';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question.headline['default'] ?? '',
          style: theme.textTheme.headlineMedium ?? const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        if (question.subheader['default']?.isNotEmpty ?? false)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              question.subheader['default'] ?? '',
              style: theme.textTheme.bodyMedium,
            ),
          ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (question.lowerLabel != null)
              Text(
                question.lowerLabel!['default'] ?? '',
                style: theme.textTheme.bodySmall,
              ),
            const Spacer(),
            if (question.upperLabel != null)
              Text(
                question.upperLabel!['default'] ?? '',
                style: theme.textTheme.bodySmall,
              ),
          ],
        ),
        const SizedBox(height: 8),
        RatingBar.builder(
          initialRating: 0,
          minRating: 1,
          direction: Axis.horizontal,
          allowHalfRating: false,
          itemCount: range,
          itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
          itemBuilder: (context, index) => scale == 'star'
              ? Icon(Icons.star, color: theme.primaryColor)
              : Text((index + 1).toString(), style: TextStyle(color: theme.primaryColor),),
          onRatingUpdate: (rating) {
            onResponse(question.id, rating.toInt());
          },
        ),
      ],
    );
  }
}