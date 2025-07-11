import 'package:flutter/material.dart';
import '../../formbricks_flutter.dart';
import '../utils/helper.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class EndWidget extends StatefulWidget {
  final Survey survey;

  const EndWidget({
    super.key,
    required this.survey,
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
    final ending = widget.survey.endings?.firstWhere(
          (e) => e['type'] == 'endScreen',
      orElse: () => widget.survey.endings!.first,
    );

    _videoController?.dispose();
    _chewieController?.dispose();
    _chewieController = null;

    final videoUrl = ending?['videoUrl'];
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
    final ending = widget.survey.endings?.firstWhere(
          (e) => e['type'] == 'endScreen',
      orElse: () => widget.survey.endings!.first,
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (ending?['imageUrl']?.isNotEmpty ?? false)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Image.network(
              ending?['imageUrl'],
              fit: BoxFit.contain,
              loadingBuilder: (context, widget, event) => SizedBox(
                width: 20,
                height: 20,
                child: Center(child: CircularProgressIndicator()),
              ),
              errorBuilder: (context, error, stackTrace) =>
              const SizedBox.shrink(),
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
            child: Icon(Icons.check_circle, size: 100, color: Colors.green,),
          ),
        Text(
          translate(ending?['headline'], context) ?? "",
          style:
          theme.textTheme.headlineMedium ??
              const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        if (translate(ending?['subheader'], context)?.isNotEmpty ?? false)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              translate(ending?['subheader'], context) ?? '',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }
}