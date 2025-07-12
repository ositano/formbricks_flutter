import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../formbricks_flutter.dart';
import '../../models/question.dart';
import '../../utils/helper.dart';

class ContactInfoQuestion extends StatefulWidget {
  final Question question;
  final Function(String, dynamic) onResponse;
  final dynamic response;
  final bool requiredAnswerByLogicCondition;

  const ContactInfoQuestion({
    super.key,
    required this.question,
    required this.onResponse,
    this.response,
    required this.requiredAnswerByLogicCondition
  });

  @override
  State<ContactInfoQuestion> createState() => _ContactInfoQuestionState();
}

class _ContactInfoQuestionState extends State<ContactInfoQuestion> {
  late var _nameController = TextEditingController();
  late var _emailController = TextEditingController();
  late var _phoneController = TextEditingController();

  VideoPlayerController? _videoController;
  ChewieController? _chewieController;

  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    final response = widget.response as Map<String, dynamic>? ?? {};
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _isInitialized = true;
    _updateControllerText(response);
    _initializeVideo();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ContactInfoQuestion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.response != oldWidget.response) {
      final response = widget.response as Map<String, dynamic>? ?? {};
      _updateControllerText(response);
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

  void _updateControllerText(Map<String, dynamic> response) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _nameController.text = response['name']?.toString() ?? '';
      _emailController.text = response['email']?.toString() ?? '';
      _phoneController.text = response['phone']?.toString() ?? '';
    });
  }

  void _updateResponse() {
    if (_isInitialized) {
      final response = {
        'name': _nameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
      };
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onResponse(widget.question.id, response);
      });
    }
  }

  Widget _buildField({
    required bool show,
    required bool required,
    required String label,
    required TextEditingController controller,
    required TextInputType? textInputType,
    required void Function() onChanged,
  }) {
    if (!show) return const SizedBox.shrink();
    return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
            ),
            SizedBox(height: 8.0,),
            TextFormField(
              controller: controller,
              keyboardType: textInputType,
              onChanged: (_) {
                onChanged();
              },
            ),
          ],
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRequired = widget.question.required ?? false;

    return FormField<bool>(
      validator: (value) {
        if(widget.requiredAnswerByLogicCondition) {
          return AppLocalizations.of(context)!.response_required;
        }
        if (isRequired &&
            (_nameController.text.isEmpty || _phoneController.text.isEmpty || _emailController.text.isEmpty)) {
          return AppLocalizations.of(context)!.all_fields_are_required;
        }
        final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
        if (!emailRegex.hasMatch(_emailController.text)) {
          return AppLocalizations.of(context)!.please_enter_valid_email;
        }
        return null;
      },
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
              style: theme.textTheme.headlineMedium ?? const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

            _buildField(
              show: true,
              required: true,
              label: AppLocalizations.of(context)!.name,
              controller: _nameController,
              onChanged: () => _updateResponse(),
              textInputType: TextInputType.name,
            ),
            _buildField(
              show: true,
              required: true,
              label: AppLocalizations.of(context)!.email,
              controller: _emailController,
              onChanged: () => _updateResponse(),
              textInputType: TextInputType.emailAddress,
            ),
            _buildField(
              show: true,
              required: true,
              label: AppLocalizations.of(context)!.phone,
              controller: _phoneController,
              onChanged: () => _updateResponse(),
              textInputType: TextInputType.phone,
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