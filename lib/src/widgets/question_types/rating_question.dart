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
    final maxRating = (question.inputConfig?['range'] as int?) ?? 5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(question.headline, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        if (question.subheader.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(question.subheader),
          ),
        const SizedBox(height: 16),
        RatingBar.builder(
          initialRating: 0,
          minRating: 0,
          direction: Axis.horizontal,
          allowHalfRating: false,
          itemCount: maxRating,
          itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
          onRatingUpdate: (rating) => onResponse(question.id, rating.toInt()),
        ),
      ],
    );
  }
}