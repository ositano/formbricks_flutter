import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../../../l10n/app_localizations.dart';
import '../../formbricks_client.dart';
import '../../models/question.dart';
import '../../utils/helper.dart';

/// Upload files (e.g., screenshots)
class FileUploadQuestion extends StatefulWidget {
  final Question question;
  final Function(String, dynamic) onResponse;
  final FormBricksClient client;
  final String surveyId;
  final String userId;
  final dynamic response;

  const FileUploadQuestion({
    super.key,
    required this.question,
    required this.onResponse,
    required this.client,
    required this.surveyId,
    required this.userId,
    this.response,
  });

  @override
  State<FileUploadQuestion> createState() => _FileUploadQuestionState();
}

class _FileUploadQuestionState extends State<FileUploadQuestion> {
  List<String?> fileUrls = [];

  @override
  void initState() {
    super.initState();
    fileUrls = (widget.response as List<dynamic>?)?.cast<String>() ?? [];
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
          if(url != null) {
            urls.add(url);
          }
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
      validator: (value) => isRequired && fileUrls.isEmpty ? AppLocalizations.of(context)!.please_upload_file : null,
      builder: (FormFieldState<bool> field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                //widget.question.headline['default'] ?? '',
                translate(widget.question.headline, context) ?? '',
                style: theme.textTheme.headlineMedium ?? const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            if (widget.question.subheader?['default']?.isNotEmpty ?? false)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                    //widget.question.subheader?['default'] ?? '',
                    translate(widget.question.subheader, context) ?? '',
                    style: theme.textTheme.bodyMedium),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _pickAndUploadFile,
              child: Text(AppLocalizations.of(context)!.upload_file),
            ),
            if (fileUrls.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: fileUrls.map((url) => Text('${AppLocalizations.of(context)!.uploaded}: $url')).toList(),
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