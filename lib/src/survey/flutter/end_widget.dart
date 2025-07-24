import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

import '../../../l10n/app_localizations.dart';
import '../../models/environment/ending.dart';
import '../../utils/helper.dart';

class EndWidget extends StatefulWidget {
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
  State<EndWidget> createState() => _EndWidgetState();
}

class _EndWidgetState extends State<EndWidget> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  void _initializeVideo() {
    _videoController?.dispose();
    _chewieController?.dispose();
    _chewieController = null;

    final videoUrl = widget.ending.videoUrl;
    if (videoUrl?.isNotEmpty ?? false) {
      _videoController = VideoPlayerController.network(videoUrl!)
        ..initialize()
            .then((_) {
              if (!mounted) return;
              if (_videoController!.value.isInitialized) {
                _chewieController = ChewieController(
                  videoPlayerController: _videoController!,
                  autoPlay: false,
                  looping: false,
                );
                setState(() {});
              }
            })
            .catchError((error) {
              print('Video initialization error: $error');
            });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.ending.imageUrl?.isNotEmpty ?? false)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: CachedNetworkImage(
                imageUrl: widget.ending.imageUrl!,
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
        else if (_chewieController != null &&
            _videoController?.value.isInitialized == true)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Chewie(controller: _chewieController!),
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
          translate(widget.ending.headline, context) ?? "",
          style:
              theme.textTheme.headlineMedium ??
              const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        if (translate(widget.ending.subheader, context)?.isNotEmpty ?? false)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              translate(widget.ending.subheader, context) ?? '',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        const SizedBox(height: 16),

        widget.showCloseButton
            ? Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    widget.onComplete
                        ?.call(); // notify TriggerManager to show next
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    widget.nextLabel ?? AppLocalizations.of(context)!.close,
                  ),
                ),
              )
            : const SizedBox.shrink(),
      ],
    );
  }
}
