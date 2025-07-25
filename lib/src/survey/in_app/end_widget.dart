import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../models/environment/ending.dart';
import '../../utils/helper.dart';
import '../../utils/theme_manager.dart';
import 'components/formbricks_video_player.dart';

class EndWidget extends StatelessWidget {
  final Ending ending;
  final bool showCloseButton;
  final VoidCallback? onComplete;
  final String? nextLabel;

  const EndWidget({
    super.key,
    required this.ending,
    required this.showCloseButton,
    required this.onComplete,
    required this.nextLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (ending.imageUrl?.isNotEmpty ?? false)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: CachedNetworkImage(
                imageUrl: ending.imageUrl!,
                fit: BoxFit.contain,
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
          )
        else if (ending.videoUrl?.isNotEmpty ?? false)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                theme.extension<MyCustomTheme>()!.styleRoundness!,
              ),
              child: FormbricksVideoPlayer(videoUrl: ending.videoUrl!),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Icon(
              Icons.check_circle_outline,
              size: 100,
              color: Colors.green,
            ),
          ),
        Text(
          translate(ending.headline, context) ?? "",
          style:
              theme.textTheme.headlineMedium ??
              const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        if (translate(ending.subheader, context)?.isNotEmpty ?? false)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              translate(ending.subheader, context) ?? '',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        const SizedBox(height: 16),
        showCloseButton
            ? Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    onComplete
                        ?.call(); // notify TriggerManager to show next
                    Navigator.of(context).maybePop();
                  },
                  child: Text(
                    nextLabel ?? AppLocalizations.of(context)!.close,
                  ),
                ),
              )
            : const SizedBox.shrink(),
      ],
    );
  }
}
