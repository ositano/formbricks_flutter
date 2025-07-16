import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../l10n/app_localizations.dart';
import '../../models/question.dart';
import '../../utils/helper.dart';

class MultipleChoiceSingleQuestion extends StatefulWidget {
  final Question question;
  final Function(String, dynamic) onResponse;
  final dynamic response;
  final bool requiredAnswerByLogicCondition;

  const MultipleChoiceSingleQuestion({
    super.key,
    required this.question,
    required this.onResponse,
    this.response,
    required this.requiredAnswerByLogicCondition
  });

  @override
  State<MultipleChoiceSingleQuestion> createState() => _MultipleChoiceSingleQuestionState();
}

class _MultipleChoiceSingleQuestionState extends State<MultipleChoiceSingleQuestion> {
  String? selectedOption;
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    selectedOption = widget.response as String?;
    _initializeVideo();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant MultipleChoiceSingleQuestion oldWidget) {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRequired = widget.question.required ?? false;
    final options = (widget.question.inputConfig?['choices'] as List?) ?? [];

    return FormField<bool>(
      validator: (_) {
        if(widget.requiredAnswerByLogicCondition) {
          return AppLocalizations.of(context)!.response_required;
        }

        if (isRequired && selectedOption == null) {
          return AppLocalizations.of(context)!.select_option;
        }
        return null;
      },
      builder: (field) {
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
              style: theme.textTheme.headlineMedium ??
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if ((translate(widget.question.subheader, context) ?? '').isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  translate(widget.question.subheader, context) ?? '',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            const SizedBox(height: 16),
            ...options.map<Widget>((option) {
              final optionId = option['id']?.toString();
              final label = translate(option['label'], context)?.toString() ?? '';

              if (optionId == null) return const SizedBox.shrink();

              final isSelected = selectedOption == optionId;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedOption = optionId;
                    widget.onResponse(widget.question.id, optionId);
                    field.didChange(true);
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected
                          ? theme.primaryColor
                          : theme.inputDecorationTheme.enabledBorder!.borderSide.color,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    color: theme.inputDecorationTheme.fillColor,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: isSelected
                            ? theme.primaryColor
                            : theme.unselectedWidgetColor,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          label,
                          style: theme.textTheme.bodyMedium
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            if (field.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 8),
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
