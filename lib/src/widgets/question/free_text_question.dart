import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

import '../../models/question.dart';

class FreeTextQuestion extends StatefulWidget {
  final Question question;
  final Function(String, dynamic) onResponse;
  final dynamic response;

  const FreeTextQuestion({
    super.key,
    required this.question,
    required this.onResponse,
    this.response,
  });

  @override
  State<FreeTextQuestion> createState() => _FreeTextQuestionState();
}

class _FreeTextQuestionState extends State<FreeTextQuestion> {
  late TextEditingController _controller;
  String _currentValue = '';
  bool _isInitialized = false;
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.response?.toString() ?? '';
    _controller = TextEditingController();
    _isInitialized = true;
    _updateControllerText();
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
      _currentValue = widget.response?.toString() ?? '';
      _updateControllerText();
    }
    if (widget.question.videoUrl != oldWidget.question.videoUrl) {
      _initializeVideo();
    }
  }

  void _updateControllerText() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_controller.text != _currentValue) {
        _controller.text = _currentValue;
      }
    });
  }

  void _initializeVideo() {
    final videoUrl = widget.question.videoUrl;
    if (videoUrl?.isNotEmpty ?? false) {
      _videoController = VideoPlayerController.network(videoUrl!)
        ..initialize().then((_) {
          setState(() {
            _chewieController = ChewieController(
              videoPlayerController: _videoController!,
              autoPlay: false,
              looping: false,
            );
          });
        }).catchError((error) {
          print('Video initialization error: $error');
        });
    } else {
      _videoController?.dispose();
      _chewieController?.dispose();
      _chewieController = null;
    }
  }

  void _updateResponse(String value) {
    if (_isInitialized) {
      _currentValue = value;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onResponse(widget.question.id, _currentValue);
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (question.imageUrl?.isNotEmpty ?? false)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Image.network(
              question.imageUrl!,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
            ),
          )
        else if (_chewieController != null && _chewieController!.videoPlayerController.value.isInitialized)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Chewie(
              controller: _chewieController!,
            ),
          ),
        Text(
          question.headline['default'] ?? '',
          style: theme.textTheme.headlineMedium ?? const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        if (question.subheader?['default']?.isNotEmpty ?? false)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              question.subheader!['default'] ?? '',
              style: theme.textTheme.bodyMedium,
            ),
          ),
        const SizedBox(height: 16),
        FormField<String>(
          initialValue: _currentValue,
          validator: (value) {
            if (isRequired && (value == null || value.isEmpty)) {
              return 'This field is required';
            }
            if (hasCharLimit) {
              if (value != null && value.length < int.tryParse(minChars)!) {
                return 'Minimum $minChars characters required';
              }
              if (value != null && maxChars != null && value.length > int.tryParse(maxChars)!) {
                return 'Maximum $maxChars characters allowed';
              }
            }
            return null;
          },
          builder: (FormFieldState<String> field) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _controller,
                  decoration: InputDecoration(
                    labelText: question.placeholder?['default'] ?? 'Type your answer here...',
                    border: OutlineInputBorder(),
                    labelStyle: theme.textTheme.bodyMedium,
                    errorText: field.hasError ? field.errorText : null,
                    counterText: hasCharLimit
                        ? '${_controller.text.length}/${maxChars ?? ''}'
                        : null,
                  ),
                  maxLines: question.longAnswer == true ? null : 1,
                  minLines: question.longAnswer == true ? 3 : 1,
                  maxLength: hasCharLimit ? int.tryParse(maxChars) : null,
                  keyboardType:  {
                    'number': TextInputType.number,
                    'phone': TextInputType.phone,
                    'email': TextInputType.emailAddress,
                  }[question.inputType] ?? TextInputType.text,//question.inputType == 'text' ? TextInputType.text : TextInputType.number,
                  onChanged: _updateResponse,
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}