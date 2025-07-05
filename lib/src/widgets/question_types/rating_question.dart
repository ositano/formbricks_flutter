import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../../../formbricks_flutter.dart';
import '../../models/question.dart';


class RatingQuestion extends StatefulWidget {
  final Question question;
  final Function(String, dynamic) onResponse;
  final dynamic response;

  const RatingQuestion({
    super.key,
    required this.question,
    required this.onResponse,
    this.response,
  });

  @override
  State<RatingQuestion> createState() => _RatingQuestionState();
}

class _RatingQuestionState extends State<RatingQuestion> {
  double? selectedRating;

  @override
  void initState() {
    super.initState();
    selectedRating = (widget.response as int? ?? 0).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final range = widget.question.inputConfig?['range'] ?? 5;
    final scale = widget.question.inputConfig?['scale'] ?? 'star';
    final isRequired = widget.question.required ?? false;

    return FormField<bool>(
      validator: (value) => isRequired && selectedRating == null ? 'Please select a rating' : null,
      builder: (FormFieldState<bool> field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              widget.question.headline['default'] ?? '',
              style: theme.textTheme.headlineMedium ?? const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (widget.question.subheader?['default']?.isNotEmpty ?? false)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  widget.question.subheader?['default'] ?? '',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            const SizedBox(height: 16),
            const SizedBox(height: 8),
            RatingBar.builder(
              initialRating: selectedRating ?? 0,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: false,
              itemCount: range,
              itemPadding: const EdgeInsets.symmetric(horizontal: 8.0),
              itemSize: 60.0,
              itemBuilder: (context, index) => scale == 'star'
                  ? Icon(Icons.star, color: theme.primaryColor)
                  : Text((index + 1).toString(), style: TextStyle(color: theme.primaryColor)),
              onRatingUpdate: (rating) {
                setState(() {
                  selectedRating = rating;
                  widget.onResponse(widget.question.id, rating.toInt());
                  if (context.findAncestorStateOfType<SurveyWidgetState>()?.formKey.currentState?.validate() ?? false) {
                    context.findAncestorStateOfType<SurveyWidgetState>()?.nextStep();
                  }
                });
                field.didChange(true);
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (widget.question.lowerLabel != null)
                  Text(
                    widget.question.lowerLabel!['default'] ?? '',
                    style: theme.textTheme.bodySmall,
                  ),
                const Spacer(),
                if (widget.question.upperLabel != null)
                  Text(
                    widget.question.upperLabel!['default'] ?? '',
                    style: theme.textTheme.bodySmall,
                  ),
              ],
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