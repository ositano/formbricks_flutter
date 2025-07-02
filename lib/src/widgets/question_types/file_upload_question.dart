import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../../formbricks_client.dart';
import '../../models/question.dart';

/// Upload files (e.g., screenshots)
class FileUploadQuestion extends StatefulWidget {
  final Question question;
  final Function(String, dynamic) onResponse;
  final FormbricksClient client;
  final String surveyId;
  final String userId;

  const FileUploadQuestion({
    super.key,
    required this.question,
    required this.onResponse,
    required this.client,
    required this.surveyId,
    required this.userId,
  });

  @override
  State<FileUploadQuestion> createState() => _FileUploadQuestionState();
}

class _FileUploadQuestionState extends State<FileUploadQuestion> {
  String? fileUrl;

  Future<void> _pickAndUploadFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      try {
        final url = await widget.client.uploadFile(
          surveyId: widget.surveyId,
          userId: widget.userId,
          filePath: result.files.single.path!,
        );
        setState(() {
          fileUrl = url;
          widget.onResponse(widget.question.id, url);
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading file: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.question.headline, style: theme.textTheme.headlineMedium ?? const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        if (widget.question.subheader.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(widget.question.subheader, style: theme.textTheme.bodyMedium,),
          ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _pickAndUploadFile,
          child: const Text('Upload File'),
        ),
        if (fileUrl != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text('Uploaded: $fileUrl'),
          ),
      ],
    );
  }
}