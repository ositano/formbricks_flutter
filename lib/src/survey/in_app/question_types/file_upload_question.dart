
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:mime_type/mime_type.dart';
import '../../../../formbricks_flutter.dart';
import '../../../models/upload/fetch_storage_url_request_body.dart';
import '../../../utils/file_upload_utils.dart';
import '../../../utils/helper.dart';
import '../../../utils/logger.dart';
import '../components/custom_heading.dart';

class FileUploadQuestion extends StatefulWidget {
  final Question question;
  final Function(String, dynamic) onResponse;
  final FormbricksClient client;
  final String surveyId;
  final dynamic response;
  final bool requiredAnswerByLogicCondition;

  const FileUploadQuestion({
    super.key,
    required this.question,
    required this.onResponse,
    required this.client,
    required this.surveyId,
    this.response,
    required this.requiredAnswerByLogicCondition,
  });

  @override
  State<FileUploadQuestion> createState() => _FileUploadQuestionState();
}

class _FileUploadQuestionState extends State<FileUploadQuestion> {
  List<String?> fileUrls = [];
  List<String?> imageFileUrls = [];

  @override
  void initState() {
    super.initState();
    fileUrls = (widget.response as List<dynamic>?)?.cast<String>() ?? [];
    imageFileUrls = fileUrls.where( (url) => FileUploadUtils.isValidFileExtension(url!, widget.question.allowedFileExtensions ??
        ['pdf', 'png', 'jpg', 'jpeg'])).toList();
  }

  Future<void> _pickAndUploadFile() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: widget.question.allowMultipleFiles ?? false,
      type: FileType.custom,
      allowedExtensions: widget.question.allowedFileExtensions ??
          ['pdf', 'png', 'jpg', 'jpeg'],
    );

    if (result != null && result.files.isNotEmpty) {
      try {
        final urls = <String>[];
        final imageUrls = <String>[];

        for (var file in result.files) {
          if(!FileUploadUtils.isValidFileExtension(file.path!, widget.question.allowedFileExtensions ??
              ['pdf', 'png', 'jpg', 'jpeg'])){
            Log.instance.d('Unsupported file type, Select either of these: ${widget.question.allowedFileExtensions ??
                ['pdf', 'png', 'jpg', 'jpeg']}');
            if(mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Unsupported file type, Select either of these: ${widget
                        .question.allowedFileExtensions ??
                        ['pdf', 'png', 'jpg', 'jpeg']}',
                  ),
                ),
              );
            }
            continue;
          }

          if(!FileUploadUtils.isValidFileSize(File(file.path!), widget.question.maxSizeInMB ?? 10)){
            if(mounted) {
              Log.instance.d('${AppLocalizations.of(context)!
                  .file_size_exceeds_limit}, limit: ${widget.question
                  .maxSizeInMB ?? 10}MB');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${AppLocalizations.of(context)!
                        .file_size_exceeds_limit}, limit: ${widget.question
                        .maxSizeInMB ?? 10}MB',
                  ),
                ),
              );
            }
            continue;
          }

          String? mimeType = mime(file.path);
          var fileRequestBody = FetchStorageUrlRequestBody(
              fileName: file.name,
              fileType: mimeType!,
              surveyId: widget.surveyId,
              filePath: file.path!,
              allowedFileExtensions: widget
                  .question.allowedFileExtensions,
          );
          final url = await widget.client.uploadFile(fileRequestBody);
            urls.add(url);
            imageUrls.add(url);
        }

        setState(() {
          fileUrls.addAll(urls);
          imageFileUrls.addAll(imageUrls);
          widget.onResponse(widget.question.id, fileUrls);
        });
      } catch (e, st) {
        Log.instance.d(st);
        if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  '${AppLocalizations.of(context)!.error_uploading_file} $e'),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    bool isRequired = widget.question.required ?? false;
    if(widget.requiredAnswerByLogicCondition){
      isRequired = widget.requiredAnswerByLogicCondition;
    }

    return FormField<bool>(
      key: ValueKey(widget.question.id),
      validator: (value) => isRequired && fileUrls.isEmpty
          ? AppLocalizations.of(context)!.please_upload_file
          : null,
      builder: (FormFieldState<bool> field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomHeading(question: widget.question, required: isRequired),
            GestureDetector(
              onTap: _pickAndUploadFile,
              child: DottedBorder(
                options: RoundedRectDottedBorderOptions(
                  color:
                  theme.textTheme.headlineMedium?.color ?? Colors.black12,
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
                      Icon(Icons.file_upload_outlined,
                          size: 30,
                          color: theme.textTheme.bodyMedium?.color),
                      Text(
                        AppLocalizations.of(context)!.click_to_upload_files,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (imageFileUrls.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: imageFileUrls.map((url) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: url!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) =>
                        const Icon(Icons.broken_image),
                      ),
                    );
                  }).toList(),
                ),
              ),
            if (fileUrls.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: fileUrls.map((url) {
                    final isImage = FileUploadUtils.isValidFileExtension(url!, widget.question.allowedFileExtensions ??
                        ['pdf', 'png', 'jpg', 'jpeg']);
                    return Stack(
                      alignment: Alignment.topRight,
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (isImage) {
                              showFullScreenImage(context, url);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(AppLocalizations.of(context)!.cannot_preview_file)),
                              );
                            }
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: isImage
                                    ? CachedNetworkImage(
                                  imageUrl: url,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorWidget: (context, url, error) =>
                                  const Icon(Icons.broken_image),
                                )
                                    : Container(
                                  width: 80,
                                  height: 80,
                                  color: Colors.grey.shade200,
                                  child: const Icon(Icons.insert_drive_file, size: 40),
                                ),
                              ),
                              const SizedBox(height: 4),
                              SizedBox(
                                width: 80,
                                child: Text(
                                  url.split('/').last,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: Theme.of(context).textTheme.bodySmall,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Remove icon
                        Positioned(
                          right: -6,
                          top: -6,
                          child: IconButton(
                            icon: const Icon(Icons.cancel, size: 20, color: Colors.redAccent),
                            onPressed: () {
                              setState(() {
                                fileUrls.remove(url);
                                widget.onResponse(widget.question.id, fileUrls);
                              });
                            },
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),


            if (field.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(field.errorText!,
                    style: TextStyle(color: theme.colorScheme.error)),
              ),
          ],
        );
      },
    );
  }
}
