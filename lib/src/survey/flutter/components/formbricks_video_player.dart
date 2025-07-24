import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class FormbricksVideoPlayer extends StatefulWidget {
  final String videoUrl;

  const FormbricksVideoPlayer({required this.videoUrl, super.key});

  @override
  State<FormbricksVideoPlayer> createState() => _FormbricksVideoPlayerState();
}

class _FormbricksVideoPlayerState extends State<FormbricksVideoPlayer> {
  YoutubePlayerController? _youtubeController;
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;

  bool get isYouTube => isYouTubeUrl(widget.videoUrl);

  @override
  void initState() {
    super.initState();
    if (isYouTube) {
      final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);
      _youtubeController = YoutubePlayerController(
        initialVideoId: videoId ?? '',
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
        ),
      );
    } else {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
      _videoController!.initialize().then((_) {
        _chewieController = ChewieController(
          videoPlayerController: _videoController!,
          autoPlay: false,
          looping: false,
        );
        setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isYouTube && _youtubeController != null) {
      return YoutubePlayer(
        controller: _youtubeController!,
        showVideoProgressIndicator: true,
      );
    }

    if (_videoController != null &&
        _videoController!.value.isInitialized &&
        _chewieController != null) {
      return Chewie(controller: _chewieController!);
    }

    return const Center(child: CircularProgressIndicator());
  }
}

bool isYouTubeUrl(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null) return false;

  return uri.host.contains("youtube.com") || uri.host.contains("youtu.be");
}
