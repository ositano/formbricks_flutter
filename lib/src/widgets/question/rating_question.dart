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
    selectedRating = (widget.response as int?)?.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final range = int.tryParse(widget.question.inputConfig?['range']?.toString() ?? '') ?? 5;
    final scale = widget.question.inputConfig?['scale'] ?? 'star';
    final isRequired = widget.question.required ?? false;

    return FormField<double>(
      validator: (value) => isRequired && (selectedRating == null || selectedRating == 0)
          ? AppLocalizations.of(context)!.please_select_rating
          : null,
      builder: (FormFieldState<double> field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              widget.question.headline['default'] ?? '',
              style: theme.textTheme.headlineMedium ??
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (widget.question.subheader?['default']?.isNotEmpty ?? false)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  widget.question.subheader!['default'] ?? '',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            const SizedBox(height: 16),
            RatingBar.builder(
              initialRating: selectedRating ?? 0,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: false,
              itemCount: range,
              itemPadding: const EdgeInsets.symmetric(horizontal: 8.0),
              itemSize: 50.0,
              itemBuilder: (context, index) => scale == 'star'
                  ? Icon(Icons.star, color: theme.primaryColor)
                  : Text(
                (index + 1).toString(),
                style: TextStyle(color: theme.primaryColor),
              ),
              onRatingUpdate: (rating) {
                setState(() {
                  selectedRating = rating;
                });
                field.didChange(rating);
                widget.onResponse(widget.question.id, rating.toInt());

                // Proceed to next step if valid
                final formState = context.findAncestorStateOfType<SurveyWidgetState>()?.formKey.currentState;
                if (formState?.validate() ?? false) {
                  context.findAncestorStateOfType<SurveyWidgetState>()?.nextStep();
                }
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
