import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import '../../../formbricks_flutter.dart';
import '../../models/question.dart';
import '../../utils/helper.dart';

/// Calendar booking input (e.g., using cal.com)
class CalQuestion extends StatefulWidget {
  final Question question;
  final Function(String, dynamic) onResponse;
  final dynamic response;
  final bool requiredAnswerByLogicCondition;

  const CalQuestion({
    super.key,
    required this.question,
    required this.onResponse,
    this.response,
    required this.requiredAnswerByLogicCondition,
  });

  @override
  State<CalQuestion> createState() => _CalQuestionState();
}

class _CalQuestionState extends State<CalQuestion> {
  bool isScheduled = false;
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    isScheduled = widget.response == true;
    _initializeVideo();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CalQuestion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.question.videoUrl != oldWidget.question.videoUrl) {
      _initializeVideo();
    }
  }

  void _initializeVideo() {
    _videoController?.dispose();
    _chewieController?.dispose();
    _chewieController = null;

    final videoUrl = widget.question.videoUrl;
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

  Future<void> _openCalendar() async {
    final url =
        'https://${widget.question.calHost ?? 'cal.com'}/${widget.question.calUserName ?? ''}';
    if (await canLaunch(url)) {
      await launch(url);
      setState(() {
        isScheduled = true;
        widget.onResponse(widget.question.id, true);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.could_not_open_calendar),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRequired = widget.question.required ?? false;

    return FormField<bool>(
      validator: (value) => widget.requiredAnswerByLogicCondition
          ? AppLocalizations.of(context)!.response_required
          : (isRequired && !isScheduled
                ? AppLocalizations.of(context)!.pls_schedule_meeting
                : null),
      builder: (FormFieldState<bool> field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.question.imageUrl?.isNotEmpty ?? false)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: GestureDetector(child: ClipRRect(
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
                            child: CircularProgressIndicator())),
                    errorWidget: (context, url, error) =>
                    const Icon(Icons.error),
                  ),
                ),
                  onTap: () => showFullScreenImage(context, widget.question.imageUrl!),
                ),
              )
            else if (_chewieController != null &&
                _videoController?.value.isInitialized == true)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Chewie(controller: _chewieController!),
              ),
            Text(
              translate(widget.question.headline, context) ?? '',
              style:
                  theme.textTheme.headlineMedium ??
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (translate(widget.question.subheader, context)?.isNotEmpty ??
                false)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  widget.question.subheader?['default'] ?? '',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _openCalendar,
              child: Text(AppLocalizations.of(context)!.schedule_meeting),
            ),
            if (isScheduled)
              Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  AppLocalizations.of(context)!.meeting_scheduled,
                  style: theme.textTheme.bodySmall,
                ),
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
