import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

import '../../../l10n/app_localizations.dart';
import '../../models/question.dart';
import '../../utils/helper.dart';

class FreeTextQuestion extends StatefulWidget {
  final Question question;
  final Function(String, dynamic) onResponse;
  final dynamic response;
  final bool requiredAnswerByLogicCondition;

  const FreeTextQuestion({
    super.key,
    required this.question,
    required this.onResponse,
    this.response,
    required this.requiredAnswerByLogicCondition,
  });

  @override
  State<FreeTextQuestion> createState() => _FreeTextQuestionState();
}

class _FreeTextQuestionState extends State<FreeTextQuestion> {
  late TextEditingController _controller;
  late String _currentValue;

  VideoPlayerController? _videoController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.response is String ? widget.response as String : '';
    _controller = TextEditingController(text: _currentValue);
    _initializeVideo();
  }

  @override
  void dispose() {
    _controller.dispose();
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant FreeTextQuestion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.response != oldWidget.response) {
      _controller.text = widget.response;
      _currentValue = widget.response;
    }

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
    final question = widget.question;
    final isRequired = question.required ?? false;
    final charLimit = question.charLimit;
    final hasCharLimit = charLimit?['enabled'] ?? false;
    final maxChars = charLimit?['max'];
    final minChars = charLimit?['min'];

    return FormField<bool>(
      key: ValueKey(question.id),
      //autovalidateMode: AutovalidateMode.onUnfocus,
      initialValue: _currentValue.isNotEmpty,
      validator: (state) {
        if(widget.requiredAnswerByLogicCondition) {
          return AppLocalizations.of(context)!.response_required;
        }

        if (!(question.required ?? false)) return null;

        if (isRequired && _controller.text.trim().isEmpty) {
          return AppLocalizations.of(context)!.field_is_required;
        }

        if (hasCharLimit) {
          final min = int.tryParse(minChars ?? '');
          final max = int.tryParse(maxChars ?? '');

          if (min != null && _controller.text.trim().length < min) {
            return '${AppLocalizations.of(context)!.min_character_required}: $min';
          }

          if (max != null && _controller.text.trim().length > max) {
            return '${AppLocalizations.of(context)!.max_character_required}: $max';
          }
        }
        return null;
      },
      builder: (field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (question.imageUrl?.isNotEmpty ?? false)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Image.network(
                  question.imageUrl!,
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
              ),
            Text(
              //question.headline['default'] ?? '',
              translate(question.headline, context) ?? '',
              style:
                  theme.textTheme.headlineMedium ??
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            //if (question.subheader?['default']?.isNotEmpty ?? false)
            if (translate(question.subheader, context)?.isNotEmpty ?? false)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  //question.subheader!['default'] ?? '',
                  translate(question.subheader, context) ?? '',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _controller,
              decoration: InputDecoration(
                //labelText: question.placeholder?['default'] ?? AppLocalizations.of(context)!.type_answer_here,
                labelText: translate(question.placeholder, context) ?? AppLocalizations.of(context)!.type_answer_here,
                border: const OutlineInputBorder(),
                labelStyle: theme.textTheme.bodyMedium,
              ),
              maxLines: question.longAnswer == true ? null : 1,
              minLines: question.longAnswer == true ? 3 : 1,
              maxLength: hasCharLimit ? int.tryParse(maxChars ?? '0') : null,
              keyboardType:
                  {
                    'number': TextInputType.number,
                    'phone': TextInputType.phone,
                    'email': TextInputType.emailAddress,
                  }[question.inputType] ??
                  TextInputType.text,
              onChanged: (value) {
                _currentValue = value;
                widget.onResponse(widget.question.id, value.trim());
                field.didChange;
              },
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
