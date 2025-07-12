import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dotted_border/dotted_border.dart'; // Add to pubspec.yaml
import 'package:video_player/video_player.dart';

import '../../../l10n/app_localizations.dart';
import '../../formbricks_client.dart';
import '../../models/question.dart';
import '../../utils/helper.dart';

class FileUploadQuestion extends StatefulWidget {
  final Question question;
  final Function(String, dynamic) onResponse;
  final FormBricksClient client;
  final String surveyId;
  final String userId;
  final dynamic response;
  final bool requiredAnswerByLogicCondition;

  const FileUploadQuestion({
    super.key,
    required this.question,
    required this.onResponse,
    required this.client,
    required this.surveyId,
    required this.userId,
    this.response,
    required this.requiredAnswerByLogicCondition
  });

  @override
  State<FileUploadQuestion> createState() => _FileUploadQuestionState();
}

class _FileUploadQuestionState extends State<FileUploadQuestion> {
  List<String?> fileUrls = [];
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    fileUrls = (widget.response as List<dynamic>?)?.cast<String>() ?? [];
    _initializeVideo();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant FileUploadQuestion oldWidget) {
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

  Future<void> _pickAndUploadFile() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: widget.question.allowMultipleFiles ?? false,
      type: FileType.custom,
      allowedExtensions: widget.question.allowedFileExtensions?.cast<String>() ?? ['pdf', 'png', 'jpeg'],
    );
    if (result != null && result.files.isNotEmpty) {
      try {
        final urls = <String>[];
        for (var file in result.files) {
          if (file.size / (1024 * 1024) > (widget.question.maxSizeInMB ?? 10)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${AppLocalizations.of(context)!.file_size_exceeds_limit}, limit:  ${widget.question.maxSizeInMB ?? 10}MB')),
            );
            continue;
          }
          final url = await widget.client.uploadFile(
            surveyId: widget.surveyId,
            userId: widget.userId,
            filePath: file.path!,
          );
          if (url != null) urls.add(url);
        }
        setState(() {
          fileUrls.addAll(urls);
          widget.onResponse(widget.question.id, fileUrls);
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.error_uploading_file} $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRequired = widget.question.required ?? false;

    return FormField<bool>(
      validator: (value) => widget.requiredAnswerByLogicCondition
        ? AppLocalizations.of(context)!.response_required
        : (isRequired && fileUrls.isEmpty ? AppLocalizations.of(context)!.please_upload_file : null),
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
              style: theme.textTheme.headlineMedium ??
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (translate(widget.question.subheader, context)?.isNotEmpty ?? false)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  translate(widget.question.subheader, context) ?? '',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _pickAndUploadFile,
              child: DottedBorder(
                options: RoundedRectDottedBorderOptions(
                  color: theme.textTheme.headlineMedium!.color ?? Colors.black12,
                  strokeWidth: 1.5,
                  radius: const Radius.circular(12),
                  dashPattern: const [6, 3],
                ),
                child: Container(
                  color: theme.inputDecorationTheme.fillColor,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.file_upload_outlined, size: 30, color: theme.textTheme.bodyMedium?.color),
                      //const SizedBox(height: 12),
                      Text(
                        AppLocalizations.of(context)!.please_upload_file,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (fileUrls.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: fileUrls
                      .map((url) => Text('${AppLocalizations.of(context)!.uploaded}: $url'))
                      .toList(),
                ),
              ),
            if (field.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(field.errorText!, style: TextStyle(color: theme.colorScheme.error)),
              ),
          ],
        );
      },
    );
  }
}
