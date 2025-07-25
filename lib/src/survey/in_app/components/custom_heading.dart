import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../formbricks_flutter.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../models/environment/question.dart';
import '../../../utils/helper.dart';
import '../../../utils/theme_manager.dart';
import 'formbricks_video_player.dart';

class CustomHeading extends StatelessWidget {
  final Question question;
  final bool required;

  const CustomHeading({
    super.key,
    required this.question,
    required this.required,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (question.imageUrl?.isNotEmpty ?? false)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: GestureDetector(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: CachedNetworkImage(
                  imageUrl: question.imageUrl!,
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
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
              onTap: () => showFullScreenImage(context, question.imageUrl!),
            ),
          )
        else if (question.videoUrl?.isNotEmpty ?? false)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                theme.extension<MyCustomTheme>()!.styleRoundness!,
              ),
              child: FormbricksVideoPlayer(videoUrl: question.videoUrl!),
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                translate(question.headline, context) ?? '',
                style:
                    theme.textTheme.headlineMedium ??
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            required
                ? const SizedBox.shrink()
                : Text(
                    AppLocalizations.of(context)!.optional,
                    textAlign: TextAlign.end,
                    style:
                        theme.textTheme.titleMedium ??
                        const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w300,
                        ),
                  ),
          ],
        ),
        if (translate(question.subheader, context)?.isNotEmpty ?? false)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              translate(question.subheader, context) ?? '',
              style: theme.textTheme.bodyMedium,
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }
}
