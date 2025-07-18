import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';
import '../../../formbricks_flutter.dart';
import '../../models/question.dart';
import '../../utils/helper.dart';

class DateQuestion extends StatefulWidget {
  final Question question;
  final Function(String, dynamic) onResponse;
  final dynamic response;
  final bool requiredAnswerByLogicCondition;

  const DateQuestion({
    super.key,
    required this.question,
    required this.onResponse,
    this.response,
    required this.requiredAnswerByLogicCondition
  });

  @override
  State<DateQuestion> createState() => _DateQuestionState();
}

class _DateQuestionState extends State<DateQuestion> {
  DateTime? selectedDate;
  late final DateFormat formatter;
  late final TextEditingController _controller;
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    formatter = DateFormat(widget.question.format ?? 'yyyy-MM-dd');
    selectedDate = _parseDate(widget.response);
    _controller = TextEditingController(text: widget.response);
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
  void didUpdateWidget(covariant DateQuestion oldWidget) {
    super.didUpdateWidget(oldWidget);

    final newDate = _parseDate(widget.response);
    if (newDate != null && newDate != selectedDate) {
      selectedDate = newDate;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _controller.text = formatter.format(newDate);
        }
      });
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
    if (videoUrl != null && videoUrl.isNotEmpty) {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl))
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
          debugPrint('Video initialization error: $error');
        });
    }
  }

  DateTime? _parseDate(dynamic input) {
    if (input is DateTime) return input;
    if (input is String && input.isNotEmpty) {
      try {
        return DateFormat(
          widget.question.format ?? 'yyyy-MM-dd',
        ).parseStrict(input);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  Future<void> _pickDate(FormFieldState<bool> field) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
        builder: (context, child) {
          return Theme(
            data: ThemeData.light().copyWith(
                colorScheme: ColorScheme.light(
                    onPrimary: Theme.of(context).cardColor, // selected text color
                    onSurface: Theme.of(context).textTheme.headlineMedium!.color!, // default text color
                    primary: Theme.of(context).primaryColor // circle color
                ),
            ),
            child: child!,
          );
        }
    );

    if (picked != null && mounted) {
      setState(() {
        selectedDate = picked;
        _controller.text = formatter.format(picked);
      });

      widget.onResponse(widget.question.id, formatter.format(picked));
      field.didChange(true); // only trigger after valid input
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final q = widget.question;
    final isRequired = q.required ?? false;

    return FormField<bool>(
      key: ValueKey(q.id),
      initialValue: selectedDate != null,
      validator: (_) => widget.requiredAnswerByLogicCondition
    ? AppLocalizations.of(context)!.response_required
        : (isRequired && selectedDate == null
          ? AppLocalizations.of(context)!.please_select_date
          : null),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Text(
                  translate(widget.question.headline, context) ?? '',
                  style: theme.textTheme.headlineMedium ??
                      const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                ),
                widget.question.required == true || widget.requiredAnswerByLogicCondition == true ? const SizedBox.shrink() :
                Text(
                  AppLocalizations.of(context)!.optional,
                  textAlign: TextAlign.end,
                  style: theme.textTheme.headlineSmall ??
                      const TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
                ),
              ],
            ),
            if (translate(q.subheader, context)?.isNotEmpty ?? false)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  translate(q.subheader, context) ?? "",
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => _pickDate(field),
              child: Container(
                height: 100,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: theme.inputDecorationTheme.fillColor,
                  border: Border.all(color: theme.textTheme.headlineMedium!.color ?? Colors.black12, width: 1.0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.calendar_month, color: Theme.of(context).iconTheme.color),
                      const SizedBox(width: 8),
                      Text(
                        selectedDate != null
                            ? formatter.format(selectedDate!)
                            : AppLocalizations.of(context)!.select_date,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    ],
                  ),
                ),
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
