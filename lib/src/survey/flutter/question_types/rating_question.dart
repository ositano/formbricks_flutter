import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

import '../../../../formbricks_flutter.dart';
import '../../../models/environment/question.dart';
import '../../../utils/helper.dart';
import '../components/formbricks_video_player.dart';

class RatingQuestion extends StatefulWidget {
  final Question question;
  final Function(String, dynamic) onResponse;
  final dynamic response;
  final bool requiredAnswerByLogicCondition;

  const RatingQuestion({
    super.key,
    required this.question,
    required this.onResponse,
    this.response,
    required this.requiredAnswerByLogicCondition,
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
    final range =
        int.tryParse(
          widget.question.range?.toString() ?? '5',
        ) ??
        5; //3,4,6,7,10
    final scale =
        widget.question.scale ?? 'star'; // 'star', 'smiley', 'number'
    final isRequired = widget.question.required ?? false;

    IconData getSmileyIcon(int index, int range) {
      final smileys = [
        LineAwesomeIcons.sad_cry, // 1 - Very sad
        LineAwesomeIcons.sad_tear, // 2 - Sad
        LineAwesomeIcons.frown, // 3 - Disappointed
        LineAwesomeIcons.frown_open, // 4 - Unhappy
        LineAwesomeIcons.meh, // 5 - Neutral
        LineAwesomeIcons.smile, // 6 - Slightly positive
        LineAwesomeIcons.grin, // 7 - Happy
        LineAwesomeIcons.grin_alt, // 8 - Very happy
        LineAwesomeIcons.grin_squint, // 9 - Excited
        LineAwesomeIcons.grin_tears, // 10 - Extremely happy
      ];
      // Map current index to smiley range
      double normalized = index / (range - 1); // between 0.0 and 1.0
      int smileyIndex = (normalized * (smileys.length - 1)).round();

      return smileys[smileyIndex.clamp(0, smileys.length - 1)];
    }

    Widget buildRatingWidget(FormFieldState<double> field) {
      if (scale == 'number') {
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(range, (index) {
            final value = index + 1;
            final isSelected = selectedRating == value.toDouble();
            return GestureDetector(
              onTap: () {
                setState(() => selectedRating = value.toDouble());
                field.didChange(selectedRating);
                widget.onResponse(widget.question.id, value);

                final formState = context
                    .findAncestorStateOfType<SurveyWidgetState>()
                    ?.formKey
                    .currentState;
                if (formState?.validate() ?? false) {
                  context
                      .findAncestorStateOfType<SurveyWidgetState>()
                      ?.nextStep();
                }
              },
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.primaryColor),
                  color: isSelected ? theme.primaryColor : Colors.white,
                ),
                child: Text(
                  value.toString(),
                  style: TextStyle(
                    color: isSelected ? Colors.white : theme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }),
        );
      }

      // Use RatingBar for 'star' and 'smiley'
      return RatingBar.builder(
        initialRating: selectedRating ?? 0,
        minRating: 1,
        allowHalfRating: false,
        itemCount: range,
        itemSize: range > 6
            ? range == 7
                  ? 30
                  : 25
            : 40,
        glowColor: Colors.amber,
        itemPadding: EdgeInsets.symmetric(horizontal: range > 7 ? 2.0 : 4.0),
        itemBuilder: (context, index) {
          Color getSmileyColor(int index, int range) {
            final ratio = index / (range - 1);
            if (ratio < 0.4) {
              return const Color(0xFF8B0000); // Pitch/Dark Red
            } else if (ratio < 0.6) {
              return Colors.grey.shade600;
            } else {
              return Colors.amberAccent.shade100;
            }
          }

          if (scale == 'smiley') {
            return Icon(
              getSmileyIcon(index, range),
              color: getSmileyColor(index, range),
              size: range > 6
                  ? range == 7
                        ? 30
                        : 25
                  : 40,
            );
          }
          return Icon(Icons.star, color: theme.primaryColor);
        },
        onRatingUpdate: (rating) {
          setState(() => selectedRating = rating);
          field.didChange(rating);
          widget.onResponse(widget.question.id, rating.toInt());

          final formState = context
              .findAncestorStateOfType<SurveyWidgetState>()
              ?.formKey
              .currentState;
          if (formState?.validate() ?? false) {
            context.findAncestorStateOfType<SurveyWidgetState>()?.nextStep();
          }
        },
      );
    }

    return FormField<double>(
      validator: (value) => widget.requiredAnswerByLogicCondition
          ? AppLocalizations.of(context)!.response_required
          : (isRequired && (selectedRating == null || selectedRating == 0)
                ? AppLocalizations.of(context)!.please_select_rating
                : null),
      builder: (FormFieldState<double> field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (widget.question.imageUrl?.isNotEmpty ?? false)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: GestureDetector(
                  child: ClipRRect(
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
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                  ),
                  onTap: () =>
                      showFullScreenImage(context, widget.question.imageUrl!),
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
                Expanded(
                  child: Text(
                    translate(widget.question.headline, context) ?? '',
                    style:
                        theme.textTheme.headlineMedium ??
                        const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                widget.question.required == true ||
                        widget.requiredAnswerByLogicCondition == true
                    ? const SizedBox.shrink()
                    : Text(
                        AppLocalizations.of(context)!.optional,
                        textAlign: TextAlign.end,
                        style:
                            theme.textTheme.headlineSmall ??
                            const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w300,
                            ),
                      ),
              ],
            ),
            if (translate(widget.question.subheader, context)?.isNotEmpty ??
                false)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  translate(widget.question.subheader, context) ?? '',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            const SizedBox(height: 16),
            buildRatingWidget(field),
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
