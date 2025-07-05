import 'package:flutter/material.dart';
import '../../models/question.dart';

class ContactInfoQuestion extends StatefulWidget {
  final Question question;
  final Function(String, dynamic) onResponse;
  final dynamic response;

  const ContactInfoQuestion({
    super.key,
    required this.question,
    required this.onResponse,
    this.response,
  });

  @override
  State<ContactInfoQuestion> createState() => _ContactInfoQuestionState();
}

class _ContactInfoQuestionState extends State<ContactInfoQuestion> {
  late var _nameController = TextEditingController();
  late var _emailController = TextEditingController();
  late var _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
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
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ContactInfoQuestion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.response != oldWidget.response) {
      final response = widget.response as Map<String, dynamic>? ?? {};
      _updateControllerText(response);
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRequired = widget.question.required ?? false;

    return FormField<bool>(
      key: _formKey,
      validator: (value) {
        if (isRequired &&
            (_nameController.text.isEmpty || _phoneController.text.isEmpty || _emailController.text.isEmpty)) {
          return 'All fields are required';
        }
        final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
        if (!emailRegex.hasMatch(_emailController.text)) {
          return 'Please enter a valid email';
        }
        return null;
      },
      builder: (FormFieldState<bool> field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.question.headline['default'] ?? '',
              style: theme.textTheme.headlineMedium ?? const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (widget.question.subheader?['default']?.isNotEmpty ?? false)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  widget.question.subheader?['default'] ?? '',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
                labelStyle: theme.textTheme.bodyMedium,
                errorText: field.hasError ? field.errorText : null,
              ),
              onChanged: (value) => _updateResponse(),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                labelStyle: theme.textTheme.bodyMedium,
                errorText: field.hasError ? field.errorText : null,
              ),
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) => _updateResponse(),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone',
                border: OutlineInputBorder(),
                labelStyle: theme.textTheme.bodyMedium,
                errorText: field.hasError ? field.errorText : null,
              ),
              keyboardType: TextInputType.phone,
              onChanged: (value) => _updateResponse(),
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